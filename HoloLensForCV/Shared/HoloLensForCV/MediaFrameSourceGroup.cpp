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
//#include <opencv2/video/tracking.hpp>

namespace HoloLensForCV
{
    static const Platform::Guid c_MF_MT_USER_DATA(
        0xb6bc765f, 0x4c3b, 0x40a4, 0xbd, 0x51, 0x25, 0x35, 0xb6, 0x6f, 0xe0, 0x9d);

    MediaFrameSourceGroup::MediaFrameSourceGroup(
        _In_ MediaFrameSourceGroupType mediaFrameSourceGroupType,
        _In_ SpatialPerception^ spatialPerception,
        _In_ DeviceType deviceType,
        _In_opt_ ISensorFrameSinkGroup^ optionalSensorFrameSinkGroup,

        // Camera calibration params
        _In_ float fL1, _In_ float fL2,
        _In_ float pP1, _In_ float pP2,
        _In_ float rD1, _In_ float rD2, _In_ float rD3,
        _In_ float tD1, _In_ float tD2,
        _In_ int imageWidth,
        _In_ int imageHeight)
        : _mediaFrameSourceGroupType(mediaFrameSourceGroupType)
        , _spatialPerception(spatialPerception)
        , _deviceType(deviceType)
        , _optionalSensorFrameSinkGroup(optionalSensorFrameSinkGroup)
    {
        Windows::Foundation::Numerics::float2 focalLength(fL1, fL2);
        Windows::Foundation::Numerics::float2 principalPoint(pP1, pP2);
        Windows::Foundation::Numerics::float3 radialDistortion(rD1, rD2, rD3);
        Windows::Foundation::Numerics::float2 tangentialDistortion(tD1, tD2);

        _cameraIntrinsicsAndExtrinsics = ref new CameraIntrinsicsAndExtrinsics();
        _cameraIntrinsicsAndExtrinsics->SetCameraParameters(
            focalLength, principalPoint,
            radialDistortion, tangentialDistortion,
            imageWidth, imageHeight);
    }

    void MediaFrameSourceGroup::EnableAll()
    {
        switch (_mediaFrameSourceGroupType)
        {
        case MediaFrameSourceGroupType::PhotoVideoCamera:
            Enable(SensorType::PhotoVideo);
            break;

#if ENABLE_HOLOLENS_RESEARCH_MODE_SENSORS
        case MediaFrameSourceGroupType::HoloLensResearchModeSensors:
            Enable(SensorType::ShortThrowToFDepth);
            Enable(SensorType::ShortThrowToFReflectivity);
            Enable(SensorType::LongThrowToFDepth);
            Enable(SensorType::LongThrowToFReflectivity);
            Enable(SensorType::VisibleLightLeftLeft);
            Enable(SensorType::VisibleLightLeftFront);
            Enable(SensorType::VisibleLightRightFront);
            Enable(SensorType::VisibleLightRightRight);
            break;
#endif /* ENABLE_HOLOLENS_RESEARCH_MODE_SENSORS */
        }
    }

    void MediaFrameSourceGroup::Enable(
        _In_ SensorType sensorType)
    {
        const int32_t sensorTypeAsIndex =
            (int32_t)sensorType;

        REQUIRES(
            0 <= sensorTypeAsIndex &&
            sensorTypeAsIndex < (int32_t)_enabledFrameReaders.size());

        _enabledFrameReaders[sensorTypeAsIndex] =
            true;
    }

    bool MediaFrameSourceGroup::IsEnabled(
        _In_ SensorType sensorType) const
    {
        const int32_t sensorTypeAsIndex =
            (int32_t)sensorType;

        REQUIRES(
            0 <= sensorTypeAsIndex &&
            sensorTypeAsIndex < (int32_t)_enabledFrameReaders.size());

        return _enabledFrameReaders[sensorTypeAsIndex];
    }

    Windows::Foundation::IAsyncAction^ MediaFrameSourceGroup::StartAsync()
    {
        return concurrency::create_async(
            [this]()
        {
            return InitializeMediaSourceWorkerAsync();
        });
    }

