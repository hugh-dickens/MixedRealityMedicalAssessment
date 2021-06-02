#pragma once
#include "pch.h"
#include "DepthPvMapper.h"

namespace HoloLensForCV
{
	// Cache the image to camera mapping of depth sensor (only done once).
	DepthPvMapper::DepthPvMapper(HoloLensForCV::SensorFrame^ depthFrame)
	{
		_imageToCameraMapping = createImageToCamMapping(depthFrame);
	}

	// Get mapping of depth frame from image to camera. Performed once a session.
	cv::Mat DepthPvMapper::createImageToCamMapping(HoloLensForCV::SensorFrame^ depthFrame)
	{
		cv::Mat imageToCameraMapping = cv::Mat(
			depthFrame->SoftwareBitmap->PixelHeight,
			depthFrame->SoftwareBitmap->PixelWidth,
			CV_32FC2,
			cv::Scalar::all(0));
		for (int x = 0; x < depthFrame->SoftwareBitmap->PixelWidth; ++x) {
			for (int y = 0; y < depthFrame->SoftwareBitmap->PixelWidth; ++y) {
				Windows::Foundation::Point uv = { float(x), float(y) };
				Windows::Foundation::Point xy(0, 0);
				if (depthFrame->SensorStreamingCameraIntrinsics->MapImagePointToCameraUnitPlane(uv, &xy)) {
					imageToCameraMapping.at<cv::Vec2f>(y, x) = cv::Vec2f(xy.X, xy.Y);
				}
			}
		}
		return imageToCameraMapping;
	}

	// Projects depth sensor data to PV frame and returns Mat with measured distances in mm in PV frame coordinates
	HoloLensForCV::SensorFrame^ DepthPvMapper::MapDepthToPV(
		HoloLensForCV::SensorFrame^ pvFrame,
		HoloLensForCV::SensorFrame^ depthFrame,
		int depthRangeFrom, int depthRangeTo, int patchRadius)
	{
		// Check if frames are null
		if (pvFrame == nullptr || depthFrame == nullptr)
		{
			return nullptr;
		}

		// Convert depth to pv mapping from CV_16UC1 (gray) to bgra8
		cv::Mat depthPvGray = createDepthToPVMapping(pvFrame, depthFrame, depthRangeFrom, depthRangeTo, patchRadius);
		cv::Mat depthPvBgra;

		// Convert cv::mat to bgra and return as sensor frame
		cv::cvtColor(depthPvGray, depthPvBgra, cv::COLOR_GRAY2BGRA);
		depthPvBgra.convertTo(depthPvBgra, CV_8UC4);

		// Adjust contrast of images.
		cv::Mat pvBgra;
		Utils::WrapHoloLensSensorFrameWithCvMat(pvFrame, pvBgra);
		depthPvBgra = 0.6*depthPvBgra + 0.2*pvBgra;

		// Return as sensor frame
		HoloLensForCV::SensorFrame^ pvDepthSensorFrame =
			Utils::WrapCvMatWithHoloLensSensorFrame(depthPvBgra, pvFrame->Timestamp);
		return pvDepthSensorFrame;
	}

	// Get the 4D point cloud from depth sensor frame
	cv::Mat DepthPvMapper::get4DPointCloudFromDepth(
		HoloLensForCV::SensorFrame^ depthFrame,
		int depthRangeFrom, int depthRangeTo)
	{
		cv::Mat depthImage;
		Utils::WrapHoloLensSensorFrameWithCvMat(depthFrame, depthImage);
		cv::Mat pointCloud(depthImage.rows, depthImage.cols, CV_32FC4, cv::Scalar::all(0));
		for (int x = 0; x < depthImage.cols; ++x) {
			for (int y = 0; y < depthImage.rows; ++y) {

				// Make sure point cloud is within specified depth range
				if (depthImage.at<unsigned short>(y, x) < depthRangeFrom || depthImage.at<unsigned short>(y, x) > depthRangeTo) {
					continue;
				}
				auto camPoint = _imageToCameraMapping.at<cv::Vec2f>(y, x);
				Windows::Foundation::Point uv = { float(x), float(y) };
				Windows::Foundation::Point xy(camPoint.val[0], camPoint.val[1]);
				cv::Point3f d(xy.X, xy.Y, 1);

				// scale factor for depth point cloud
				// (-1 * depth(y,x) / 1000) * (1 / sqrt(x^2 + y^2 + 1)
				d *= -(depthImage.at<unsigned short>(y, x) / 1000.0) * (1 / sqrt(d.x*d.x + d.y*d.y + 1));
				pointCloud.at<cv::Vec4f>(y, x) = cv::Vec4f(d.x, d.y, d.z, 1);
			}
		}
		return pointCloud;
	}

