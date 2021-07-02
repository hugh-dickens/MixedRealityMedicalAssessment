using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class ChangeColour : MonoBehaviour
{
    Renderer rend;
    public TextMeshPro val;
    public GameObject EMG_interface;
    private UDPComm udp_script;
    private void Start()
    {
        udp_script = EMG_interface.GetComponent<UDPComm>();
        rend = GetComponent<Renderer>();
        rend.material.SetColor("_Color", new Color(0, 1, .2f)); // start green
    }
    private void Update()
    {
        
        //float EMG_Colour = udp_script.EMG;
        val.SetText(udp_script.EMG.ToString());
        
        // new Color(redFloat, greenFloat, blueFloat)
        // will customise this to reflect EMG high as red, low as green
        // e.g. (redFloat * EMG, 1+(-greenFloat)*EMG, blueFloat)
        //rend.material.SetColor("_Color", new Color( EMG_Colour, 1 - EMG_Colour, 0.2f));
        
    }
}
