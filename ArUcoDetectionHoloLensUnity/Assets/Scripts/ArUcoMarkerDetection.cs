using System;
using System.Collections;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Runtime.InteropServices;

#if ENABLE_WINMD_SUPPORT
using Windows.UI.Xaml;
using Windows.Graphics.Imaging;
using Windows.Perception.Spatial;

// Include winrt components
using HoloLensForCV;
#endif

using UnityEngine;
using UnityEngine.UI;
using UnityEngine.XR.WSA;
using UnityEngine.XR.WSA.Input;
using System.Threading;
using Microsoft.MixedReality.Toolkit.Experimental.Utilities;

using TMPro;

// App permissions, modify the appx file for research mode streams
// https://docs.microsoft.com/en-us/windows/uwp/packaging/app-capability-declarations

// Reimplement as list loop structure... 
namespace ArUcoDetectionHoloLensUnity
{
    // Using the hololens for cv .winmd file for runtime support
    // Build HoloLensForCV c++ project (x86) and copy all output files
    // to Assets->Plugins->x86
    // https://docs.unity3d.com/2018.4/Documentation/Manual/IL2CPP-WindowsRuntimeSupport.html
    public class ArUcoMarkerDetection : MonoBehaviour
    {
        private bool _isWorldAnchored = false;

        public Text myText;

        public CvUtils.DeviceTypeUnity deviceType;

        // Note: HL2 only has PV camera function currently.
        public CvUtils.SensorTypeUnity sensorTypePv;
        public CvUtils.ArUcoDictionaryName arUcoDictionaryName;

        // Params for aruco detection
        // Marker size in meters: 0.08 cm
        public float markerSize;

        /// <summary>
        /// Holder for the camera parameters (intrinsics and extrinsics)
        /// of the tracking sensor on the HoloLens 2
        /// </summary>
        public CameraCalibrationParams calibParams;

        /// <summary>
        /// Game object for to use for marker instantiation
        /// </summary>
        public GameObject markerWrist;
        public GameObject markerElbow;
        public GameObject markerShoulder;

        /// <summary>
        /// List of prefab instances of detected aruco markers.
        /// </summary>
        //private List<GameObject> _markerGOs; - might need to do this instead for the private list of game objects instead of having 3 public 
                                                /// game object variables.

        private bool _mediaFrameSourceGroupsStarted = false;
        private int _frameCount = 0;
        public int skipFrames = 1; // previously 3
        public int MarkerIDWrist = 0;
        public int MarkerIDElbow = 0;
        public int MarkerIDShoulder = 0;
        public float Angle;
        //public GameObject MarkerText;

        public TextMeshPro MarkerTextWrist;
        public TextMeshPro MarkerTextElbow;
        public TextMeshPro MarkerTextShoulder;
        public TextMeshPro AngleText;

        


        //public TextMeshPro AngleRecordingText;

#if ENABLE_WINMD_SUPPORT
        // Enable winmd support to include winmd files. Will not
        // run in Unity editor.
        private SensorFrameStreamer _sensorFrameStreamerPv;
        private SpatialPerception _spatialPerception;
        private HoloLensForCV.DeviceType _deviceType;
        private MediaFrameSourceGroupType _mediaFrameSourceGroup;

        /// <summary>
        /// Media frame source groups for each sensor stream.
        /// </summary>
        private MediaFrameSourceGroup _pvMediaFrameSourceGroup;
        private SensorType _sensorType;

        /// <summary>
        /// ArUco marker tracker winRT class
        /// </summary>
        //private ArUcoMarkerTracker _arUcoMarkerTracker;

        /// <summary>
        /// Coordinate system reference for Unity to WinRt 
        /// transform construction
        /// </summary>
        private SpatialCoordinateSystem _unityCoordinateSystem;
#endif

        // Gesture handler
        GestureRecognizer _gestureRecognizer;

        #region UnityMethods

