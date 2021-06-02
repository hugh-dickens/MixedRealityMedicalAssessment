//*********************************************************
//
// Copyright (c) Microsoft. All rights reserved.
// This code is licensed under the MIT License (MIT).
// THIS CODE IS PROVIDED *AS IS* WITHOUT WARRANTY OF
// ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING ANY
// IMPLIED WARRANTIES OF FITNESS FOR A PARTICULAR
// PURPOSE, MERCHANTABILITY, OR NON-INFRINGEMENT.
//
//*********************************************************

#pragma once

#include <map>
#include <array>
#include <memory>
#include <mutex>
#include <ctime>
#include <deque>
#include <chrono>
#include <fstream>
#include <sstream>
#include <cstddef>
#include <stdexcept>
#include <shared_mutex>
#include <unordered_set>

#include <agile.h>
#include <collection.h>
#include <ppltasks.h>
#include <memorybuffer.h>
#include <windowsnumerics.h>
#include <windows.foundation.h>
#include <windows.foundation.collections.h>
#include <windows.foundation.numerics.h>

#include <DirectXMath.h>

#define DBG_ENABLE_ERROR_LOGGING 1
#define DBG_ENABLE_INFORMATIONAL_LOGGING 1
#define DBG_ENABLE_VERBOSE_LOGGING 1

#include <Debugging/All.h>
#include <Io/All.h>

#include "CsvWriter.h"

#include "ICameraIntrinsics.h"
#include "CameraIntrinsics.h"

#include "SpatialPerception.h"

#include "SensorType.h"
#include "SensorFrame.h"

#include "ISensorFrameSink.h"
#include "ISensorFrameSinkGroup.h"

#include "SensorFrameStreamHeader.h"
#include "SensorFrameStreamingServer.h"
#include "SensorFrameStreamer.h"
#include "SensorFrameReceiver.h"

#include "SensorFrameRecorderSink.h"
#include "SensorFrameRecorder.h"

#include "MediaFrameReaderContext.h"
#include "MediaFrameSourceGroupType.h"
#include "MediaFrameSourceGroup.h"

#include "MultiFrameBuffer.h"

// OpenCV includes (using Nuget package)
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/features2d/features2d.hpp>
#include <opencv2/calib3d/calib3d.hpp>
//#include <opencv2/video/tracking.hpp>

// Include the depth pv mapper class
#include "DepthPvMapper.h"

// Includes for ArUco project
#include "DetectedArUcoMarker.h"
#include "ArUcoMarkerTracker.h"
#include <opencv2/aruco.hpp>
#include "DeviceType.h"