    //// Initialize the kalman filter. Code directly from opencv example
    //// https://docs.opencv.org/master/dc/d2c/tutorial_real_time_pose.html
    //void  MediaFrameSourceGroup::initKalmanFilter(cv::KalmanFilter& KF, int nStates, int nMeasurements, int nInputs, double dt)
    //{
    //    KF.init(nStates, nMeasurements, nInputs, CV_64F);                 // init Kalman Filter
    //    cv::setIdentity(KF.processNoiseCov, cv::Scalar::all(1e-5));       // set process noise
    //    cv::setIdentity(KF.measurementNoiseCov, cv::Scalar::all(1e-4));   // set measurement noise
    //    cv::setIdentity(KF.errorCovPost, cv::Scalar::all(1));             // error covariance
    //    /* DYNAMIC MODEL */
    //    //  [1 0 0 dt  0  0 dt2   0   0 0 0 0  0  0  0   0   0   0]
    //    //  [0 1 0  0 dt  0   0 dt2   0 0 0 0  0  0  0   0   0   0]
    //    //  [0 0 1  0  0 dt   0   0 dt2 0 0 0  0  0  0   0   0   0]
    //    //  [0 0 0  1  0  0  dt   0   0 0 0 0  0  0  0   0   0   0]
    //    //  [0 0 0  0  1  0   0  dt   0 0 0 0  0  0  0   0   0   0]
    //    //  [0 0 0  0  0  1   0   0  dt 0 0 0  0  0  0   0   0   0]
    //    //  [0 0 0  0  0  0   1   0   0 0 0 0  0  0  0   0   0   0]
    //    //  [0 0 0  0  0  0   0   1   0 0 0 0  0  0  0   0   0   0]
    //    //  [0 0 0  0  0  0   0   0   1 0 0 0  0  0  0   0   0   0]
    //    //  [0 0 0  0  0  0   0   0   0 1 0 0 dt  0  0 dt2   0   0]
    //    //  [0 0 0  0  0  0   0   0   0 0 1 0  0 dt  0   0 dt2   0]
    //    //  [0 0 0  0  0  0   0   0   0 0 0 1  0  0 dt   0   0 dt2]
    //    //  [0 0 0  0  0  0   0   0   0 0 0 0  1  0  0  dt   0   0]
    //    //  [0 0 0  0  0  0   0   0   0 0 0 0  0  1  0   0  dt   0]
    //    //  [0 0 0  0  0  0   0   0   0 0 0 0  0  0  1   0   0  dt]
    //    //  [0 0 0  0  0  0   0   0   0 0 0 0  0  0  0   1   0   0]
    //    //  [0 0 0  0  0  0   0   0   0 0 0 0  0  0  0   0   1   0]
    //    //  [0 0 0  0  0  0   0   0   0 0 0 0  0  0  0   0   0   1]
    //    // position
    //    KF.transitionMatrix.at<double>(0, 3) = dt;
    //    KF.transitionMatrix.at<double>(1, 4) = dt;
    //    KF.transitionMatrix.at<double>(2, 5) = dt;
    //    KF.transitionMatrix.at<double>(3, 6) = dt;
    //    KF.transitionMatrix.at<double>(4, 7) = dt;
    //    KF.transitionMatrix.at<double>(5, 8) = dt;
    //    KF.transitionMatrix.at<double>(0, 6) = 0.5 * pow(dt, 2);
    //    KF.transitionMatrix.at<double>(1, 7) = 0.5 * pow(dt, 2);
    //    KF.transitionMatrix.at<double>(2, 8) = 0.5 * pow(dt, 2);
    //    // orientation
    //    KF.transitionMatrix.at<double>(9, 12) = dt;
    //    KF.transitionMatrix.at<double>(10, 13) = dt;
    //    KF.transitionMatrix.at<double>(11, 14) = dt;
    //    KF.transitionMatrix.at<double>(12, 15) = dt;
    //    KF.transitionMatrix.at<double>(13, 16) = dt;
    //    KF.transitionMatrix.at<double>(14, 17) = dt;
    //    KF.transitionMatrix.at<double>(9, 15) = 0.5 * pow(dt, 2);
    //    KF.transitionMatrix.at<double>(10, 16) = 0.5 * pow(dt, 2);
    //    KF.transitionMatrix.at<double>(11, 17) = 0.5 * pow(dt, 2);
    //    /* MEASUREMENT MODEL */
    //   //  [1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]
    //   //  [0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]
    //   //  [0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]
    //   //  [0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0]
    //   //  [0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0]
    //   //  [0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0]
    //    KF.measurementMatrix.at<double>(0, 0) = 1;  // x
    //    KF.measurementMatrix.at<double>(1, 1) = 1;  // y
    //    KF.measurementMatrix.at<double>(2, 2) = 1;  // z
    //    KF.measurementMatrix.at<double>(3, 9) = 1;  // roll
    //    KF.measurementMatrix.at<double>(4, 10) = 1; // pitch
    //    KF.measurementMatrix.at<double>(5, 11) = 1; // yaw
    //}

    //void MediaFrameSourceGroup::fillMeasurements(cv::Mat& measurements,
    //    const cv::Mat& translation_measured, const cv::Mat& rotation_measured)
    //{
    //    // Convert rotation matrix to euler angles
    //    cv::Mat measured_eulers(3, 1, CV_64F);
    //    cv::Rodrigues(rotation_measured, measured_eulers);
    //    //measured_eulers = rot2euler(rotation_measured);
    //    // Set measurement to predict
    //    measurements.at<double>(0) = translation_measured.at<double>(0); // x
    //    measurements.at<double>(1) = translation_measured.at<double>(1); // y
    //    measurements.at<double>(2) = translation_measured.at<double>(2); // z
    //    measurements.at<double>(3) = measured_eulers.at<double>(0);      // roll
    //    measurements.at<double>(4) = measured_eulers.at<double>(1);      // pitch
    //    measurements.at<double>(5) = measured_eulers.at<double>(2);      // yaw
    //}

