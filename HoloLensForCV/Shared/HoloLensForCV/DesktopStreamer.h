#pragma once

#include "DesktopStreamerHeader.h"
namespace HoloLensForCV
{
	// Collect bounding box information and stream from PC to connected HoloLens.
	// Using sensor frame streaming server as a reference.
	public ref class DesktopStreamer sealed
	{
	public:
		DesktopStreamer(Platform::String^ serviceName);

		void Send(Windows::Foundation::Collections::IVector<YoloRuntime::BoundingBox^>^ boundingBoxes);

	private:
		~DesktopStreamer();

		void OnConnection(
			Windows::Networking::Sockets::StreamSocketListener^ listener,
			Windows::Networking::Sockets::StreamSocketListenerConnectionReceivedEventArgs^ object);

		void SendBoundingBox(
			DesktopStreamerHeader^ header,
			const Platform::Array<uint8_t>^ data);

	private:
		Windows::Networking::Sockets::StreamSocketListener^ _listener;
		Windows::Networking::Sockets::StreamSocket^ _socket;
		Windows::Storage::Streams::DataWriter^ _writer;
		bool _writeInProgress;
	};
}

