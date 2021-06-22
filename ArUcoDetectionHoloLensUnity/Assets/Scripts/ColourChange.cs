using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ColourChange : MonoBehaviour
{

    public GameObject sphere;
    // Start is called before the first frame update
    void Start()
    {
        sphere = GameObject.Find("EMG Colour Sphere");
    }

    // Update is called once per frame
    void Update()
    {
        sphere.GetComponent<Renderer>().material.color = new Color(0, 1, 0, 1);
    }
}
