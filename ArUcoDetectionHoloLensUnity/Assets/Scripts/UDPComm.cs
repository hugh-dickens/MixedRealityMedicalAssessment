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

public class UDPComm : MonoBehaviour
{
    // Define the UDP packet structure
    private struct PacketOperator_t
    {
        public float AngleValue;
        public float AngularValue;
    };

    //private IPEndPoint udp_send;
    private UdpClient udp;
    private string dst_ip;
    private byte[] udp_data;
    private DateTime time_check;
    private PacketOperator_t udp_packet;
    private BinaryFormatter msgFormatter;

    // CHANGES - instead want to edit another EMG value with this received val.
    public int EMG = 0;
    public TextMeshPro EMG_Value;
    public TextMeshPro Debugger_text;

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
        //dst_ip = "192.168.1.100";
        
        // Port that the UDP link will try communicate with on your PC
        // You may need to adjust your firewall to allow traffic on this port.
        //int client_port = 9995;

        //udp = new UdpClient(dst_ip, client_port);

        // Initialise the UDP packet
        udp_packet = new PacketOperator_t();
        udp_packet.AngleValue = 0.0f;
        udp_packet.AngularValue = 0.0f;

        }

    // Update is called once per frame
    void Update()
    {
        //Creates a UdpClient for reading incoming data.
        UdpClient receivingUdpClient = new UdpClient(11000);

        //Creates an IPEndPoint to record the IP Address and port number of the sender.
        // The IPEndPoint will allow you to read datagrams sent from any source.
        IPEndPoint RemoteIpEndPoint = new IPEndPoint(IPAddress.Any, 0);
        try
        {

            // Blocks until a message returns on this socket from a remote host.
            Byte[] receiveBytes = receivingUdpClient.Receive(ref RemoteIpEndPoint);

            string returnData = Encoding.ASCII.GetString(receiveBytes);
            EMG_Value.SetText(returnData);

        }
        catch (Exception e)
        {
            Console.WriteLine(e.ToString());
        }

        //time_check = curr_time;

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

