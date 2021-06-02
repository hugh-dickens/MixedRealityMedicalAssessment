#pragma once

namespace HoloLensForCV
{
	//
	// Network header for sensor frame streaming.
	//
	public ref class DesktopStreamerHeader sealed
	{
	public:
		DesktopStreamerHeader();

		// Set length of header
		static property uint32_t ProtocolHeaderLength
		{
			uint32_t get()
			{
				return
					2 * sizeof(uint32_t) /* NumBoxes, BoxSize*/;
			}
		}

		property uint32_t NumberOfBoxes;
		property uint32_t BoxSize;

		static void Read(
			_Inout_ Windows::Storage::Streams::DataReader^ dataReader,
			_Out_ DesktopStreamerHeader^* header);

		static void Write(
			_In_ DesktopStreamerHeader^ header,
			_Inout_ Windows::Storage::Streams::DataWriter^ dataWriter);
	};
}