	// Take in sensor frames, depth near/far ranges and patch radius.
	// Returns Mat of type CV_16UC1
	cv::Mat DepthPvMapper::createDepthToPVMapping(
		HoloLensForCV::SensorFrame^ pvFrame,
		HoloLensForCV::SensorFrame^ depthFrame,
		int depthRangeFrom,
		int depthRangeTo,
		int patchRadius)
	{
		int pvWidth = pvFrame->SoftwareBitmap->PixelWidth;
		int pvHeight = pvFrame->SoftwareBitmap->PixelHeight;
		cv::Mat res(pvHeight, pvWidth, CV_16UC1, cv::Scalar::all(0));
		cv::Mat pointCloud = get4DPointCloudFromDepth(depthFrame, depthRangeFrom, depthRangeTo);
		cv::Mat depthImage;
		Utils::WrapHoloLensSensorFrameWithCvMat(depthFrame, depthImage);
		auto depthFrameToOrigin = depthFrame->FrameToOrigin;
		auto depthCamViewTransform = depthFrame->CameraViewTransform;
		auto pvFrameToOrigin = pvFrame->FrameToOrigin;
		auto pvCamViewTransform = pvFrame->CameraViewTransform;
		auto pvCamProjTransform = pvFrame->CameraProjectionTransform;
		Windows::Foundation::Numerics::float4x4 depthCamViewTransformInv;
		Windows::Foundation::Numerics::float4x4 pvFrameToOriginInv;

		if (!Windows::Foundation::Numerics::invert(depthCamViewTransform, &depthCamViewTransformInv) ||
			!Windows::Foundation::Numerics::invert(pvFrameToOrigin, &pvFrameToOriginInv))
		{
			dbg::trace(L"Can't map depth to pv, invalid transform matrices");
			return res;
		}
		// build point cloud -> pv view transform matrix
		auto depthPointToWorld = depthCamViewTransformInv * depthFrameToOrigin;
		auto depthPointToPvFrame = depthPointToWorld * pvFrameToOriginInv;
		auto depthPointToCamView = depthPointToPvFrame * pvCamViewTransform;
		auto depthPointToImage = depthPointToCamView * pvCamProjTransform;

		// loop through point cloud and estimate coordinates
		for (int x = 0; x < pointCloud.cols; ++x) {
			for (int y = 0; y < pointCloud.rows; ++y) {
				cv::Vec4f point = pointCloud.at<cv::Vec4f>(y, x);
				if (point.val[0] == 0 && point.val[1] == 0 && point.val[2] == 0)
					continue; // jump to end of loop body

				// project point and normalize by final w coordinate
				cv::Vec4f projPoint = Utils::vecDotM(point, depthPointToImage);
				cv::Vec3f normProjPoint = cv::Vec3f(
					projPoint.val[0] / projPoint.val[3],
					projPoint.val[1] / projPoint.val[3],
					projPoint.val[2] / projPoint.val[3]);

				// convert point with central origin and y axis up to pv image coordinates
				// scale for screen resolution
				if (normProjPoint.val[0] > -1 && normProjPoint.val[0] < 1 && normProjPoint.val[1] > -1 && normProjPoint.val[1] < 1)
				{
					int imgX = (int)(pvWidth * ((normProjPoint.val[0] + 1) / 2.0));
					int imgY = (int)(pvHeight * (1 - ((normProjPoint.val[1] + 1) / 2.0)));
					for (int i = imgX - patchRadius; i <= imgX + patchRadius; i++)
						for (int j = imgY - patchRadius; j <= imgY + patchRadius; j++)
							if (i >= 0 && j >= 0 && i < res.cols && j < res.rows)
								res.at<ushort>(j, i) = (ushort)depthImage.at<ushort>(y, x);
				}
			}
		}
		return res;
	}

	namespace Utils
	{
		// Taken directly from the OpenCVHelpers.
		void WrapHoloLensSensorFrameWithCvMat(
			_In_ HoloLensForCV::SensorFrame^ holoLensSensorFrame,
			_Out_ cv::Mat& wrappedImage)
		{
			// Confirm that the sensor frame is not null
			if (holoLensSensorFrame != nullptr)
			{
				Windows::Graphics::Imaging::SoftwareBitmap^ bitmap =
				holoLensSensorFrame->SoftwareBitmap;

			Windows::Graphics::Imaging::BitmapBuffer^ bitmapBuffer =
				bitmap->LockBuffer(
					Windows::Graphics::Imaging::BitmapBufferAccessMode::Read);

			uint32_t pixelBufferDataLength = 0;

			uint8_t* pixelBufferData =
				Io::GetTypedPointerToMemoryBuffer<uint8_t>(
					bitmapBuffer->CreateReference(),
					pixelBufferDataLength);

			int32_t wrappedImageType;

			switch (bitmap->BitmapPixelFormat)
			{
			case Windows::Graphics::Imaging::BitmapPixelFormat::Bgra8:
				wrappedImageType = CV_8UC4;
				break;

			case Windows::Graphics::Imaging::BitmapPixelFormat::Gray16:
				wrappedImageType = CV_16UC1;
				break;

			case Windows::Graphics::Imaging::BitmapPixelFormat::Gray8:
				wrappedImageType = CV_8UC1;
				break;

			default:
				dbg::trace(
					L"WrapHoloLensSensorFrameWithCvMat: unrecognized bitmap pixel format, falling back to CV_8UC1");

				wrappedImageType = CV_8UC1;
				break;
			}

			wrappedImage = cv::Mat(
				bitmap->PixelHeight,
				bitmap->PixelWidth,
				wrappedImageType,
				pixelBufferData);
				
			}

			// Otherwise return an empty sensor frame
			else
			{
				uint8_t* pixelBufferData = new uint8_t(); 

				wrappedImage = cv::Mat(
					0,
					0,
					CV_8UC1,
					pixelBufferData);
			}
		}