    //void MediaFrameSourceGroup::updateKalmanFilter(cv::KalmanFilter& KF, cv::Mat& measurement,
    //    cv::Mat& translation_estimated, cv::Mat& rotation_estimated)
    //{
    //    // First predict, to update the internal statePre variable
    //    cv::Mat prediction = KF.predict();
    //    // The "correct" phase that is going to use the predicted value and our measurement
    //    cv::Mat estimated = KF.correct(measurement);
    //    // Estimated translation
    //    translation_estimated.at<double>(0) = estimated.at<double>(0);
    //    translation_estimated.at<double>(1) = estimated.at<double>(1);
    //    translation_estimated.at<double>(2) = estimated.at<double>(2);
    //    // Estimated euler angles
    //    cv::Mat eulers_estimated(3, 1, CV_64F);
    //    eulers_estimated.at<double>(0) = estimated.at<double>(9);
    //    eulers_estimated.at<double>(1) = estimated.at<double>(10);
    //    eulers_estimated.at<double>(2) = estimated.at<double>(11);
    //    // Convert estimated quaternion to rotation matrix
    //    cv::Rodrigues(eulers_estimated, rotation_estimated);
    //    //rotation_estimated = euler2rot(eulers_estimated);
    //}

    ///
    /// Control the ArUco marker tracker class. Instantiate class object with 
    /// initial parameters.
    /// 
    Windows::Foundation::IAsyncAction^ MediaFrameSourceGroup::StartArUcoMarkerTrackerAsync(
        float markerSize,
        int dictId,
        Windows::Perception::Spatial::SpatialCoordinateSystem^ unitySpatialCoordinateSystem)
    {
        // Initialize the Kalman filter
        //initKalmanFilter(_KF, _nStates, _nMeasurements, _nInputs, _dt);    // init function

        // Instantiate aruco marker tracker class with parameters.
        return concurrency::create_async(
            [this, markerSize, dictId, unitySpatialCoordinateSystem]()
        {
            _arUcoMarkerTracker = ref new ArUcoMarkerTracker(markerSize, dictId, unitySpatialCoordinateSystem);
        });
    }

    ///
    /// Get the current sensor frame and process using aruco libary. Return a vector of 
    /// detected markers across the application boundary to the C# environment.
    ///
    Windows::Foundation::Collections::IVector<DetectedArUcoMarker^>^
    //void 
        MediaFrameSourceGroup::DetectArUcoMarkers(SensorType type)
    {
        // Get the current sensor frame from media frame source group
        SensorFrame^ frame = GetLatestSensorFrame(type);

        // Process the sensor frame using aruco marker tracker class
        auto detections = _arUcoMarkerTracker->DetectArUcoMarkersInFrame(frame);
        //_detections = _arUcoMarkerTracker->DetectArUcoMarkersInFrame(frame);

        //// Filter the detections using Kalman filter
        //// TODO: integrate into ArUcoMarkerTracker class
        //for each (auto detection in detections)
        //{
        //    cv::Mat measurements;
        //    cv::Mat translation_measured(3, 1, CV_64F);
        //    cv::Mat rotation_measured(3, 1, CV_64F);
        //    cv::Mat rotation_measured_mat(3, 3, CV_64F);

        //    translation_measured.at<double>(0, 0) = (double)detection->Position.x;
        //    translation_measured.at<double>(1, 0) = (double)detection->Position.y;
        //    translation_measured.at<double>(2, 0) = (double)detection->Position.z;

        //    // Euler rotation
        //    rotation_measured.at<double>(0, 0) = (double)detection->Rotation.x;
        //    rotation_measured.at<double>(1, 0) = (double)detection->Rotation.y;
        //    rotation_measured.at<double>(2, 0) = (double)detection->Rotation.z;

        //    cv::Rodrigues(rotation_measured, rotation_measured_mat);
        //    fillMeasurements(measurements, translation_measured, rotation_measured_mat);

        //    // Instantiate estimated translation and rotation
        //    cv::Mat translation_estimated(3, 1, CV_64F);
        //    cv::Mat rotation_estimated(3, 3, CV_64F);
        //    cv::Mat rotation_estimated_euler(3, 1, CV_64F);

        //    // update the Kalman filter with good measurements
        //    updateKalmanFilter(_KF, measurements, translation_estimated, rotation_estimated);

        //    detection->Position = Windows::Foundation::Numerics::float3(
        //        (float)translation_estimated.at<double>(0,0),
        //        (float)translation_estimated.at<double>(1,0),
        //        (float)translation_estimated.at<double>(2,0));

        //    // Convert to euler representation
        //    cv::Rodrigues(rotation_measured, rotation_estimated_euler);
        //    detection->Rotation = Windows::Foundation::Numerics::float3(
        //        (float)rotation_estimated_euler.at<double>(0, 0),
        //        (float)rotation_estimated_euler.at<double>(1, 0),
        //        (float)rotation_estimated_euler.at<double>(2, 0));
        //}

        return detections;
    }

