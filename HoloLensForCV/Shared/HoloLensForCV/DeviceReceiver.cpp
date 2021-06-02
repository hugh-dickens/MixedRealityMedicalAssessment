#include "pch.h"
#include "DeviceReceiver.h"

using namespace Windows::Foundation::Collections;

namespace HoloLensForCV
{
	DeviceReceiver::DeviceReceiver(
		_In_ Windows::Networking::Sockets::StreamSocket^ streamSocket)
		: _streamSocket(streamSocket)
	{
		_reader = ref new Windows::Storage::Streams::DataReader(
			_streamSocket->InputStream);

		_reader->UnicodeEncoding =
			Windows::Storage::Streams::UnicodeEncoding::Utf8;

		_reader->ByteOrder =
			Windows::Storage::Streams::ByteOrder::LittleEndian;

		dbg::trace(L"DeviceReceiver::DeviceReceiver: created data reader.");
	}

	Concurrency::task<DesktopStreamerHeader^>
		DeviceReceiver::ReceiveDataHeaderAsync()
	{
		return concurrency::create_task(
			_reader->LoadAsync(
				DesktopStreamerHeader::ProtocolHeaderLength)
		).then([this](concurrency::task<unsigned int> headerBytesLoadedTaskResult)
		{
			//
			// Make sure that we have received exactly the number of bytes we have
			// asked for. Doing so will also implicitly check for the possible exceptions
			// that could have been thrown in the async call chain.
			//
			const uint32_t headerBytesLoaded = headerBytesLoadedTaskResult.get();

			if (DesktopStreamerHeader::ProtocolHeaderLength != headerBytesLoaded)
			{
				dbg::trace(
					L"DeviceReceiver::ReceiveDataHeaderAsync: expected data of size %i bytes, got %i bytes",
					DesktopStreamerHeader::ProtocolHeaderLength,
					headerBytesLoaded);

				throw ref new Platform::FailureException();
			}

			DesktopStreamerHeader^ header;

			DesktopStreamerHeader::Read(
				_reader,
				&header);

			dbg::trace(
				L"DeviceReceiver::ReceiveAsync: seeing %i bounding boxes of size %i",
				header->NumberOfBoxes,
				header->BoxSize);

			return header;
		});
	}

	//Concurrency::task<Windows::Foundation::Collections::IVector<YoloRuntime::BoundingBox^>^>
	Concurrency::task<IVector<uint8_t>^>
		DeviceReceiver::ReceiveDataAsync(DesktopStreamerHeader^ header)
	{
		return concurrency::create_task(
			_reader->LoadAsync(
				// uint8_t size = 1
				header->BoxSize * header->NumberOfBoxes * sizeof(uint8_t))).
			then([this, header](concurrency::task<unsigned int> bytesLoadedTaskResult)
		{
			//
			// Make sure that we have received exactly the number of bytes we have
			// asked for. Doing so will also implicitly check for the possible exceptions
			// that could have been thrown in the async call chain.
			//
			const size_t bytesLoaded = bytesLoadedTaskResult.get();

			if (header->BoxSize * header->NumberOfBoxes != bytesLoaded)
			{
				dbg::trace(
					L"DeviceReceiver::ReceiveDataAsync: expected data of %i bytes, got %i bytes",
					header->BoxSize * header->NumberOfBoxes,
					bytesLoaded);

				throw ref new Platform::FailureException();
			}

			// Iterate across input vector and fill bounding box struct
			int numBoxes = (int)header->NumberOfBoxes;
			int boxSize = (int)header->BoxSize;

			// Read from incoming stream writer to data buffer array
			// of same size as input data (allocate the memory)
			// https://github.com/microsoft/Windows-universal-samples/blob/master/Samples/DataReaderWriter/cpp/Scenario2_ReadBytes.xaml.cpp
			// Getting null data from stream
			Platform::Array<uint8_t>^ data = ref new Platform::Array<uint8_t>(numBoxes * boxSize);
			_reader->ReadBytes(data);

			dbg::trace(L"DeviceReceiver::ReceiveDataAsync: read in data stream, found %i bounding box(es) and data of size %i.",
				header->NumberOfBoxes,
				data->Length);

			// Process the data to create bounding boxes in C# environment
			//https://social.msdn.microsoft.com/Forums/vstudio/en-US/6b2525c3-5da2-4899-8b75-64b218234ea6/how-to-return-array-using-iasyncoperation-in-winrt?forum=wpdevelop
			IVector<uint8_t>^ dataVec =
				ref new Platform::Collections::Vector<uint8_t>(data->Data, data->Length);
			return dataVec;
		});
	}

