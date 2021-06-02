#include "pch.h"
#include "DetectedArUcoMarker.h"

namespace HoloLensForCV
{
	DetectedArUcoMarker::DetectedArUcoMarker(
		_In_ int id,
		_In_ Windows::Foundation::Numerics::float3 position,
		_In_ Windows::Foundation::Numerics::float3 rotation,
		_In_ Windows::Foundation::Numerics::float4x4 cameraToWorldUnity)
	{
		// Set the position, rotation and cam to world transform
		// properties of current marker
		Id = id;
		Position = position;
		Rotation = rotation;
		CameraToWorldUnity = cameraToWorldUnity;
	}
}