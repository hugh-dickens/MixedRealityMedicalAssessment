#pragma once
#include "DesktopStreamerHeader.h"

using namespace Windows::Foundation::Collections;

namespace HoloLensForCV
{
	//
	// On the device side, the sensor frame streamer will open a stream socket for each
	// of the sensors.
	//
	// On the client side, connect to that socket and use this class to await on the
	// ReceiveAsync call to obtain sensor frames.
	//
	public ref class DeviceReceiver sealed
	{
	public:
		DeviceReceiver(
			_In_ Windows::Networking::Sockets::StreamSocket^ streamSocket);

		//https://docs.microsoft.com/en-us/cpp/cppcx/array-and-writeonlyarray-c-cx?view=vs-2019
		//https://social.msdn.microsoft.com/Forums/vstudio/en-US/6b2525c3-5da2-4899-8b75-64b218234ea6/how-to-return-array-using-iasyncoperation-in-winrt?forum=wpdevelop
		Windows::Foundation::IAsyncOperation<IVector<uint8_t>^>^
			ReceiveAsync();
	private:
		Concurrency::task<DesktopStreamerHeader^> ReceiveDataHeaderAsync();

		Concurrency::task<IVector<uint8_t>^>
			ReceiveDataAsync(DesktopStreamerHeader^ header);

		std::vector<uint8_t> GetData(
			Windows::Storage::Streams::IBuffer^ buf);

	private:
		Windows::Networking::Sockets::StreamSocket^ _streamSocket;
		Windows::Storage::Streams::DataReader^ _reader;

	};

	public ref class InteropDeviceReceiver sealed
	{
	public:
		// From mainpage app compute on desktop send data
		void ConnectSocket_Click(Platform::String^ ipAddress, Platform::String^ hostId);
		IVector<uint8_t>^ GetBoundingBoxResults();

	private:
		// From mainpage app compute on desktop send data
		IVector<uint8_t>^ _dataVector;
		void ReceiverLoop(DeviceReceiver^ receiver);

		HoloLensForCV::DeviceReceiver^ _receiver;
	};
}
