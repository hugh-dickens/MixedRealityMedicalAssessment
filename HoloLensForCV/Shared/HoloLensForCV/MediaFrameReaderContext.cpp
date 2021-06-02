//*********************************************************
//
// Copyright (c) Microsoft. All rights reserved.
// This code is licensed under the MIT License (MIT).
// THIS CODE IS PROVIDED *AS IS* WITHOUT WARRANTY OF
// ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING ANY
// IMPLIED WARRANTIES OF FITNESS FOR A PARTICULAR
// PURPOSE, MERCHANTABILITY, OR NON-INFRINGEMENT.
//
//*********************************************************

#include "pch.h"

namespace HoloLensForCV
{
    /// <summary>
    /// Struct to contain camera calibration parameters 
    /// (intrinsics and extrinsics) for the HoloLens 2
    /// https://github.com/doughtmw/HoloLensCamCalib/tree/f4762cc37f148626b5a3ecdb585f420780725314
    /// </summary>
    struct CameraCalibrationParameters
    {
        // HL2: check to see if the camera intrinsics exist - they don't...
        // Set manually for testing
        // https://github.com/doughtmw/HoloLensCamCalib/blob/master/Examples/HL2/896x504/data.json
        /*{"camera_matrix": [[687.7084133264314, 0.0, 435.87585657815976], [0.0, 688.8967461985196, 242.48218786961218], [0.0, 0.0, 1.0]],
        "dist_coeff" : [[0.007576387773579617, -0.008347022259459137, 0.004030833288551814, -0.0005115698316792066, 0.0]],
        "height" : 504, "width" : 896}*/

        //Windows::Foundation::Numerics::float2 focalLength(687.7084133264314f, 688.8967461985196f); // (0,0) & (1,1)
        //Windows::Foundation::Numerics::float2 principalPoint(435.87585657815976f, 242.48218786961218f); // (0,2) & (2,2)
        //Windows::Foundation::Numerics::float3 radialDistortion(0.007576387773579617f, -0.008347022259459137f, 0.0f); // (0,0) & (0,1) & (0,4)
        //Windows::Foundation::Numerics::float2 tangentialDistortion(0.004030833288551814f, -0.0005115698316792066f); // (0,2) & (0,3)
        //uint imageWidth(896);
        //uint imageHeight(504);

        Windows::Foundation::Numerics::float2 focalLength;
        Windows::Foundation::Numerics::float2 principalPoint;
        Windows::Foundation::Numerics::float3 radialDistortion;
        Windows::Foundation::Numerics::float2 tangentialDistortion;
        int imageWidth;
        int imageHeight;

        // Create the camera intrinsics matrix from manual calculations
        //auto manualCameraIntrinsics = ref new Windows::Media::Devices::Core::CameraIntrinsics(focalLength, principalPoint, radialDistortion, tangentialDistortion, imageWidth, imageHeight);

        //// Cache to the current sensor frame
        //sensorFrame->CoreCameraIntrinsics = manualCameraIntrinsics;
    }CameraCalibrationParameters;

    /// <summary>
    /// Set the camera parameters of cached CameraCalibrationParameters struct
    /// and use for improving tracking performance.
    /// </summary>
    /// <param name="focalLength"></param>
    /// <param name="principalPoint"></param>
    /// <param name="radialDistortion"></param>
    /// <param name="tangentialDistortion"></param>
    /// <param name="imageWidth"></param>
    /// <param name="imageHeight"></param>
    void CameraIntrinsicsAndExtrinsics::SetCameraParameters(
        Windows::Foundation::Numerics::float2 focalLength,
        Windows::Foundation::Numerics::float2 principalPoint,
        Windows::Foundation::Numerics::float3 radialDistortion,
        Windows::Foundation::Numerics::float2 tangentialDistortion,
        int imageWidth,
        int imageHeight)
    {
        CameraCalibrationParameters.focalLength = focalLength;
        CameraCalibrationParameters.principalPoint = principalPoint;
        CameraCalibrationParameters.radialDistortion = radialDistortion;
        CameraCalibrationParameters.tangentialDistortion = tangentialDistortion;
        CameraCalibrationParameters.imageWidth = imageWidth;
        CameraCalibrationParameters.imageHeight = imageHeight;
    }

