#include "pch.h"
#include "ArUcoMarkerTracker.h"
#include "DetectedArUcoMarker.h"

namespace HoloLensForCV
{
	ArUcoMarkerTracker::ArUcoMarkerTracker(
		float markerSize,
		int dictId,
		Windows::Perception::Spatial::SpatialCoordinateSystem^ unitySpatialCoodinateSystem)
	{
		// Cache initial input parameters
		_markerSize = markerSize;
		_dictId = dictId;
		_unitySpatialCoordinateSystem = unitySpatialCoodinateSystem;
	}


	Windows::Foundation::Collections::IVector<DetectedArUcoMarker^>^
		ArUcoMarkerTracker::DetectArUcoMarkersInFrame(
			SensorFrame^ pvSensorFrame)
	{

		// Clear the prior interface vector containing
		// detected aruco markers
		Windows::Foundation::Collections::IVector<DetectedArUcoMarker^>^ detectedMarkers
			= ref new Platform::Collections::Vector<DetectedArUcoMarker^>();

		// If null sensor frame, return zero detections
		if (pvSensorFrame == nullptr)
		{
			DetectedArUcoMarker^ zeroMarker = ref new DetectedArUcoMarker(
				0,
				Windows::Foundation::Numerics::float3::zero(),
				Windows::Foundation::Numerics::float3::zero(),
				Windows::Foundation::Numerics::float4x4::identity());

			 detectedMarkers->Append(zeroMarker);
			 return detectedMarkers;
		}

		else
		{
			// https://docs.opencv.org/4.1.1/d5/dae/tutorial_aruco_detection.html
			cv::Mat wrappedMat;
			std::vector<std::vector<cv::Point2f>> markers, rejectedCandidates;
			std::vector<int32_t> markerIds;

			// Create the aruco dictionary from id
			cv::Ptr<cv::aruco::Dictionary> dictionary =
				cv::aruco::getPredefinedDictionary(_dictId);

			// Create detector parameters
			cv::Ptr<cv::aruco::DetectorParameters> detectorParams
				= cv::aruco::DetectorParameters::create();

			// Use wrapper method to get cv::Mat from sensor frame
			// Can I directly stream gray frames from pv camera?
			Utils::WrapHoloLensSensorFrameWithCvMat(pvSensorFrame, wrappedMat);

			// Convert cv::Mat to grayscale for detection
			cv::Mat grayMat;
			cv::cvtColor(wrappedMat, grayMat, cv::COLOR_BGRA2GRAY);

			// Detect markers
			cv::aruco::detectMarkers(
				grayMat,
				dictionary,
				markers,
				markerIds,
				detectorParams,
				rejectedCandidates);

			dbg::trace(
				L"ArUcoMarkerTracker::DetectArUcoMarkersInFrame: %i markers found",
				markerIds.size());

			// If we have detected markers, compute the transform
			// to relate WinRT (right-handed row-vector) and Unity
			// (left-handed column-vector) representations for transforms
			// WinRT transfrom -> Unity transform by transpose and flip z values
			if (!markerIds.empty())
			{
				// Get transform to relate unity coordinate system to camera (cameraToUnity)
				// https://github.com/chrisfromwork/HoloLensForCV/blob/master/Samples/UnityArUcoMarkerDetectorPlugin/ArUcoMarkerDetector.cpp			
				Platform::IBox<Windows::Foundation::Numerics::float4x4>^ cameraToUnityReference =
					pvSensorFrame->FrameCoordinateSystem->TryGetTransformTo(_unitySpatialCoordinateSystem);

				if (!cameraToUnityReference)
				{
					dbg::trace(L"Failed to obtain transform to unity coordinate space.");
					DetectedArUcoMarker^ marker = ref new DetectedArUcoMarker(
						0,
						Windows::Foundation::Numerics::float3::zero(),
						Windows::Foundation::Numerics::float3::zero(),
						Windows::Foundation::Numerics::float4x4::identity());

					// Add the marker to interface vector of markers
					detectedMarkers->Append(marker);
					return detectedMarkers;
				}

				// Get camera to unity transformation matrix
				Windows::Foundation::Numerics::float4x4 cameraToUnity = cameraToUnityReference->Value;

				// Get transform to relate view coordinate system to camera coordinate system (viewToCamera)
				Windows::Foundation::Numerics::float4x4 viewToCamera;
				Windows::Foundation::Numerics::invert(pvSensorFrame->CameraViewTransform, &viewToCamera);

				// Compute transform to relate the WinRT coordinate frame with Unity coordinate frame (viewToUnity)
				// WinRT transfrom -> Unity transform by transpose and flip z values
				// https://github.com/chrisfromwork/HoloLensForCV/blob/master/Samples/UnityArUcoMarkerDetectorPlugin/ArUcoMarkerDetector.cpp
				Windows::Foundation::Numerics::float4x4 viewToUnityWinRT = viewToCamera * cameraToUnity;
				Windows::Foundation::Numerics::float4x4 viewToUnity =
					Windows::Foundation::Numerics::transpose(viewToUnityWinRT);
				viewToUnity.m31 *= -1.0f;
				viewToUnity.m32 *= -1.0f;
				viewToUnity.m33 *= -1.0f;
				viewToUnity.m34 *= -1.0f;

				// Set camera intrinsic parameters for aruco based pose estimation
				cv::Mat cameraMatrix(3, 3, CV_64F, cv::Scalar(0));
				cameraMatrix.at<double>(0, 0) = pvSensorFrame->CoreCameraIntrinsics->FocalLength.x;
				cameraMatrix.at<double>(0, 2) = pvSensorFrame->CoreCameraIntrinsics->PrincipalPoint.x;
				cameraMatrix.at<double>(1, 1) = pvSensorFrame->CoreCameraIntrinsics->FocalLength.y;
				cameraMatrix.at<double>(1, 2) = pvSensorFrame->CoreCameraIntrinsics->PrincipalPoint.y;
				cameraMatrix.at<double>(2, 2) = 1.0;

				// Set distortion matrix for aruco based pose estimation
				cv::Mat distortionCoefficientsMatrix(1, 5, CV_64F);
				distortionCoefficientsMatrix.at<double>(0, 0) = pvSensorFrame->CoreCameraIntrinsics->RadialDistortion.x;
				distortionCoefficientsMatrix.at<double>(0, 1) = pvSensorFrame->CoreCameraIntrinsics->RadialDistortion.y;
				distortionCoefficientsMatrix.at<double>(0, 2) = pvSensorFrame->CoreCameraIntrinsics->TangentialDistortion.x;
				distortionCoefficientsMatrix.at<double>(0, 3) = pvSensorFrame->CoreCameraIntrinsics->TangentialDistortion.y;
				distortionCoefficientsMatrix.at<double>(0, 4) = pvSensorFrame->CoreCameraIntrinsics->RadialDistortion.z;

				// Vectors for pose (translation and rotation) estimation
				std::vector<cv::Vec3d> rVecs;
				std::vector<cv::Vec3d> tVecs;

				// Estimate pose of single markers
				cv::aruco::estimatePoseSingleMarkers(
					markers,
					_markerSize,
					cameraMatrix,
					distortionCoefficientsMatrix,
					rVecs,
					tVecs);

				// Iterate across the detected marker ids and cache information of 
				// pose of each marker as well as marker id
				for (size_t i = 0; i < markerIds.size(); i++)
				{
					// Create marker WinRT marker class instance with current
					// detected marker parameters and view to unity transform
					DetectedArUcoMarker^ marker = ref new DetectedArUcoMarker(
						markerIds[i],
						Windows::Foundation::Numerics::float3((float)tVecs[i][0], (float)tVecs[i][1], (float)tVecs[i][2]),
						Windows::Foundation::Numerics::float3((float)rVecs[i][0], (float)rVecs[i][1], (float)rVecs[i][2]),
						viewToUnity);

					// Add the marker to interface vector of markers
					detectedMarkers->Append(marker);
				}
			}

			return detectedMarkers;
		}
	}
}
