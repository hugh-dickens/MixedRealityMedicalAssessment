using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class GetAngularVelocity : MonoBehaviour
{
    public Vector3 Angular;
    public TextMeshPro AngularPrinting;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        Angular = GetComponent<Rigidbody>().angularVelocity;
        AngularPrinting.SetText(Angular.ToString());
    }
}