    MediaFrameReaderContext::MediaFrameReaderContext(
        _In_ SensorType sensorType,
        _In_ SpatialPerception^ spatialPerception,
        _In_ DeviceType deviceType,
        _In_opt_ ISensorFrameSink^ sensorFrameSink)
        : _sensorType(sensorType)
        , _spatialPerception(spatialPerception)
        , _deviceType(deviceType)
        , _sensorFrameSink(sensorFrameSink)
    {
    }

    SensorFrame^ MediaFrameReaderContext::GetLatestSensorFrame()
    {
        SensorFrame^ latestSensorFrame;

        {
            std::lock_guard<std::mutex> latestSensorFrameMutexLockGuard(
                _latestSensorFrameMutex);
            latestSensorFrame = _latestSensorFrame;
        }

        return latestSensorFrame;
    }

    void MediaFrameReaderContext::FrameArrived(
        Windows::Media::Capture::Frames::MediaFrameReader^ sender,
        Windows::Media::Capture::Frames::MediaFrameArrivedEventArgs^ args)
    {
        //
        // TryAcquireLatestFrame will return the latest frame that has not yet been acquired.
        // This can return null if there is no such frame, or if the reader is not in the
        // "Started" state. The latter can occur if a FrameArrived event was in flight
        // when the reader was stopped.
        //
        Windows::Media::Capture::Frames::MediaFrameReference^ frame =
            sender->TryAcquireLatestFrame();

        if (nullptr == frame)
        {
            dbg::trace(
                L"MediaFrameReaderContext::FrameArrived: _sensorType=%s (%i), frame is null",
                _sensorType.ToString()->Data(),
                (int32_t)_sensorType);

            return;
        }
        else if (nullptr == frame->VideoMediaFrame)
        {
            dbg::trace(
                L"MediaFrameReaderContext::FrameArrived: _sensorType=%s (%i), frame->VideoMediaFrame is null",
                _sensorType.ToString()->Data(),
                (int32_t)_sensorType);

            return;
        }
        else if (nullptr == frame->VideoMediaFrame->SoftwareBitmap)
        {
            dbg::trace(
                L"MediaFrameReaderContext::FrameArrived: _sensorType=%s (%i), frame->VideoMediaFrame->SoftwareBitmap is null",
                _sensorType.ToString()->Data(),
                (int32_t)_sensorType);

            return;
        }

#if DBG_ENABLE_VERBOSE_LOGGING
        dbg::trace(
            L"MediaFrameReaderContext::FrameArrived: _sensorType=%s (%i), timestamp=%llu (relative)",
            _sensorType.ToString()->Data(),
            (int32_t)_sensorType,
            frame->SystemRelativeTime->Value.Duration);
#endif

        //
        // Convert the system boot relative timestamp of exposure we've received from the media
        // frame reader into the universal time format accepted by the spatial perception APIs.
        //
        Windows::Foundation::DateTime timestamp;

        timestamp.UniversalTime =
            _timeConverter.RelativeTicksToAbsoluteTicks(
                Io::HundredsOfNanoseconds(
                    frame->SystemRelativeTime->Value.Duration)).count();

        //
        // Create a copy of the software bitmap and wrap it up with a SensorFrame.
        //
        // Per MSDN, each MediaFrameReader maintains a circular buffer of MediaFrameReference
        // objects obtained from TryAcquireLatestFrame. After all of the MediaFrameReference
        // objects in the buffer have been used, subsequent calls to TryAcquireLatestFrame will
        // cause the system to call Close (or Dispose in C#) on the oldest buffer object in
        // order to reuse it.
        //
        // Because creating a copy of the software bitmap just in case the app would want to hold
        // onto it is fairly expensive, we will let the application decide whether to make a copy
        // or risk getting the reference to the media frame closed in flight.
        //
        Windows::Graphics::Imaging::SoftwareBitmap^ softwareBitmap =
            frame->VideoMediaFrame->SoftwareBitmap;

        //
        // Finally, wrap all of the above information in a SensorFrame object and pass it
        // down to the sensor frame sink. We'll also retain a reference to the latest sensor
        // frame on this object for immediate consumption by the app.
        //
        SensorFrame^ sensorFrame =
            ref new SensorFrame(_sensorType, timestamp, softwareBitmap);

        //
        // Extract the frame-to-origin transform, if the MFT exposed it.
        // HL1 can access spatial coordinate system from GUID
        bool frameToOriginObtained = false;
        static const Platform::Guid c_MFSampleExtension_Spatial_CameraCoordinateSystem(0x9d13c82f, 0x2199, 0x4e67, 0x91, 0xcd, 0xd1, 0xa4, 0x18, 0x1f, 0x25, 0x34);

        Windows::Perception::Spatial::SpatialCoordinateSystem^ frameCoordinateSystem = nullptr;

        // Has key for spatial coordinate system OR is HL1
        if (frame->Properties->HasKey(c_MFSampleExtension_Spatial_CameraCoordinateSystem) ||
            _deviceType == DeviceType::HL1)
        {
            frameCoordinateSystem = safe_cast<Windows::Perception::Spatial::SpatialCoordinateSystem^>(
                frame->Properties->Lookup(
                    c_MFSampleExtension_Spatial_CameraCoordinateSystem));
        }
        // HL2 support, doesn't require guid to access spatial coordinate system
        // https://github.com/qian256/HoloLensARToolKit/blob/master/HoloLensARToolKit/Assets/ARToolKitUWP/Scripts/ARUWPVideo.cs
        else if (_deviceType == DeviceType::HL2)
        {
            frameCoordinateSystem = safe_cast<Windows::Perception::Spatial::SpatialCoordinateSystem^>(
                frame->CoordinateSystem);
        }

        else
        {
            frameCoordinateSystem = safe_cast<Windows::Perception::Spatial::SpatialCoordinateSystem^>(
                frame->CoordinateSystem);
        }

        if (nullptr != frameCoordinateSystem)
        {
			// Cache the frame coordinate system to sensor frame class
			// https://github.com/chrisfromwork/HoloLensForCV/commit/269d64c4e6bd500cac5c12bd199ea7fde7dc4602
			sensorFrame->FrameCoordinateSystem = frameCoordinateSystem;

            Platform::IBox<Windows::Foundation::Numerics::float4x4>^ frameToOriginReference =
                frameCoordinateSystem->TryGetTransformTo(
                    _spatialPerception->GetOriginFrameOfReference()->CoordinateSystem);

            if (nullptr != frameToOriginReference)
            {
#if DBG_ENABLE_VERBOSE_LOGGING
                Windows::Foundation::Numerics::float4x4 frameToOrigin =
                    frameToOriginReference->Value;
                dbg::trace(
                    L"frameToOrigin=[[%f, %f, %f, %f], [%f, %f, %f, %f], [%f, %f, %f, %f], [%f, %f, %f, %f]]",
                    frameToOrigin.m11, frameToOrigin.m12, frameToOrigin.m13, frameToOrigin.m14,
                    frameToOrigin.m21, frameToOrigin.m22, frameToOrigin.m23, frameToOrigin.m24,
                    frameToOrigin.m31, frameToOrigin.m32, frameToOrigin.m33, frameToOrigin.m34,
                    frameToOrigin.m41, frameToOrigin.m42, frameToOrigin.m43, frameToOrigin.m44);
#endif /* DBG_ENABLE_VERBOSE_LOGGING */

                sensorFrame->FrameToOrigin =
                    frameToOriginReference->Value;

                frameToOriginObtained = true;
            }
        }

        if (!frameToOriginObtained)
        {
            //
            // Set the FrameToOrigin to zero, making it obvious that we do not
            // have a valid pose for this frame.
            //
            Windows::Foundation::Numerics::float4x4 zero;

            memset(
                &zero,
                0 /* _Val */,
                sizeof(zero));

            sensorFrame->FrameToOrigin =
                zero;
        }

        //
        // Extract camera view transform, if the MFT exposed it:
        //
        static const Platform::Guid c_MFSampleExtension_Spatial_CameraViewTransform(
            0x4e251fa4, 0x830f, 0x4770, 0x85, 0x9a, 0x4b, 0x8d, 0x99, 0xaa, 0x80, 0x9b);

        // HL1 OR has accessible GUID for camera view transform
        if (frame->Properties->HasKey(c_MFSampleExtension_Spatial_CameraViewTransform) ||
            _deviceType == DeviceType::HL1)
        {
            Platform::Object^ mfMtUserData =
                frame->Properties->Lookup(c_MFSampleExtension_Spatial_CameraViewTransform);
            Platform::Array<byte>^ cameraViewTransformAsPlatformArray =
                safe_cast<Platform::IBoxArray<byte>^>(mfMtUserData)->Value;
            sensorFrame->CameraViewTransform =
                *reinterpret_cast<Windows::Foundation::Numerics::float4x4*>(
                    cameraViewTransformAsPlatformArray->Data);
        }
            
        // HL2
        else if (_deviceType == DeviceType::HL2)
        {
            // Set the CameraViewTransform to identity as we are not able 
            // to access the camera view transform on HL2
            auto identity = Windows::Foundation::Numerics::float4x4::identity();

            sensorFrame->CameraViewTransform = identity;
        }

        else
        {
            // Set the CameraViewTransform to zero to make it clear
            // that we don't have access
            Windows::Foundation::Numerics::float4x4 zero;

            memset(
                &zero,
                0 /* _Val */,
                sizeof(zero));

            sensorFrame->CameraViewTransform = zero;
        }
#if DBG_ENABLE_VERBOSE_LOGGING
        auto cameraViewTransform = sensorFrame->CameraViewTransform;
        dbg::trace(
            L"cameraViewTransform=[[%f, %f, %f, %f], [%f, %f, %f, %f], [%f, %f, %f, %f], [%f, %f, %f, %f]]",
            cameraViewTransform.m11, cameraViewTransform.m12, cameraViewTransform.m13, cameraViewTransform.m14,
            cameraViewTransform.m21, cameraViewTransform.m22, cameraViewTransform.m23, cameraViewTransform.m24,
            cameraViewTransform.m31, cameraViewTransform.m32, cameraViewTransform.m33, cameraViewTransform.m34,
            cameraViewTransform.m41, cameraViewTransform.m42, cameraViewTransform.m43, cameraViewTransform.m44);
#endif /* DBG_ENABLE_VERBOSE_LOGGING */

        //
        // Extract camera projection transform, if the MFT exposed it:
        //
        static const Platform::Guid c_MFSampleExtension_Spatial_CameraProjectionTransform(
            0x47f9fcb5, 0x2a02, 0x4f26, 0xa4, 0x77, 0x79, 0x2f, 0xdf, 0x95, 0x88, 0x6a);

        // HL1 or has GUID to access camera projection transform
        if (frame->Properties->HasKey(c_MFSampleExtension_Spatial_CameraProjectionTransform) ||
            _deviceType == DeviceType::HL1)
            {
            Platform::Object^ mfMtUserData =
                frame->Properties->Lookup(c_MFSampleExtension_Spatial_CameraProjectionTransform);
            Platform::Array<byte>^ cameraViewTransformAsPlatformArray =
                safe_cast<Platform::IBoxArray<byte>^>(mfMtUserData)->Value;
            
            // Cache the camera projection transform 
            sensorFrame->CameraProjectionTransform =
                *reinterpret_cast<Windows::Foundation::Numerics::float4x4*>(
                    cameraViewTransformAsPlatformArray->Data);
        }

        else if (_deviceType == DeviceType::HL2)
        {
            // Create the camera intrinsics matrix from manual calculations
            auto manualCameraIntrinsics =
                ref new Windows::Media::Devices::Core::CameraIntrinsics(
                    CameraCalibrationParameters.focalLength,
                    CameraCalibrationParameters.principalPoint,
                    CameraCalibrationParameters.radialDistortion,
                    CameraCalibrationParameters.tangentialDistortion,
                    (uint)CameraCalibrationParameters.imageWidth,
                    (uint)CameraCalibrationParameters.imageHeight);

            // Cache to the current sensor frame
            sensorFrame->CoreCameraIntrinsics = manualCameraIntrinsics;
        }

        else
        {
            // Set the CameraProjectionTransform to zero, making it obvious that we do not
            // have a valid pose for this frame.

            Windows::Foundation::Numerics::float4x4 zero;

            memset(
                &zero,
                0 /* _Val */,
                sizeof(zero));

            sensorFrame->CameraProjectionTransform = zero;

        }

#if DBG_ENABLE_VERBOSE_LOGGING
        auto cameraProjectionTransform = sensorFrame->CameraProjectionTransform;
        dbg::trace(
            L"cameraProjectionTransform=[[%f, %f, %f, %f], [%f, %f, %f, %f], [%f, %f, %f, %f], [%f, %f, %f, %f]]",
            cameraProjectionTransform.m11, cameraProjectionTransform.m12, cameraProjectionTransform.m13, cameraProjectionTransform.m14,
            cameraProjectionTransform.m21, cameraProjectionTransform.m22, cameraProjectionTransform.m23, cameraProjectionTransform.m24,
            cameraProjectionTransform.m31, cameraProjectionTransform.m32, cameraProjectionTransform.m33, cameraProjectionTransform.m34,
            cameraProjectionTransform.m41, cameraProjectionTransform.m42, cameraProjectionTransform.m43, cameraProjectionTransform.m44);
#endif /* DBG_ENABLE_VERBOSE_LOGGING */

        //
        // See if the frame comes with HoloLens Sensor Streaming specific intrinsics...
        //
        if (frame->Properties->HasKey(SensorStreaming::MFSampleExtension_SensorStreaming_CameraIntrinsics))
        {
            Microsoft::WRL::ComPtr<SensorStreaming::ICameraIntrinsics> sensorStreamingCameraIntrinsics =
                reinterpret_cast<SensorStreaming::ICameraIntrinsics*>(
                    frame->Properties->Lookup(
                        SensorStreaming::MFSampleExtension_SensorStreaming_CameraIntrinsics));

            //
            // The visible light camera images are grayscale, but packed as 32bpp ARGB images.
            //
            unsigned int imageWidth = softwareBitmap->PixelWidth;

            if ((_sensorType == SensorType::VisibleLightLeftFront) ||
                (_sensorType == SensorType::VisibleLightLeftLeft) ||
                (_sensorType == SensorType::VisibleLightRightFront) ||
                (_sensorType == SensorType::VisibleLightRightRight))
            {
                imageWidth = imageWidth * 4;
            }

            sensorFrame->SensorStreamingCameraIntrinsics =
                ref new CameraIntrinsics(
                    sensorStreamingCameraIntrinsics,
                    imageWidth,
                    softwareBitmap->PixelHeight);
        }
        else
        {
            if (_sensorType != SensorType::PhotoVideo)
            {
                dbg::trace(
                    L"MediaFrameReaderContext::FrameArrived: _sensorType=%s (%i), MFSampleExtension_SensorStreaming_CameraIntrinsics not found!",
                    _sensorType.ToString()->Data(),
                    (int32_t)_sensorType);
            }

            if (_deviceType == DeviceType::HL1)
            {
                sensorFrame->CoreCameraIntrinsics =
                    frame->VideoMediaFrame->CameraIntrinsics;
            }
            
            if (_deviceType == DeviceType::HL2)
            {
                Microsoft::WRL::ComPtr<SensorStreaming::ICameraIntrinsics> sensorStreamingCameraIntrinsics =
                    reinterpret_cast<SensorStreaming::ICameraIntrinsics*>(
                        frame->VideoMediaFrame->CameraIntrinsics);

                sensorFrame->SensorStreamingCameraIntrinsics =
                    ref new CameraIntrinsics(
                        sensorStreamingCameraIntrinsics,
                        softwareBitmap->PixelWidth,
                        softwareBitmap->PixelHeight);
            }
        }

        if (nullptr != _sensorFrameSink)
        {
            _sensorFrameSink->Send(
                sensorFrame);
        }

        {
            std::lock_guard<std::mutex> latestSensorFrameMutexLockGuard(
                _latestSensorFrameMutex);

            _latestSensorFrame = sensorFrame;
        }
    }
}
