#pragma once
#include "DetectedArUcoMarker.h"
#include <opencv2/aruco.hpp>
#include <opencv2/core.hpp>

namespace HoloLensForCV
{
	// ArUcoMarkerTracker runtime class
	public ref class ArUcoMarkerTracker sealed
	{
	public:
		ArUcoMarkerTracker(
			float markerSize,
			int dictId,
			Windows::Perception::Spatial::SpatialCoordinateSystem^ unitySpatialCoodinateSystem);

		Windows::Foundation::Collections::IVector<DetectedArUcoMarker^>^
			DetectArUcoMarkersInFrame(
				SensorFrame^ pvSensorFrame);

	private:
		// Cached parameters for aruco marker detection
		float _markerSize;
		int _dictId;

		// Spatial coordinate system from unity
		Windows::Perception::Spatial::SpatialCoordinateSystem^ _unitySpatialCoordinateSystem;

	};
}


