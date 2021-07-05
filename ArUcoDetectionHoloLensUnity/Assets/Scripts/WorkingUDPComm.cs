using Microsoft.MixedReality.Toolkit;
using System.Net;
using System.Net.Sockets;
using System.Runtime.Serialization.Formatters.Binary;
using System.Text;
using UnityEngine;
using System.Collections;
using System;
using System.Runtime.InteropServices;
using TMPro;

public class WorkingUDPComm : MonoBehaviour
{
    // Define the UDP packet structure
    private struct PacketOperator_t
    {
        public float AngleValue;
        public float AngularValue;
    };

    //private IPEndPoint udp_send;
    private UdpClient udp;
    private UdpClient client;
    private string dst_ip;
    private byte[] udp_data;
    private DateTime time_check;
    private PacketOperator_t udp_packet;
    private BinaryFormatter msgFormatter;

    public float EMG;
    public TextMeshPro EMG_Value;
    public TextMeshPro Debugger_text;

    Renderer rend;

    // Start() is called before the first frame update
    void Start()
    {
        msgFormatter = new BinaryFormatter();
        Debug.Log("UDP Starting");
        time_check = new DateTime();

        // HARD-CODED IP - you will need to either change this to your PC's IP, or change your PC's IP to this.
        // The Hololens and PC will need to be on the same subnet to be able to talk to each other,
        // e.g. Hololens 192.168.1.139, PC 192.168.1.100. Achieved through setting manual IPs.
        // DNS and default gateway for a manual IP is 192.168.1.254 I think... netmask is 255.255.255.0, or simply '24'
        dst_ip = "192.168.1.100";

        // Port that the UDP link will try communicate with on your PC
        // You may need to adjust your firewall to allow traffic on this port.
        int client_port = 9995;
        int rxPort = 9050;

        udp = new UdpClient(dst_ip, client_port);
        client = new UdpClient(rxPort);

        // Initialise the UDP packet
        udp_packet = new PacketOperator_t();
        udp_packet.AngleValue = 0.0f;
        udp_packet.AngularValue = 0.0f;

        Debugger_text.SetText("Normalised EMG:");

        rend = GetComponent<Renderer>();
        rend.material.SetColor("_Color", new Color(0, 1, .2f)); // start green 

    }

    // Update is called once per frame
    void Update()
    {
        // Using timestamp checks to send messages when there is new eye data only.
        // Hololens update rate (120Hz) is higher than eye gaze update rate (30Hz).
        // This is an optional step if you are just streaming data. - removed for my application
        //DateTime curr_time;
        //curr_time = CoreServices.InputSystem.EyeGazeProvider.Timestamp; // output at system rate (~30Hz)

        //if (!curr_time.Equals(time_check))
        //{
        // Convert udp packet to raw bytes
        byte[] udp_bytes = getBytes(udp_packet);

        // Send
        udp.Send(udp_bytes, udp_bytes.Length);

        
        IPEndPoint anyIP = new IPEndPoint(IPAddress.Any, 0);
        byte[] data = client.Receive(ref anyIP);
        string text = Encoding.UTF8.GetString(data);
        
        float EMG = float.Parse(text);
        EMG -= 300;
        EMG *= 0.003f;
        EMG_Value.SetText(EMG.ToString());
        // EMG_Value.SetText(text);

        //}
        //time_check = curr_time;
        rend.material.SetColor("_Color", new Color(EMG, 1 - EMG, 0));

    }

    public void SetAngleValue(float msg)
    {
        // External scripts have access to this method, used for updating the udp packet data.
        udp_packet.AngleValue = msg;
    }

    public void SetAngularValue(float msg)
    {
        // External scripts have access to this method, used for updating the udp packet data.
        udp_packet.AngularValue = msg;
    }

    // Method to convert UDP packet to bytes
    private byte[] getBytes(PacketOperator_t msg)
    {
        int size = Marshal.SizeOf(msg);
        byte[] arr = new byte[size];

        IntPtr ptr = Marshal.AllocHGlobal(size);
        Marshal.StructureToPtr(msg, ptr, true);
        Marshal.Copy(ptr, arr, 0, size);
        Marshal.FreeHGlobal(ptr);
        return arr;
    }

}