		// Wrap OpenCV Mat of type CV_8UC1 with SensorFrame.
		HoloLensForCV::SensorFrame^ WrapCvMatWithHoloLensSensorFrame(
			cv::Mat& from, Windows::Foundation::DateTime dt)
		{
			int32_t pixelHeight = from.rows;
			int32_t pixelWidth = from.cols;

			Windows::Graphics::Imaging::SoftwareBitmap^ bitmap =
				ref new Windows::Graphics::Imaging::SoftwareBitmap(
					Windows::Graphics::Imaging::BitmapPixelFormat::Bgra8,
					pixelWidth, pixelHeight,
					Windows::Graphics::Imaging::BitmapAlphaMode::Ignore);

			Windows::Graphics::Imaging::BitmapBuffer^ bitmapBuffer =
				bitmap->LockBuffer(Windows::Graphics::Imaging::BitmapBufferAccessMode::ReadWrite);

			auto reference = bitmapBuffer->CreateReference();
			unsigned char* dstPixels = GetPointerToPixelData(reference);
			memcpy(dstPixels, from.data, from.step.buf[1] * from.cols * from.rows);

			// Return a new sensor frame of photovideo type
			HoloLensForCV::SensorFrame^ sf =
				ref new HoloLensForCV::SensorFrame(HoloLensForCV::SensorType::PhotoVideo, dt, bitmap);
			return sf;
		}

		// https://github.com/microsoft/Windows-universal-samples/blob/master/Samples/CameraOpenCV/shared/OpenCVBridge/OpenCVHelper.cpp
		// https://stackoverflow.com/questions/34198259/winrt-c-win10-opencv-hsv-color-space-image-display-artifacts/34198580#34198580
		// Get pointer to memory buffer reference. 
		unsigned char* GetPointerToPixelData(Windows::Foundation::IMemoryBufferReference^ reference)
		{
			Microsoft::WRL::ComPtr<Windows::Foundation::IMemoryBufferByteAccess> bufferByteAccess;

			reinterpret_cast<IInspectable*>(reference)->QueryInterface(IID_PPV_ARGS(&bufferByteAccess));

			unsigned char* pixels = nullptr;
			unsigned int capacity = 0;
			bufferByteAccess->GetBuffer(&pixels, &capacity);

			return pixels;
		}

		// Perform vector matrix multiplication for camera projection math.
		cv::Vec4f vecDotM(cv::Vec4f vec, Windows::Foundation::Numerics::float4x4 m)
		{
			cv::Vec4f res;
			res.val[0] = vec.val[0] * m.m11 + vec.val[1] * m.m21 + vec.val[2] * m.m31 + vec.val[3] * m.m41;
			res.val[1] = vec.val[0] * m.m12 + vec.val[1] * m.m22 + vec.val[2] * m.m32 + vec.val[3] * m.m42;
			res.val[2] = vec.val[0] * m.m13 + vec.val[1] * m.m23 + vec.val[2] * m.m33 + vec.val[3] * m.m43;
			res.val[3] = vec.val[0] * m.m14 + vec.val[1] * m.m24 + vec.val[2] * m.m34 + vec.val[3] * m.m44;
			return res;
		}

		// Helper function to convert a windows foundation float 4 x 4 to OpenCV mat format.
		cv::Mat floatMToCvMat(Windows::Foundation::Numerics::float4x4 in)
		{
			cv::Mat res = cv::Mat(4, 4, CV_32F);
			res.at<float>(0, 0) = in.m11;
			res.at<float>(0, 1) = in.m12;
			res.at<float>(0, 2) = in.m13;
			res.at<float>(0, 3) = in.m14;

			res.at<float>(1, 0) = in.m21;
			res.at<float>(1, 1) = in.m22;
			res.at<float>(1, 2) = in.m23;
			res.at<float>(1, 3) = in.m24;

			res.at<float>(2, 0) = in.m31;
			res.at<float>(2, 1) = in.m32;
			res.at<float>(2, 2) = in.m33;
			res.at<float>(2, 3) = in.m34;

			res.at<float>(3, 0) = in.m41;
			res.at<float>(3, 1) = in.m42;
			res.at<float>(3, 2) = in.m43;
			res.at<float>(3, 3) = in.m44;
			return res;
		}
	}
}