        // Use this for initialization
        async void Start()
        {
            // Initialize gesture handler
            InitializeHandler();

            // Start the media frame source groups.
            await StartHoloLensMediaFrameSourceGroups();

            // Wait for a few seconds prior to making calls to Update 
            // HoloLens media frame source groups.
            StartCoroutine(DelayCoroutine());

            markerWrist.transform.localScale = new Vector3(markerSize, markerSize, markerSize);
            markerElbow.transform.localScale = new Vector3(markerSize, markerSize, markerSize);
            markerShoulder.transform.localScale = new Vector3(markerSize, markerSize, markerSize);
        }

        /// <summary>
        /// https://docs.unity3d.com/ScriptReference/WaitForSeconds.html
        /// Wait for some seconds for media frame source groups to complete
        /// their initialization.
        /// </summary>
        /// <returns></returns>
        IEnumerator DelayCoroutine()
        {
            Debug.Log("Started Coroutine at timestamp : " + Time.time);

            // YieldInstruction that waits for 2 seconds.
            yield return new WaitForSeconds(2);

            Debug.Log("Finished Coroutine at timestamp : " + Time.time);
        }

        // Update is called once per frame
        async void Update()
        {
#if ENABLE_WINMD_SUPPORT
            _frameCount += 1;

            // Predict every 3rd frame - changed to first
            if (_frameCount == skipFrames)
            {
                // Potentially this is where I will need to look for 3 ArUco markers instead of just the one. Var declares local 
                // variables without giving them explicit types, therefore not 100% sure what detections is.
                // wait until the task is completed => task being completed - using the type of sensor stream detect
                // the markers with openCV
                var detections = await Task.Run(() => _pvMediaFrameSourceGroup.DetectArUcoMarkers(_sensorType));

                // Update the game object pose with current detections - this will have to be 3 seperate game objects/ their poses.
                UpdateArUcoDetections(detections);

                _frameCount = 0;
            }
#endif
        }

        async void OnApplicationQuit()
        {
            await StopHoloLensMediaFrameSourceGroup();
        }

        #endregion

        async Task StartHoloLensMediaFrameSourceGroups()
        {
#if ENABLE_WINMD_SUPPORT
            // Plugin doesn't work in the Unity editor
            myText.text = "Initializing MediaFrameSourceGroups...";

            // PV
            Debug.Log("HoloLensForCVUnity.ArUcoDetection.StartHoloLensMediaFrameSourceGroup: Setting up sensor frame streamer");
            _sensorType = (SensorType)sensorTypePv;
            _sensorFrameStreamerPv = new SensorFrameStreamer();
            _sensorFrameStreamerPv.Enable(_sensorType);

            // Spatial perception
            Debug.Log("HoloLensForCVUnity.ArUcoDetection.StartHoloLensMediaFrameSourceGroup: Setting up spatial perception");
            _spatialPerception = new SpatialPerception();

            // Enable media frame source groups
            // PV
            Debug.Log("HoloLensForCVUnity.ArUcoDetection.StartHoloLensMediaFrameSourceGroup: Setting up the media frame source group");

            // Check if using research mode sensors
            if (sensorTypePv == CvUtils.SensorTypeUnity.PhotoVideo)
                _mediaFrameSourceGroup = MediaFrameSourceGroupType.PhotoVideoCamera;
            else
                _mediaFrameSourceGroup = MediaFrameSourceGroupType.HoloLensResearchModeSensors;

            // Cast device type 
            _deviceType = (HoloLensForCV.DeviceType)deviceType;
            _pvMediaFrameSourceGroup = new MediaFrameSourceGroup(
                _mediaFrameSourceGroup,
                _spatialPerception,
                _deviceType,
                _sensorFrameStreamerPv,

                // Calibration parameters from opencv, compute once for each hololens 2 device
                calibParams.focalLength.x, calibParams.focalLength.y,
                calibParams.principalPoint.x, calibParams.principalPoint.y,
                calibParams.radialDistortion.x, calibParams.radialDistortion.y, calibParams.radialDistortion.z,
                calibParams.tangentialDistortion.x, calibParams.tangentialDistortion.y,
                calibParams.imageHeight, calibParams.imageWidth);
            _pvMediaFrameSourceGroup.Enable(_sensorType);

            // Start media frame source groups
            myText.text = "Starting MediaFrameSourceGroups...";

            // Photo video
            Debug.Log("HoloLensForCVUnity.ArUcoDetection.StartHoloLensMediaFrameSourceGroup: Starting the media frame source group");
            await _pvMediaFrameSourceGroup.StartAsync();
            _mediaFrameSourceGroupsStarted = true;

            myText.text = "MediaFrameSourceGroups started...";

            // Initialize the Unity coordinate system
            // Get pointer to Unity's spatial coordinate system
            // https://github.com/qian256/HoloLensARToolKit/blob/master/ARToolKitUWP-Unity/Scripts/ARUWPVideo.cs
            try
            {
                _unityCoordinateSystem = Marshal.GetObjectForIUnknown(WorldManager.GetNativeISpatialCoordinateSystemPtr()) as SpatialCoordinateSystem;
            }
            catch (Exception)
            {
                Debug.Log("ArUcoDetectionHoloLensUnity.ArUcoMarkerDetection: Could not get pointer to Unity spatial coordinate system.");
                throw;
            }

            // Initialize the aruco marker detector with parameters
            await _pvMediaFrameSourceGroup.StartArUcoMarkerTrackerAsync(
                markerSize, 
                (int)arUcoDictionaryName, 
                _unityCoordinateSystem);
#endif
        }

