#pragma once

// DepthPvMapper implementation from:
// https://github.com/cyberj0g/HoloLensForCV/blob/master/Samples/ComputeOnDevice/DepthPvMapper.cpp

namespace HoloLensForCV
{
	//
	// Creates a synchronized mapping between
	// depth and photo video frames.
	//
	public ref class DepthPvMapper sealed
	{
	public:
		// Initialize depth image space coordinates to unit plane mapping 
		// (reverse depth cam space projection transform, 2D->3D)
		// this transform doesn't depend on actual depth values 
		// and can be done once per sensor stream activation
		DepthPvMapper(HoloLensForCV::SensorFrame^ depthFrame);

		// Need to return a windows runtime type by public member.
		HoloLensForCV::SensorFrame^ MapDepthToPV(
			HoloLensForCV::SensorFrame ^ pvFrame,
			HoloLensForCV::SensorFrame ^ depthFrame,
			int depthRangeFrom,
			int depthRangeTo,
			int patchRadius);

	private:

		// Using custom built Nuget package for
		// OpenCV 4.1.1 Windows compile.
		cv::Mat _imageToCameraMapping;
		cv::Mat createImageToCamMapping(HoloLensForCV::SensorFrame^ depthFrame);
		cv::Mat get4DPointCloudFromDepth(HoloLensForCV::SensorFrame^ depthFrame, int depthRangeFrom, int depthRangeTo);
		cv::Mat createDepthToPVMapping(
			HoloLensForCV::SensorFrame^ pvFrame,
			HoloLensForCV::SensorFrame^ depthFrame,
			int depthRangeFrom,
			int depthRangeTo,
			int patchRadius);
	};

	namespace Utils
	{
		void WrapHoloLensSensorFrameWithCvMat(HoloLensForCV::SensorFrame^ holoLensSensorFrame, cv::Mat& openCVImage);
		HoloLensForCV::SensorFrame^ WrapCvMatWithHoloLensSensorFrame(cv::Mat& from, Windows::Foundation::DateTime dt);
		unsigned char* GetPointerToPixelData(Windows::Foundation::IMemoryBufferReference^ reference);
		static cv::Vec4f vecDotM(cv::Vec4f vec, Windows::Foundation::Numerics::float4x4 m);
		static cv::Mat floatMToCvMat(Windows::Foundation::Numerics::float4x4 in);

	}
}

