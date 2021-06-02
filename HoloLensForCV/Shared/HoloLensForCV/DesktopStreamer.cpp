#include "pch.h"
#include "DesktopStreamer.h"

namespace HoloLensForCV
{
	DesktopStreamer::DesktopStreamer(Platform::String^ serviceName)
		: _writeInProgress(false)
	{
		// Initialize stream socket listener and beginning 
		// looking for connections
		_listener = ref new Windows::Networking::Sockets::StreamSocketListener();

		_listener->ConnectionReceived +=
			ref new Windows::Foundation::TypedEventHandler<
			Windows::Networking::Sockets::StreamSocketListener^,
			Windows::Networking::Sockets::StreamSocketListenerConnectionReceivedEventArgs^>(
				this,
				&DesktopStreamer::OnConnection);

		_listener->Control->KeepAlive = true;

		// Don't limit traffic to an address or an adapter.
		Concurrency::create_task(_listener->BindServiceNameAsync(serviceName)).then(
			[this](Concurrency::task<void> previousTask)
		{
			try
			{
				// Try getting an exception.
				previousTask.get();
			}
			catch (Platform::Exception^ exception)
			{
#if DBG_ENABLE_ERROR_LOGGING
				dbg::trace(
					L"DesktopStreamer::DesktopStreamer: %s",
					exception->Message->Data());
#endif /* DBG_ENABLE_ERROR_LOGGING */
			}
		});
	}

	void DesktopStreamer::Send(
		Windows::Foundation::Collections::IVector<YoloRuntime::BoundingBox^>^ boundingBoxes)
	{
		if (nullptr == _socket)
		{
			dbg::trace(
				L"DesktopStreamer::Consume: data dropped -- no connection!");
			return;
		}

		if (_writeInProgress)
		{
			dbg::trace(
				L"DesktopStreamer::Send: data dropped -- previous send operation is in progress!");
			return;
		}

		// Format the data from bounding boxes into platform
		// array to send to the device and be consumed in Unity
		// will likely have a bunch of bounding boxes
		// Send with known size, limit to 10 total
		int32_t boxSize = 6;
		int32_t numBoxes = boundingBoxes->Size;
		dbg::trace(L"DesktopStreamer::Send: %i bounding boxes detected.",
			numBoxes);

		if (numBoxes == 0)
		{
			return;
		}

		Platform::Array<uint8_t>^ dataBufferAsPlatformArray;
		int32_t dataBufferSize = boxSize * numBoxes * sizeof(uint8_t);
		{
			dbg::TimerGuard timerGuard(
				L"DesktopStreamer::Send: buffer preparation",
				4.0 /* minimum_time_elapsed_in_milliseconds */);

			// Dynamically allocate memory for the heap
			uint8_t* boxData = new uint8_t[dataBufferSize];

			// For box in bounding boxes
			int boxCount = 0;
			for (YoloRuntime::BoundingBox^ box : boundingBoxes)
			{
				// Add stuff here...
				boxData[(boxSize * boxCount) + 0] = (uint8_t)box->TopLabel;

				// x, y, height, width, and confidence
				boxData[(boxSize * boxCount) + 1] = (uint8_t)box->X;
				boxData[(boxSize * boxCount) + 2] = (uint8_t)box->Y;
				boxData[(boxSize * boxCount) + 3] = (uint8_t)box->Height;
				boxData[(boxSize * boxCount) + 4] = (uint8_t)box->Width;
				boxData[(boxSize * boxCount) + 5] = (uint8_t)box->Confidence;

				boxCount++;
			}

			// Create new platform array from array
			dataBufferAsPlatformArray =
				ref new Platform::Array<uint8_t>(
					boxData,
					dataBufferSize);

			// Deallocate the memory
			delete[] boxData;
		}


		// New instance of static stream header 
		DesktopStreamerHeader^ header =
			ref new DesktopStreamerHeader();

		// Set important parameters to determine
		// size of incoming byte array of box data
		header->NumberOfBoxes = numBoxes;
		header->BoxSize = boxSize;

		// Send bounding box data along with header info
		SendBoundingBox(
			header,
			dataBufferAsPlatformArray);
	}

	DesktopStreamer::~DesktopStreamer()
	{
		// The listener can be closed in two ways:
		//  - explicit: by using delete operator (the listener is closed even if there are outstanding references to it).
		//  - implicit: by removing last reference to it (i.e. falling out-of-scope).
		// In this case this is the last reference to the listener so both will yield the same result.
		delete _listener;
		_listener = nullptr;
	}

	void DesktopStreamer::OnConnection(
		Windows::Networking::Sockets::StreamSocketListener^ listener,
		Windows::Networking::Sockets::StreamSocketListenerConnectionReceivedEventArgs^ object)
	{
		_socket = object->Socket;

		_writeInProgress = false;

		_writer = ref new Windows::Storage::Streams::DataWriter(
			_socket->OutputStream);

		_writer->UnicodeEncoding =
			Windows::Storage::Streams::UnicodeEncoding::Utf8;

		_writer->ByteOrder =
			Windows::Storage::Streams::ByteOrder::LittleEndian;
	}

	void DesktopStreamer::SendBoundingBox(
		DesktopStreamerHeader^ header,
		const Platform::Array<uint8_t>^ data)
	{
		if (nullptr == _socket)
		{
#if DBG_ENABLE_VERBOSE_LOGGING
			dbg::trace(
				L"DesktopStreamer::SendBoundingBox: data dropped -- no connection!");
#endif /* DBG_ENABLE_VERBOSE_LOGGING */

			return;
		}

		if (_writeInProgress)
		{
#if DBG_ENABLE_INFORMATIONAL_LOGGING
			dbg::trace(
				L"DesktopStreamer::SendBoundingBox: data dropped -- previous StoreAsync task is still in progress!");
#endif /* DBG_ENABLE_INFORMATIONAL_LOGGING */

			return;
		}

		_writeInProgress = true;

		{
			dbg::TimerGuard timerGuard(
				L"DesktopStreamer::SendBoundingBox: writer operations",
				4.0 /* minimum_time_elapsed_in_milliseconds */);

			// Write the header info to writer
			DesktopStreamerHeader::Write(
				header,
				_writer);

			_writer->WriteBytes(
				data);
		}

#if DBG_ENABLE_INFORMATIONAL_LOGGING
		dbg::TimerGuard timerGuard(
			L"DesktopStreamer::SendBoundingBox: StoreAsync task creation",
			10.0 /* minimum_time_elapsed_in_milliseconds */);
#endif /* DBG_ENABLE_INFORMATIONAL_LOGGING */

		Concurrency::create_task(_writer->StoreAsync()).then(
			[&](Concurrency::task<unsigned int> writeTask)
		{
			try
			{
				// Try getting an exception.
				writeTask.get();

				_writeInProgress = false;
			}
			catch (Platform::Exception^ exception)
			{
#if DBG_ENABLE_ERROR_LOGGING
				dbg::trace(
					L"DesktopStreamer::SendBoundingBox: StoreAsync call failed with error: %s",
					exception->Message->Data());
#endif /* DBG_ENABLE_ERROR_LOGGING */

				_socket = nullptr;
			}
		});
	}
}

