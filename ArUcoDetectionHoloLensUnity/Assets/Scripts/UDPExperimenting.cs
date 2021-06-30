using System.Collections;
using System.Collections.Generic;
using System;
using System.Net;
using System.Net.Sockets;
using System.Text;
using UnityEngine;
using TMPro;

public class UDPExperimenting : MonoBehaviour
{

    public int EMG = 0;
    public TextMeshPro EMG_Value;
    public TextMeshPro Debugger_text;
    public static void Main()
    {
        byte[] data = new byte[1024];
        IPEndPoint ipep = new IPEndPoint(IPAddress.Any, 9995);
        UdpClient newsock = new UdpClient(ipep);

        Console.WriteLine("Waiting for a client...");

        IPEndPoint sender = new IPEndPoint(IPAddress.Any, 0);

        data = newsock.Receive(ref sender);

        Console.WriteLine("Message received from {0}:", sender.ToString());
        Console.WriteLine(Encoding.ASCII.GetString(data, 0, data.Length));

        string welcome = "Welcome to my test server";
        data = Encoding.ASCII.GetBytes(welcome);
        newsock.Send(data, data.Length, sender);

        while (true)
        {
            data = newsock.Receive(ref sender);

            Console.WriteLine(Encoding.ASCII.GetString(data, 0, data.Length));
            newsock.Send(data, data.Length, sender);
        }
    }
}
