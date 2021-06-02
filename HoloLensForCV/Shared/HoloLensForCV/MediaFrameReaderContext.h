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

#pragma once
#include "DeviceType.h"


namespace HoloLensForCV
{
    //
    // Receives media frames from the MediaFrameReader
    // and exposes them as sensor frames to the app.
    //
    public ref class MediaFrameReaderContext sealed
    {
    public:
        MediaFrameReaderContext(
            _In_ SensorType sensorType,
            _In_ SpatialPerception^ spatialPerception,
            _In_ DeviceType deviceType,
            _In_opt_ ISensorFrameSink^ sensorFrameSink);

        SensorFrame^ GetLatestSensorFrame();

        /// <summary>
        /// Handler for frames which arrive from the MediaFrameReader.
        /// </summary>
        void FrameArrived(
            Windows::Media::Capture::Frames::MediaFrameReader^ sender,
            Windows::Media::Capture::Frames::MediaFrameArrivedEventArgs^ args);

    private:
        SensorType _sensorType;
        SpatialPerception^ _spatialPerception;
        ISensorFrameSink^ _sensorFrameSink;
        DeviceType _deviceType;

        Io::TimeConverter _timeConverter;

        std::mutex _latestSensorFrameMutex;
        SensorFrame^ _latestSensorFrame;
    };

    public ref class CameraIntrinsicsAndExtrinsics sealed
    {
    public:
        void SetCameraParameters(
            Windows::Foundation::Numerics::float2 focalLength,
            Windows::Foundation::Numerics::float2 principalPoint,
            Windows::Foundation::Numerics::float3 radialDistortion,
            Windows::Foundation::Numerics::float2 tangentialDistortion,
            int imageWidth,
            int imageHeight);
    };
}
