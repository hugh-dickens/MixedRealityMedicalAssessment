#include "pch.h"
#include "DesktopStreamerHeader.h"

// https://docs.microsoft.com/en-us/windows/uwp/cpp-and-winrt-apis/faq#why-am-i-getting-a-class-not-registered-exception

namespace HoloLensForCV
{
	DesktopStreamerHeader::DesktopStreamerHeader()
	{
		NumberOfBoxes = 0;
		BoxSize = 0;
	}

	/* static */ void DesktopStreamerHeader::Read(
		_Inout_ Windows::Storage::Streams::DataReader^ dataReader,
		_Out_ DesktopStreamerHeader^* headerReference)
	{
		DesktopStreamerHeader^ header =
			ref new DesktopStreamerHeader();

		header->NumberOfBoxes = dataReader->ReadUInt32();
		header->BoxSize = dataReader->ReadUInt32();

		*headerReference = header;
	}

	/* static */ void DesktopStreamerHeader::Write(
		_In_ DesktopStreamerHeader^ header,
		_Inout_ Windows::Storage::Streams::DataWriter^ dataWriter)
	{
		dataWriter->WriteUInt32(header->NumberOfBoxes);
		dataWriter->WriteUInt32(header->BoxSize);
	}
}