	//Windows::Foundation::IAsyncOperation<Windows::Foundation::Collections::IVector<YoloRuntime::BoundingBox^>^>^
	Windows::Foundation::IAsyncOperation<IVector<uint8_t>^>^
		DeviceReceiver::ReceiveAsync()
	{
		return concurrency::create_async(
			[this]()
		{
			return ReceiveDataHeaderAsync().then(
				[this](concurrency::task<DesktopStreamerHeader^> header)
			{;
			return ReceiveDataAsync(header.get());
			});
		});
	}

	// Helper method to get vector data from buffer stream
	std::vector<uint8_t> DeviceReceiver::GetData(
		Windows::Storage::Streams::IBuffer^ buf)
	{
		auto reader = ::Windows::Storage::Streams::DataReader::FromBuffer(buf);

		std::vector<uint8_t> data(reader->UnconsumedBufferLength);

		if (!data.empty())
			reader->ReadBytes(
				::Platform::ArrayReference<unsigned char>(
					&data[0], (unsigned int)data.size()));

		return data;
	}


	void InteropDeviceReceiver::ReceiverLoop(
		DeviceReceiver^ receiver)
	{
		dbg::trace(
			L"InteropDeviceReceiver::ReceiverLoop: creating receive task");

		concurrency::create_task(
			receiver->ReceiveAsync()).then(
				[this, receiver](
					concurrency::task<IVector<uint8_t>^>
					dataTask)
		{
			float boxSize = 6.0f;

			// Receive object
			IVector<uint8_t>^ data =
				dataTask.get();

			dbg::trace(
				L"InteropDeviceReceiver::ReceiverLoop: receiving %i boxes",
				(int)(data->Size / boxSize));

			// Cache the results for access in c# env
			_dataVector = data;

			ReceiverLoop(
				receiver);
		});
	}

	// Expose the bounding box information to c# client
	IVector<uint8_t>^
		InteropDeviceReceiver::GetBoundingBoxResults()
	{
		return _dataVector;
	}

	void InteropDeviceReceiver::ConnectSocket_Click(
		Platform::String^ ipAddress,
		Platform::String^ hostId)
	{
		_dataVector = ref new Platform::Collections::Vector<uint8_t>();

		//
		// By default 'HostNameForConnect' is disabled and host name validation is not required. When enabling the
		// text box validating the host name is required since it was received from an untrusted source
		// (user input). The host name is validated by catching ArgumentExceptions thrown by the HostName
		// constructor for invalid input.
		//
		Windows::Networking::HostName^ hostName;

		try
		{
			hostName = ref new Windows::Networking::HostName(ipAddress);
		}
		catch (Platform::Exception^)
		{
			return;
		}

		Windows::Networking::Sockets::StreamSocket^ dataSocket =
			ref new Windows::Networking::Sockets::StreamSocket();
		dataSocket->Control->KeepAlive = true;

#if DBG_ENABLE_INFORMATIONAL_LOGGING
		dbg::trace(
			L"DeviceReceiver::ConnectSocket_Click: data sender created");
#endif /* DBG_ENABLE_INFORMATIONAL_LOGGING */

		//
		// Save the socket, so subsequent steps can use it.
		//
		concurrency::create_task(
			dataSocket->ConnectAsync(hostName, hostId)
		).then(
			[this, dataSocket]()
		{
#if DBG_ENABLE_INFORMATIONAL_LOGGING
			dbg::trace(
				L"DeviceReceiver::ConnectSocket_Click: server connection established");
#endif /* DBG_ENABLE_INFORMATIONAL_LOGGING */

			_receiver = ref new HoloLensForCV::DeviceReceiver(
				dataSocket);

			ReceiverLoop(
				_receiver);
		});
	}

}