    /// <summary>
    /// Return the cached aruco detections.
    /// </summary>
    /// <returns></returns>
    //Windows::Foundation::Collections::IVector<DetectedArUcoMarker^>^ MediaFrameSourceGroup::GetArUcoDetections()
    //{
    //    return _detections;
    //}

    Windows::Foundation::IAsyncAction^ MediaFrameSourceGroup::StopAsync()
    {
        return concurrency::create_async(
            [this]()
        {
            return CleanupMediaCaptureAsync();
        });
    }

    SensorFrame^ MediaFrameSourceGroup::GetLatestSensorFrame(
        SensorType sensorType)
    {
        const int32_t sensorTypeAsIndex =
            (int32_t)sensorType;

        REQUIRES(
            0 <= sensorTypeAsIndex &&
            sensorTypeAsIndex < (int32_t)_frameReaders.size());

        if (_frameReaders[sensorTypeAsIndex] == nullptr)
        {
            return nullptr;
        }

        return _frameReaders[sensorTypeAsIndex]->GetLatestSensorFrame();
    }

    Concurrency::task<void> MediaFrameSourceGroup::InitializeMediaSourceWorkerAsync()
    {
        return CleanupMediaCaptureAsync()
            .then([this]()
        {
            return Concurrency::create_task(
                Windows::Media::Capture::Frames::MediaFrameSourceGroup::FindAllAsync());

        }, Concurrency::task_continuation_context::get_current_winrt_context())
            .then([this](Windows::Foundation::Collections::IVectorView<Windows::Media::Capture::Frames::MediaFrameSourceGroup^>^ sourceGroups)
        {
            Windows::Media::Capture::Frames::MediaFrameSourceGroup^ selectedSourceGroup;

            for (Windows::Media::Capture::Frames::MediaFrameSourceGroup^ sourceGroup : sourceGroups)
            {
                const wchar_t* sourceGroupDisplayName =
                    sourceGroup->DisplayName->Data();

                dbg::trace(
                    L"MediaFrameSourceGroup::InitializeMediaSourceWorkerAsync: source group display name: %s", sourceGroupDisplayName);

                //
                // Note: this is the display name of the media frame source group associated
                // with the photo/video camera (or, RGB camera) on HoloLens Development Edition.
                //
                const wchar_t* c_HoloLensDevelopmentEditionPhotoVideoSourceGroupDisplayName =
                    L"MN34150";

                const wchar_t* c_HoloLensResearchModeSensorStreamingGroupDisplayName =
                    L"Sensor Streaming";

                const wchar_t* c_HoloLens2PhotoVideoSourceGroupDisplayName =
                    L"QC Back Camera";

                //
                // HoloLens 2: QC Back Camera is available. 
                // Source group: QC Back Camera
                // Frame Source: Color VideoPreview
                // Media Format: Video, NV12, 896 x 504, 30 fps
                //

                // Include the HoloLens 2 display name
                if (MediaFrameSourceGroupType::PhotoVideoCamera == _mediaFrameSourceGroupType &&
                    (0 == wcscmp(c_HoloLensDevelopmentEditionPhotoVideoSourceGroupDisplayName, sourceGroupDisplayName) ||
                        0 == wcscmp(c_HoloLens2PhotoVideoSourceGroupDisplayName, sourceGroupDisplayName)))
                {
#if DBG_ENABLE_INFORMATIONAL_LOGGING
                    dbg::trace(
                        L"MediaFrameSourceGroup::InitializeMediaSourceWorkerAsync: found the photo-video media frame source group.");
#endif /* DBG_ENABLE_INFORMATIONAL_LOGGING */

                    selectedSourceGroup =
                        sourceGroup;

                    break;
                }
#if ENABLE_HOLOLENS_RESEARCH_MODE_SENSORS
                else if (MediaFrameSourceGroupType::HoloLensResearchModeSensors == _mediaFrameSourceGroupType &&
                    (0 == wcscmp(c_HoloLensResearchModeSensorStreamingGroupDisplayName, sourceGroupDisplayName)))
                {
#if DBG_ENABLE_INFORMATIONAL_LOGGING
                    dbg::trace(
                        L"MediaFrameSourceGroup::InitializeMediaSourceWorkerAsync: found the HoloLens Sensor Streaming media frame source group.");
#endif /* DBG_ENABLE_INFORMATIONAL_LOGGING */

                    selectedSourceGroup =
                        sourceGroup;

                    break;
                }
#endif /* ENABLE_HOLOLENS_RESEARCH_MODE_SENSORS */
            }

            if (nullptr == selectedSourceGroup)
            {
#if DBG_ENABLE_INFORMATIONAL_LOGGING
                dbg::trace(
                    L"MediaFrameSourceGroup::InitializeMediaSourceWorkerAsync: selected media frame source group not found.");
#endif /* DBG_ENABLE_INFORMATIONAL_LOGGING */

                return Concurrency::task_from_result();
            }

            //
            // Initialize MediaCapture with the selected group.
            //
            return TryInitializeMediaCaptureAsync(selectedSourceGroup)
                .then([this, selectedSourceGroup](bool initialized)
            {
                if (!initialized)
                {
                    return CleanupMediaCaptureAsync();
                }

                //
                // Set up frame readers, register event handlers and start streaming.
                //
                auto startedSensors =
                    std::make_shared<std::unordered_set<SensorType, SensorTypeHash>>();

                Concurrency::task<void> createReadersTask =
                    Concurrency::task_from_result();

#if DBG_ENABLE_INFORMATIONAL_LOGGING
                dbg::trace(
                    L"MediaFrameSourceGroup::InitializeMediaSourceWorkerAsync: selected group has %i media frame sources",
                    _mediaCapture->FrameSources->Size);
#endif /* DBG_ENABLE_INFORMATIONAL_LOGGING */

                for (Windows::Foundation::Collections::IKeyValuePair<Platform::String^, Windows::Media::Capture::Frames::MediaFrameSource^>^ kvp : _mediaCapture->FrameSources)
                {
                    Windows::Media::Capture::Frames::MediaFrameSource^ source =
                        kvp->Value;

                    createReadersTask = createReadersTask.then([this, startedSensors, source]()
                    {
                        SensorType sensorType =
                            GetSensorType(
                                source);

                        if (SensorType::Undefined == sensorType)
                        {
                            //
                            // We couldn't map the source to a Research Mode sensor type. Ignore this source.
                            //
#if DBG_ENABLE_INFORMATIONAL_LOGGING
                            dbg::trace(
                                L"MediaFrameSourceGroup::InitializeMediaSourceWorkerAsync: could not map the media frame source to a Research Mode sensor type!");
#endif /* DBG_ENABLE_INFORMATIONAL_LOGGING */

                            return Concurrency::task_from_result();
                        }
                        else if (startedSensors->find(sensorType) != startedSensors->end())
                        {
                            //
                            // We couldn't map the source to a Research Mode sensor type. Ignore this source.
                            //
#if DBG_ENABLE_INFORMATIONAL_LOGGING
                            dbg::trace(
                                L"MediaFrameSourceGroup::InitializeMediaSourceWorkerAsync: sensor type %s has already been initialized!",
                                sensorType.ToString());
#endif /* DBG_ENABLE_INFORMATIONAL_LOGGING */

                            return Concurrency::task_from_result();
                        }
                        else if (!IsEnabled(sensorType))
                        {
                            //
                            // The sensor type was not explicitly enabled by user. Ignore this source.
                            //
#if DBG_ENABLE_INFORMATIONAL_LOGGING
                            dbg::trace(
                                L"MediaFrameSourceGroup::InitializeMediaSourceWorkerAsync: sensor type %s has not been enabled!",
                                sensorType.ToString());
#endif /* DBG_ENABLE_INFORMATIONAL_LOGGING */

                            return Concurrency::task_from_result();
                        }

                        //
                        // Look for a format which the FrameRenderer can render.
                        //
                        Platform::String^ requestedSubtype =
                            nullptr;

                        auto found =
                            std::find_if(
                                begin(source->SupportedFormats),
                                end(source->SupportedFormats),
                                [&](Windows::Media::Capture::Frames::MediaFrameFormat^ format)
                        {
                            requestedSubtype =
                                GetSubtypeForFrameReader(
                                    source->Info->SourceKind,
                                    format);

                            return requestedSubtype != nullptr;
                        });

                        if (requestedSubtype == nullptr)
                        {
                            //
                            // No acceptable format was found. Ignore this source.
                            //
                            return Concurrency::task_from_result();
                        }

                        //
                        // Tell the source to use the format we can render.
                        //
                        return Concurrency::create_task(
                            source->SetFormatAsync(*found))
                            .then([this, source, requestedSubtype]()
                        {
                            return Concurrency::create_task(
                                _mediaCapture->CreateFrameReaderAsync(
                                    source,
                                    requestedSubtype));

                        }, Concurrency::task_continuation_context::get_current_winrt_context())
                            .then([this, sensorType](Windows::Media::Capture::Frames::MediaFrameReader^ frameReader)
                        {
                            ISensorFrameSink^ optionalSensorFrameSink =
                                nullptr != _optionalSensorFrameSinkGroup
                                ? _optionalSensorFrameSinkGroup->GetSensorFrameSink(
                                    sensorType)
                                : nullptr;

                            MediaFrameReaderContext^ frameReaderContext =
                                ref new MediaFrameReaderContext(
                                    sensorType,
                                    _spatialPerception,
                                    _deviceType,
                                    optionalSensorFrameSink);

                            _frameReaders[(int32_t)sensorType] =
                                frameReaderContext;

                            Windows::Foundation::EventRegistrationToken token =
                                frameReader->FrameArrived +=
                                ref new Windows::Foundation::TypedEventHandler<
                                Windows::Media::Capture::Frames::MediaFrameReader^,
                                Windows::Media::Capture::Frames::MediaFrameArrivedEventArgs^>(
                                    frameReaderContext,
                                    &MediaFrameReaderContext::FrameArrived);

                            //
                            // Keep track of created reader and event handler so it can be stopped later.
                            //
                            _frameEventRegistrations.push_back(
                                std::make_pair(
                                    frameReader,
                                    token));

#if DBG_ENABLE_INFORMATIONAL_LOGGING
                            dbg::trace(
                                L"MediaFrameSourceGroup::InitializeMediaSourceWorkerAsync: created the '%s' frame reader",
                                sensorType.ToString()->Data());
#endif /* DBG_ENABLE_INFORMATIONAL_LOGGING */

                            return Concurrency::create_task(
                                frameReader->StartAsync());

                        }, Concurrency::task_continuation_context::get_current_winrt_context())
                            .then([this, sensorType, startedSensors](Windows::Media::Capture::Frames::MediaFrameReaderStartStatus status)
                        {
                            if (status == Windows::Media::Capture::Frames::MediaFrameReaderStartStatus::Success)
                            {
#if DBG_ENABLE_INFORMATIONAL_LOGGING
                                dbg::trace(
                                    L"MediaFrameSourceGroup::InitializeMediaSourceWorkerAsync: started the '%s' frame reader",
                                    sensorType.ToString()->Data());
#endif /* DBG_ENABLE_INFORMATIONAL_LOGGING */

                                startedSensors->insert(
                                    sensorType);
                            }
                            else
                            {
#if DBG_ENABLE_ERROR_LOGGING
                                dbg::trace(
                                    L"MediaFrameSourceGroup::InitializeMediaSourceWorkerAsync: unable to start the '%s' frame reader. Error: %s",
                                    sensorType.ToString()->Data(),
                                    status.ToString()->Data());
#endif /* DBG_ENABLE_ERROR_LOGGING */
                            }

                        }, Concurrency::task_continuation_context::get_current_winrt_context());

                    }, Concurrency::task_continuation_context::get_current_winrt_context());
                }

                //
                // Run the loop and see if any sources were used.
                //
                return createReadersTask.then([this, startedSensors, selectedSourceGroup]()
                {
                    if (startedSensors->size() == 0)
                    {
#if DBG_ENABLE_INFORMATIONAL_LOGGING
                        dbg::trace(
                            L"MediaFrameSourceGroup::InitializeMediaSourceWorkerAsync: no eligible sources in '%s'",
                            selectedSourceGroup->DisplayName->Data());
#endif /* DBG_ENABLE_INFORMATIONAL_LOGGING */
                    }

                }, Concurrency::task_continuation_context::get_current_winrt_context());

            }, Concurrency::task_continuation_context::get_current_winrt_context());

        }, Concurrency::task_continuation_context::get_current_winrt_context());
    }