        // Get the latest frame from hololens media
        // frame source group -- not needed; I didnt add in this comment
#if ENABLE_WINMD_SUPPORT           
        void UpdateArUcoDetections(IList<DetectedArUcoMarker> detections)
        {
            if (!_mediaFrameSourceGroupsStarted ||
                _pvMediaFrameSourceGroup == null)
            {
                return;
            }

            // Detect ArUco markers in current frame
            // https://docs.opencv.org/2.4/modules/calib3d/doc/camera_calibration_and_3d_reconstruction.html#void%20Rodrigues(InputArray%20src,%20OutputArray%20dst,%20OutputArray%20jacobian)
            // THIS WAS COMMENTED OUT BELOW

            // IList<DetectedArUcoMarker> detectedArUcoMarkers = _pvMediaFrameSourceGroup.GetArUcoDetections();
            // _pvMediaFrameSourceGroup.DetectArUcoMarkers(_sensorType);


            // THIS WAS detections.Count !=0
            // If we detect a marker, display
            
            if (detections.Count == 3)
            {
                //myText.text = "Angle:";
                // Remove world anchor from game object
                if (_isWorldAnchored)
                {
                    try
                    {
                        DestroyImmediate(markerWrist.GetComponent<WorldAnchor>());
                        DestroyImmediate(markerElbow.GetComponent<WorldAnchor>());
                        DestroyImmediate(markerShoulder.GetComponent<WorldAnchor>());
                        _isWorldAnchored = false;
                    }
                    catch (Exception)
                    {
                        throw;
                    }
                }

                // COMMENTED OUT the foreach loop
                /*foreach (var detectedMarker in detections)
                {
                    // Get pose from OpenCV and format for Unity
                    Vector3 position = CvUtils.Vec3FromFloat3(detectedMarker.Position);
                    MarkerIDWrist = detectedMarker.Id;
                    MarkerTextWrist.SetText(MarkerIDWrist.ToString());
                    position.y *= -1f;
                    Quaternion rotation = CvUtils.RotationQuatFromRodrigues(CvUtils.Vec3FromFloat3(detectedMarker.Rotation));
                    Matrix4x4 cameraToWorldUnity = CvUtils.Mat4x4FromFloat4x4(detectedMarker.CameraToWorldUnity);
                    Matrix4x4 transformUnityCamera = CvUtils.TransformInUnitySpace(position, rotation);

                    // Use camera to world transform to get world pose of marker
                    Matrix4x4 transformUnityWorld = cameraToWorldUnity * transformUnityCamera;

                    // Apply updated transform to gameobject in world
                    markerWrist.transform.SetPositionAndRotation(
                        CvUtils.GetVectorFromMatrix(transformUnityWorld),
                        CvUtils.GetQuatFromMatrix(transformUnityWorld));
                } */

                //// HARDCODED to try and track all 3 ArUco markers instead of 1. THis is effectively the same as a for loop with 
                /// naming being slightly easier for now - will change.
                // Get pose from OpenCV and format for Unity

                // This code works - been altered to only assign in this order on first detection of ArUco codes
                if (MarkerIDWrist == 0)
                {
                    MarkerIDWrist = detections[0].Id;
                    // MarkerTextWrist.SetText(MarkerIDWrist.ToString());
                    MarkerIDElbow = detections[1].Id;
                    // MarkerTextElbow.SetText(MarkerIDElbow.ToString());
                    MarkerIDShoulder = detections[2].Id;
                    //MarkerTextShoulder.SetText(MarkerIDShoulder.ToString());

                    Vector3 position1 = CvUtils.Vec3FromFloat3(detections[0].Position);
                    Vector3 position2 = CvUtils.Vec3FromFloat3(detections[1].Position);
                    Vector3 position3 = CvUtils.Vec3FromFloat3(detections[2].Position);


                    position1.y *= -1f;
                    position2.y *= -1f;
                    position3.y *= -1f;

                    
                    Quaternion rotation1 = CvUtils.RotationQuatFromRodrigues(CvUtils.Vec3FromFloat3(detections[0].Rotation));
                    Matrix4x4 cameraToWorldUnity1 = CvUtils.Mat4x4FromFloat4x4(detections[0].CameraToWorldUnity);
                    Matrix4x4 transformUnityCamera1 = CvUtils.TransformInUnitySpace(position1, rotation1);

                    // Use camera to world transform to get world pose of marker
                    Matrix4x4 transformUnityWorld1 = cameraToWorldUnity1 * transformUnityCamera1;

                    // Apply updated transform to gameobject in world
                    markerWrist.transform.SetPositionAndRotation(
                        CvUtils.GetVectorFromMatrix(transformUnityWorld1),
                        CvUtils.GetQuatFromMatrix(transformUnityWorld1));

                    // Added this in to print the position instead of the ID
                    //MarkerTextWrist.SetText(markerWrist.transform.position.ToString());
                    MarkerTextWrist.SetText("wrist");

                    Quaternion rotation2 = CvUtils.RotationQuatFromRodrigues(CvUtils.Vec3FromFloat3(detections[1].Rotation));
                    Matrix4x4 cameraToWorldUnity2 = CvUtils.Mat4x4FromFloat4x4(detections[1].CameraToWorldUnity);
                    Matrix4x4 transformUnityCamera2 = CvUtils.TransformInUnitySpace(position2, rotation2);

                    // Use camera to world transform to get world pose of marker
                    Matrix4x4 transformUnityWorld2 = cameraToWorldUnity2 * transformUnityCamera2;

                    // Apply updated transform to gameobject in world
                    markerElbow.transform.SetPositionAndRotation(
                        CvUtils.GetVectorFromMatrix(transformUnityWorld2),
                        CvUtils.GetQuatFromMatrix(transformUnityWorld2));

                    // Added this in to print the position instead of the ID
                    //MarkerTextElbow.SetText(markerElbow.transform.position.ToString());
                    MarkerTextElbow.SetText("elbow");

                    Quaternion rotation3 = CvUtils.RotationQuatFromRodrigues(CvUtils.Vec3FromFloat3(detections[2].Rotation));
                    Matrix4x4 cameraToWorldUnity3 = CvUtils.Mat4x4FromFloat4x4(detections[2].CameraToWorldUnity);
                    Matrix4x4 transformUnityCamera3 = CvUtils.TransformInUnitySpace(position3, rotation3);

                    // Use camera to world transform to get world pose of marker
                    Matrix4x4 transformUnityWorld3 = cameraToWorldUnity3 * transformUnityCamera3;

                    // Apply updated transform to gameobject in world
                    markerShoulder.transform.SetPositionAndRotation(
                        CvUtils.GetVectorFromMatrix(transformUnityWorld3),
                        CvUtils.GetQuatFromMatrix(transformUnityWorld3));

                    // Added this in to print the position instead of the ID
                    //MarkerTextShoulder.SetText(markerShoulder.transform.position.ToString());
                    MarkerTextShoulder.SetText("shoulder");
                }
                else
                {

                    foreach (var index in detections)
                    {
                        if (index.Id == MarkerIDWrist)
                        {
                            Vector3 position1 = CvUtils.Vec3FromFloat3(index.Position);
                            position1.y *= -1f;
                            Quaternion rotation1 = CvUtils.RotationQuatFromRodrigues(CvUtils.Vec3FromFloat3(index.Rotation));
                            Matrix4x4 cameraToWorldUnity1 = CvUtils.Mat4x4FromFloat4x4(index.CameraToWorldUnity);
                            Matrix4x4 transformUnityCamera1 = CvUtils.TransformInUnitySpace(position1, rotation1);

                            // Use camera to world transform to get world pose of marker
                            Matrix4x4 transformUnityWorld1 = cameraToWorldUnity1 * transformUnityCamera1;

                            // Apply updated transform to gameobject in world
                            markerWrist.transform.SetPositionAndRotation(
                                CvUtils.GetVectorFromMatrix(transformUnityWorld1),
                                CvUtils.GetQuatFromMatrix(transformUnityWorld1));

                            // Added this in to print the position instead of the ID
                            //MarkerTextWrist.SetText(markerWrist.transform.position.ToString());
                            MarkerTextWrist.SetText("wrist");

                        }
                        else if (index.Id == MarkerIDElbow)
                        {
                            Vector3 position2 = CvUtils.Vec3FromFloat3(index.Position);
                            position2.y *= -1f;
                            Quaternion rotation2 = CvUtils.RotationQuatFromRodrigues(CvUtils.Vec3FromFloat3(index.Rotation));
                            Matrix4x4 cameraToWorldUnity2 = CvUtils.Mat4x4FromFloat4x4(index.CameraToWorldUnity);
                            Matrix4x4 transformUnityCamera2 = CvUtils.TransformInUnitySpace(position2, rotation2);

                            // Use camera to world transform to get world pose of marker
                            Matrix4x4 transformUnityWorld2 = cameraToWorldUnity2 * transformUnityCamera2;

                            // Apply updated transform to gameobject in world
                            markerElbow.transform.SetPositionAndRotation(
                                CvUtils.GetVectorFromMatrix(transformUnityWorld2),
                                CvUtils.GetQuatFromMatrix(transformUnityWorld2));

                            // Added this in to print the position instead of the ID
                            //MarkerTextWrist.SetText(markerWrist.transform.position.ToString());
                            MarkerTextElbow.SetText("Elbow");
                        }
                        else
                        {
                            Vector3 position3 = CvUtils.Vec3FromFloat3(index.Position);
                            position3.y *= -1f;
                            Quaternion rotation3 = CvUtils.RotationQuatFromRodrigues(CvUtils.Vec3FromFloat3(index.Rotation));
                            Matrix4x4 cameraToWorldUnity3 = CvUtils.Mat4x4FromFloat4x4(index.CameraToWorldUnity);
                            Matrix4x4 transformUnityCamera3 = CvUtils.TransformInUnitySpace(position3, rotation3);

                            // Use camera to world transform to get world pose of marker
                            Matrix4x4 transformUnityWorld3 = cameraToWorldUnity3 * transformUnityCamera3;

                            // Apply updated transform to gameobject in world
                            markerShoulder.transform.SetPositionAndRotation(
                                CvUtils.GetVectorFromMatrix(transformUnityWorld3),
                                CvUtils.GetQuatFromMatrix(transformUnityWorld3));

                            // Added this in to print the position instead of the ID
                            //MarkerTextWrist.SetText(markerWrist.transform.position.ToString());
                            MarkerTextShoulder.SetText("Shoulder");
                        }
                        

                    }
                }
           
                // This turns the coordinates into vectors
                Vector3 vec1 = markerWrist.transform.position - markerElbow.transform.position;
                Vector3 vec2 = markerShoulder.transform.position - markerElbow.transform.position;

                // calculate and display the angle in the public variable
                Angle = Vector3.Angle(vec1, vec2);
                // Currently this will print the angle above the shoulder joint instead of in an external UI - just for testing
                AngleText.SetText(Angle.ToString());
                //myText.text = Angle.ToString();
            }
            // If no markers in scene, anchor marker go to last position - not 100% sure what this does. May need to add seperate world
            // anchors to each markerJoints.
            else
            {
                // Add a world anchor to the attached gameobject
                markerWrist.AddComponent<WorldAnchor>();
                markerElbow.AddComponent<WorldAnchor>();
                markerShoulder.AddComponent<WorldAnchor>();
                _isWorldAnchored = true;
            }
            //myText.text = "Began streaming sensor frames. Double tap to end streaming.";
        }
#endif

