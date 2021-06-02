#pragma once

namespace HoloLensForCV
{
	// Class to hold important properties of the 
	// detected ArUco markers to send to Unity.
	public ref class DetectedArUcoMarker sealed
	{
	public:
		DetectedArUcoMarker(
			_In_ int id,
			_In_ Windows::Foundation::Numerics::float3 position,
			_In_ Windows::Foundation::Numerics::float3 rotation,
			_In_ Windows::Foundation::Numerics::float4x4 cameraToWorldUnity);

		property int Id;
		property Windows::Foundation::Numerics::float3 Position;
		property Windows::Foundation::Numerics::float3 Rotation;
		property Windows::Foundation::Numerics::float4x4 CameraToWorldUnity;
	};
}

