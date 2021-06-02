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
#include "DetectedArUcoMarker.h"
#include "ArUcoMarkerTracker.h"
#include "DeviceType.h"
//#include <opencv2/video/tracking.hpp>

namespace HoloLensForCV
{
    //
    // Handles media capture and exposing sensor frames for the specified sensor group.
    //
    public ref class MediaFrameSourceGroup sealed
    {
    public:
        MediaFrameSourceGroup(
            _In_ MediaFrameSourceGroupType mediaFrameSourceGroupType,
            _In_ SpatialPerception^ spatialPerception,
            _In_ DeviceType deviceType,
            _In_opt_ ISensorFrameSinkGroup^ optionalSensorFrameSinkGroup,
            _In_ float fL1, _In_ float fL2,
            _In_ float pP1, _In_ float pP2,
            _In_ float rD1, _In_ float rD2, _In_ float rD3,
            _In_ float tD1, _In_ float tD2,
            _In_ int imageWidth,
            _In_ int imageHeight);

        void EnableAll();

        void Enable(
            _In_ SensorType sensorType);

        Windows::Foundation::IAsyncAction^ StartAsync();

        Windows::Foundation::IAsyncAction^ StartArUcoMarkerTrackerAsync(float markerSize, int dictId, Windows::Perception::Spatial::SpatialCoordinateSystem^ unitySpatialCoodinateSystem);
        //void DetectArUcoMarkers(SensorType type);
        Windows::Foundation::Collections::IVector<DetectedArUcoMarker^>^ DetectArUcoMarkers(SensorType type);
        //Windows::Foundation::Collections::IVector<DetectedArUcoMarker^>^ GetArUcoDetections();

		Windows::Foundation::IAsyncAction^ StopAsync();

        SensorFrame^ GetLatestSensorFrame(
            SensorType sensorType);

    private:
        /// <summary>
        /// Returns true if the sensor was explicitly enabled by the user.
        /// </summary>
        bool IsEnabled(
            _In_ SensorType sensorType) const;

        /// <summary>
        /// Switch to the next eligible media source.
        /// </summary>
        Concurrency::task<void> InitializeMediaSourceWorkerAsync();

        /// <summary>
        /// </summary>
        SensorType GetSensorType(
            Windows::Media::Capture::Frames::MediaFrameSource^ source);

        /// <summary>
        /// </summary>
        Platform::String^ GetSubtypeForFrameReader(
            Windows::Media::Capture::Frames::MediaFrameSourceKind kind,
            Windows::Media::Capture::Frames::MediaFrameFormat^ format);

        /// <summary>
        /// Stop streaming from all readers and dispose all readers and media capture object.
        /// </summary>
        /// <remarks>
        /// Unregisters FrameArrived event handlers, stops and disposes frame readers
        /// and disposes the MediaCapture object.
        /// </remarks>
        concurrency::task<void> CleanupMediaCaptureAsync();

        /// <summary>
        /// Initialize the media capture object.
        /// Must be called from the UI thread.
        /// </summary>
        concurrency::task<bool> TryInitializeMediaCaptureAsync(
            Windows::Media::Capture::Frames::MediaFrameSourceGroup^ group);

    private:
        ArUcoMarkerTracker^ _arUcoMarkerTracker;
        CameraIntrinsicsAndExtrinsics^ _cameraIntrinsicsAndExtrinsics;
        //Windows::Foundation::Collections::IVector<DetectedArUcoMarker^>^ _detections = ref new Platform::Collections::Vector<DetectedArUcoMarker^>();

        //// Create a Kalman filter to filter bad tracking results
        //// https://docs.opencv.org/master/dc/d2c/tutorial_real_time_pose.html
        //void initKalmanFilter(cv::KalmanFilter& KF, int nStates, int nMeasurements, int nInputs, double dt);
        //void fillMeasurements(cv::Mat& measurements, const cv::Mat& translation_measured, const cv::Mat& rotation_measured);
        //void updateKalmanFilter(cv::KalmanFilter& KF, cv::Mat& measurement, cv::Mat& translation_estimated, cv::Mat& rotation_estimated);
        //cv::KalmanFilter _KF;         // instantiate Kalman Filter
        //int _nStates = 18;            // the number of states
        //int _nMeasurements = 6;       // the number of measured states
        //int _nInputs = 0;             // the number of action control
        //double _dt = 0.125;           // time between measurements (1/FPS)

        MediaFrameSourceGroupType _mediaFrameSourceGroupType;
        SpatialPerception^ _spatialPerception;
        DeviceType _deviceType;

        Platform::Agile<Windows::Media::Capture::MediaCapture> _mediaCapture;

        std::vector<std::pair<Windows::Media::Capture::Frames::MediaFrameReader^, Windows::Foundation::EventRegistrationToken>> _frameEventRegistrations;

        std::array<bool, (size_t)SensorType::NumberOfSensorTypes> _enabledFrameReaders;
        std::array<MediaFrameReaderContext^, (size_t)SensorType::NumberOfSensorTypes> _frameReaders;

        ISensorFrameSinkGroup^ _optionalSensorFrameSinkGroup;
    };
}
