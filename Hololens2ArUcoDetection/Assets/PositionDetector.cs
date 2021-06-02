using System.Collections;
using System.Collections.Generic;
using UnityEngine;
//https://answers.unity.com/questions/156989/how-get-position-from-a-game-object.html

public class PositionDetector : MonoBehaviour
{
    // Dont think the below are needed for anything?
    // private Vector3 posElbow;

    // Declare the gameobjects as public so they can be seen in the inspector
    public GameObject MarkerCube;

    public static Vector3 vecWrist;


    private void Start()
    {
        // find the gameobjects coordinates from unity
        MarkerCube = GameObject.Find("MarkerCube");
        
    }


    void Update()
    {

        vecWrist = MarkerCube.transform.position;


        // This turns the coordinates into vectors
        // Vector3 vec1 = sphereWrist.transform.position - sphereElbow.transform.position;
        // Vector3 vec2 = sphereShoulder.transform.position - sphereElbow.transform.position;

        // calculate and display the angle in the public variable
        // AngleRecording = Vector3.Angle(vec1, vec2);

    }

}