    SensorType MediaFrameSourceGroup::GetSensorType(
        Windows::Media::Capture::Frames::MediaFrameSource^ source)
    {
        //
        // First check if the request is concerning the PV camera.
        //
        if (MediaFrameSourceGroupType::PhotoVideoCamera == _mediaFrameSourceGroupType)
        {
#if DBG_ENABLE_INFORMATIONAL_LOGGING
            dbg::trace(
                L"MediaFrameSourceGroup::GetSensorType:: assuming SensorType::PhotoVideo per _mediaFrameSourceGroupType check (source id is '%s')",
                source->Info->Id->Data());
#endif /* DBG_ENABLE_INFORMATIONAL_LOGGING */

            return SensorType::PhotoVideo;
        }

        //
        // The sensor streaming DMFT exposes the sensor names through the MF_MT_USER_DATA
        // property (GUID for that property is {b6bc765f-4c3b-40a4-bd51-2535b66fe09d}).
        //
        if (!source->Info->Properties->HasKey(c_MF_MT_USER_DATA))
        {
#if DBG_ENABLE_INFORMATIONAL_LOGGING
            dbg::trace(
                L"MediaFrameSourceGroup::GetSensorType:: assuming SensorType::Undefined given missing MF_MT_USER_DATA");
#endif /* DBG_ENABLE_INFORMATIONAL_LOGGING */

            return SensorType::Undefined;
        }

        Platform::Object^ mfMtUserData =
            source->Info->Properties->Lookup(
                c_MF_MT_USER_DATA);

        Platform::Array<byte>^ sensorNameAsPlatformArray =
            safe_cast<Platform::IBoxArray<byte>^>(
                mfMtUserData)->Value;

        const wchar_t* sensorName =
            reinterpret_cast<wchar_t*>(
                sensorNameAsPlatformArray->Data);

#if DBG_ENABLE_INFORMATIONAL_LOGGING
        dbg::trace(
            L"MediaFrameSourceGroup::GetSensorType:: found sensor name '%s' in MF_MT_USER_DATA (blob has %i bytes)",
            sensorName,
            sensorNameAsPlatformArray->Length);
#endif /* DBG_ENABLE_INFORMATIONAL_LOGGING */

#if ENABLE_HOLOLENS_RESEARCH_MODE_SENSORS
        if (0 == wcscmp(sensorName, L"Short Throw ToF Depth"))
        {
            return SensorType::ShortThrowToFDepth;
        }
        else if (0 == wcscmp(sensorName, L"Short Throw ToF Reflectivity"))
        {
            return SensorType::ShortThrowToFReflectivity;
        }
        if (0 == wcscmp(sensorName, L"Long Throw ToF Depth"))
        {
            return SensorType::LongThrowToFDepth;
        }
        else if (0 == wcscmp(sensorName, L"Long Throw ToF Reflectivity"))
        {
            return SensorType::LongThrowToFReflectivity;
        }
        else if (0 == wcscmp(sensorName, L"Visible Light Left-Left"))
        {
            return SensorType::VisibleLightLeftLeft;
        }
        else if (0 == wcscmp(sensorName, L"Visible Light Left-Front"))
        {
            return SensorType::VisibleLightLeftFront;
        }
        else if (0 == wcscmp(sensorName, L"Visible Light Right-Front"))
        {
            return SensorType::VisibleLightRightFront;
        }
        else if (0 == wcscmp(sensorName, L"Visible Light Right-Right"))
        {
            return SensorType::VisibleLightRightRight;
        }
        else
#endif /* ENABLE_HOLOLENS_RESEARCH_MODE_SENSORS */
        {
#if DBG_ENABLE_INFORMATIONAL_LOGGING
            dbg::trace(
                L"MediaFrameSourceGroup::GetSensorType:: could not match sensor name to SensorType enumeration");
#endif /* DBG_ENABLE_INFORMATIONAL_LOGGING */

            return SensorType::Undefined;
        }
    }

