using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class PositionText : MonoBehaviour
{
    public int MarkerID = 0;
    // Start is called before the first frame update
    void Start()
    {
        
    }
    // Update is called once per frame
    void Update()
    {
        TextMeshProUGUI textmeshPro = GetComponent<TextMeshProUGUI>();
        //textmeshPro.SetText(MarkerID.ToString());
    }
}
