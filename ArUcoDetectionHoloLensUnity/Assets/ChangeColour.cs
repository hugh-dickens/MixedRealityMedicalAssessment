using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ChangeColour : MonoBehaviour
{
    Renderer rend;
    // Start is called before the first frame update
    void Start()
    {
        rend = GetComponent<Renderer>();
        rend.material.SetColor("_Color", new Color(0, 1, .2f)); // start green
        
    }

    // Update is called once per frame
    void Update()
    {
        // find the UDP game object/ script so that EMG value can be found and used for colour of sphere
        GameObject go = GameObject.Find("UDPComm");
        UDPExperimenting cs = go.GetComponent<UDPExperimenting>();
        float EMG_Colour = cs.EMG * 0.001f;
        // new Color(redFloat, greenFloat, blueFloat)
        // will customise this to reflect EMG high as red, low as green
        // e.g. (redFloat * EMG, 1+(-greenFloat)*EMG, blueFloat)
        rend.material.SetColor("_Color", new Color(0.2f * EMG_Colour, 1 + (-0.2f) * EMG_Colour, 0.2f));
        
    }
}