    Platform::String^ MediaFrameSourceGroup::GetSubtypeForFrameReader(
        Windows::Media::Capture::Frames::MediaFrameSourceKind kind,
        Windows::Media::Capture::Frames::MediaFrameFormat^ format)
    {
        //
        // Note that media encoding subtypes may differ in case.
        // https://docs.microsoft.com/en-us/uwp/api/Windows.Media.MediaProperties.MediaEncodingSubtypes
        //
        switch (kind)
        {

        case Windows::Media::Capture::Frames::MediaFrameSourceKind::Color:

            // Force set the media stream to the desired format
            // Ensure we select the desired video stream, check width and height
            // MediaFrameSourceInfo->Source->Profile  Width : 896, Height : 504, FrameRate : 29.970030
            // Force the lowest resolution for streaming. TODO: make this something that can be selected.
            if (format->VideoFormat->Width == 896 && format->VideoFormat->Height == 504)
            //if (true)
            {
#if DBG_ENABLE_INFORMATIONAL_LOGGING
                dbg::trace(
                    L"MediaFrameSourceGroup::GetSubtypeForFrameReader: evaluating MediaFrameSourceKind::Color with format %s-%s @%i/%iHz and resolution %i x %i",
                    format->MajorType->Data(),
                    format->Subtype->Data(),
                    format->FrameRate->Numerator,
                    format->FrameRate->Denominator,
                    format->VideoFormat->Width,
                    format->VideoFormat->Height);
#endif /* DBG_ENABLE_INFORMATIONAL_LOGGING */

                //
                // For color sources, we accept anything and request that it be converted to Bgra8.
                //
                return Windows::Media::MediaProperties::MediaEncodingSubtypes::Bgra8;
            }


#if ENABLE_HOLOLENS_RESEARCH_MODE_SENSORS
        case Windows::Media::Capture::Frames::MediaFrameSourceKind::Depth:
        {
            if (MediaFrameSourceGroupType::HoloLensResearchModeSensors == _mediaFrameSourceGroupType)
            {
                //
                // The only depth format we can render is D16.
                //
                dbg::trace(
                    L"MediaFrameSourceGroup::GetSubtypeForFrameReader: evaluating MediaFrameSourceKind::Depth with format %s-%s @%i/%iHz",
                    format->MajorType->Data(),
                    format->Subtype->Data(),
                    format->FrameRate->Numerator,
                    format->FrameRate->Denominator);

                const bool isD16 =
                    CompareStringOrdinal(
                        format->Subtype->Data(),
                        -1 /* cchCount1 */,
                        Windows::Media::MediaProperties::MediaEncodingSubtypes::D16->Data(),
                        -1 /* cchCount2 */,
                        TRUE /* bIgnoreCase */) == CSTR_EQUAL;

                return isD16 ? format->Subtype : nullptr;
            }
            else
            {
                return nullptr;
            }
        }

        case Windows::Media::Capture::Frames::MediaFrameSourceKind::Infrared:
        {
            if (MediaFrameSourceGroupType::HoloLensResearchModeSensors == _mediaFrameSourceGroupType)
            {
                //
                // The only infrared formats we can render are L8 and L16.
                //
                dbg::trace(
                    L"MediaFrameSourceGroup::GetSubtypeForFrameReader: evaluating MediaFrameSourceKind::Infrared with format %s-%s @%i/%iHz",
                    format->MajorType->Data(),
                    format->Subtype->Data(),
                    format->FrameRate->Numerator,
                    format->FrameRate->Denominator);

                const bool isL8 =
                    CompareStringOrdinal(
                        format->Subtype->Data(),
                        -1 /* cchCount1 */,
                        Windows::Media::MediaProperties::MediaEncodingSubtypes::L8->Data(),
                        -1 /* cchCount2 */,
                        TRUE /* bIgnoreCase */) == CSTR_EQUAL;

                const bool isL16 =
                    CompareStringOrdinal(
                        format->Subtype->Data(),
                        -1 /* cchCount1 */,
                        Windows::Media::MediaProperties::MediaEncodingSubtypes::L16->Data(),
                        -1 /* cchCount2 */,
                        TRUE /* bIgnoreCase */) == CSTR_EQUAL;

                return (isL8 || isL16) ? format->Subtype : nullptr;
            }
            else
            {
                return nullptr;
            }
        }
#endif /* ENABLE_HOLOLENS_RESEARCH_MODE_SENSORS */

        default:
            //
            // No other source kinds are supported by this class.
            //
            return nullptr;
        }
    }