        /// <summary>
        /// Stop the media frame source groups.
        /// </summary>
        /// <returns></returns>
        async Task StopHoloLensMediaFrameSourceGroup()
        {
#if ENABLE_WINMD_SUPPORT
            if (!_mediaFrameSourceGroupsStarted ||
                _pvMediaFrameSourceGroup == null)
            {
                return;
            }

            // Wait for frame source groups to stop.
            await _pvMediaFrameSourceGroup.StopAsync();
            _pvMediaFrameSourceGroup = null;

            // Set to null value
            _sensorFrameStreamerPv = null;

            // Bool to indicate closing
            _mediaFrameSourceGroupsStarted = false;

            myText.text = "Stopped streaming sensor frames. Okay to exit app.";
#endif
        }

        #region ComImport
        // https://docs.microsoft.com/en-us/windows/uwp/audio-video-camera/imaging
        [ComImport]
        [Guid("5B0D3235-4DBA-4D44-865E-8F1D0E4FD04D")]
        [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
        unsafe interface IMemoryBufferByteAccess
        {
            void GetBuffer(out byte* buffer, out uint capacity);
        }
        #endregion

#if ENABLE_WINMD_SUPPORT
        // Get byte array from software bitmap.
        // https://github.com/qian256/HoloLensARToolKit/blob/master/ARToolKitUWP-Unity/Scripts/ARUWPVideo.cs
        unsafe byte* GetByteArrayFromSoftwareBitmap(SoftwareBitmap sb)
        {
            if (sb == null)
                return null;

            SoftwareBitmap sbCopy = new SoftwareBitmap(sb.BitmapPixelFormat, sb.PixelWidth, sb.PixelHeight);
            Interlocked.Exchange(ref sbCopy, sb);
            using (var input = sbCopy.LockBuffer(BitmapBufferAccessMode.Read))
            using (var inputReference = input.CreateReference())
            {
                byte* inputBytes;
                uint inputCapacity;
                ((IMemoryBufferByteAccess)inputReference).GetBuffer(out inputBytes, out inputCapacity);
                return inputBytes;
            }
        }
#endif

        #region TapGestureHandler
        private void InitializeHandler()
        {
            // New recognizer class
            _gestureRecognizer = new GestureRecognizer();

            // Set tap as a recognizable gesture
            _gestureRecognizer.SetRecognizableGestures(GestureSettings.DoubleTap);

            // Begin listening for gestures
            _gestureRecognizer.StartCapturingGestures();

            // Capture on gesture events with delegate handler
            _gestureRecognizer.Tapped += GestureRecognizer_Tapped;

            Debug.Log("Gesture recognizer initialized.");
        }

        // On tapped event, stop all frame source groups
        private void GestureRecognizer_Tapped(TappedEventArgs obj)
        {
            StopHoloLensMediaFrameSourceGroup();
            CloseHandler();
        }

        private void CloseHandler()
        {
            _gestureRecognizer.StopCapturingGestures();
            _gestureRecognizer.Dispose();
        }
        #endregion
    }
}



