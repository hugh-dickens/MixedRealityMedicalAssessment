# Minimum script for reading and unpacking messages from UDPComm.cs 
# this scipt has been integrated into 01_main_scipt.py
import socket
import struct

## NOTE: Packet structure from sender script (UDPComm.cs on Hololens):
# private struct PacketOperator_t
# {
    # public float Angle;
    # public float AngularVelocity;
# };

angle = []
angularVel = []

if __name__ == '__main__':
    UDP_IP = ""  # No IP specified, as we receive from any IP address (that's on the same subnet, 192.1.168.xxx)
    UDP_PORT = 9995  # Same port as we specified in UDPComm.cs

    sock = socket.socket(socket.AF_INET, # Internet
                         socket.SOCK_DGRAM) # UDP
    sock.bind((UDP_IP, UDP_PORT))

    while True:

        data, addr = sock.recvfrom(1024)  # buffr size is 1024 bytes
        # Unpacks two floats from data : angle and angular velocity
              
        print(data)
        unpack = struct.unpack('c', data)
        
        # print(unpack)
        # unpack = struct.unpack('ff', data)
        # angle.append(unpack[0])
        # angularVel.append(unpack[1])

            
        

        

        