    Concurrency::task<bool> MediaFrameSourceGroup::TryInitializeMediaCaptureAsync(
        Windows::Media::Capture::Frames::MediaFrameSourceGroup^ group)
    {
        if (_mediaCapture != nullptr)
        {
            //
            // Already initialized.
            //
            return Concurrency::task_from_result(true);
        }

        //
        // Initialize media capture with the source group.
        //
        _mediaCapture =
            ref new Windows::Media::Capture::MediaCapture();

        auto settings =
            ref new Windows::Media::Capture::MediaCaptureInitializationSettings();

        //
        // Select the source we will be reading from.
        //
        settings->SourceGroup =
            group;

        //
        // This media capture can share streaming with other apps.
        //

        // For HL1
        if (_deviceType == DeviceType::HL1)
        {
            settings->SharingMode =
                Windows::Media::Capture::MediaCaptureSharingMode::SharedReadOnly;
        }
        // For HL2
        if (_deviceType == DeviceType::HL2)
        {
            settings->SharingMode =
                Windows::Media::Capture::MediaCaptureSharingMode::ExclusiveControl;
        }

        //
        // Only stream video and don't initialize audio capture devices.
        //
        settings->StreamingCaptureMode =
            Windows::Media::Capture::StreamingCaptureMode::Video;

        //
        // Set to CPU to ensure frames always contain CPU SoftwareBitmap images,
        // instead of preferring GPU D3DSurface images.
        //
        settings->MemoryPreference =
            Windows::Media::Capture::MediaCaptureMemoryPreference::Cpu;

        //
        // Only stream video and don't initialize audio capture devices.
        //
        settings->StreamingCaptureMode =
            Windows::Media::Capture::StreamingCaptureMode::Video;

        //
        // Initialize MediaCapture with the specified group.
        // This must occur on the UI thread because some device families
        // (such as Xbox) will prompt the user to grant consent for the
        // app to access cameras.
        // This can raise an exception if the source no longer exists,
        // or if the source could not be initialized.
        //
        return Concurrency::create_task(
            _mediaCapture->InitializeAsync(
                settings))
            .then([this](Concurrency::task<void> initializeMediaCaptureTask)
        {
            try
            {
                //
                // Get the result of the initialization. This call will throw if initialization failed
                // This pattern is documented at https://msdn.microsoft.com/en-us/library/dd997692.aspx
                //
                initializeMediaCaptureTask.get();

#if DBG_ENABLE_INFORMATIONAL_LOGGING
                dbg::trace(
                    L"MediaFrameSourceGroup::TryInitializeMediaCaptureAsync: MediaCapture is successfully initialized in shared mode.");
#endif /* DBG_ENABLE_INFORMATIONAL_LOGGING */

                return true;
            }
            catch (Platform::Exception^ exception)
            {
#if DBG_ENABLE_ERROR_LOGGING
                dbg::trace(
                    L"MediaFrameSourceGroup::TryInitializeMediaCaptureAsync: failed to initialize media capture: %s",
                    exception->Message->Data());
#endif /* DBG_ENABLE_ERROR_LOGGING */

                return false;
            }
        });
    }

    Concurrency::task<void> MediaFrameSourceGroup::CleanupMediaCaptureAsync()
    {
        Concurrency::task<void> cleanupTask =
            Concurrency::task_from_result();

        if (_mediaCapture != nullptr)
        {
            for (auto& readerAndToken : _frameEventRegistrations)
            {
                Windows::Media::Capture::Frames::MediaFrameReader^ reader =
                    readerAndToken.first;

                Windows::Foundation::EventRegistrationToken token =
                    readerAndToken.second;

                reader->FrameArrived -= token;

                cleanupTask =
                    cleanupTask &&
                    Concurrency::create_task(
                        reader->StopAsync());
            }

            _frameEventRegistrations.clear();

            _mediaCapture = nullptr;
        }

        return cleanupTask;
    }
}
