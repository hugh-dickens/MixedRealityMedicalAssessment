# Minimum script for reading and unpacking messages from UDPComm.cs
import socket
import struct

## NOTE: Packet structure from sender script (UDPComm.cs on Hololens):
# private struct PacketOperator_t
# {
    # public double mentalLoad;
    # public byte askMode;
# };

if __name__ == '__main__':
    UDP_IP = ""  # No IP specified, as we receive from any IP address (that's on the same subnet, 192.1.168.xxx)
    UDP_PORT = 9995  # Same port as we specified in UDPComm.cs

    sock = socket.socket(socket.AF_INET, # Internet
                         socket.SOCK_DGRAM) # UDP
    sock.bind((UDP_IP, UDP_PORT))

    while True:
        data, addr = sock.recvfrom(1024)  # buffr size is 1024 bytes
        # See link above for more info on formatting the unpack method
        # the data received is indexed 0:17 as I found UDPComm.cs padded the message for some reason
        # you may need to test this out a bit to get it working, as I'm pretty sure it should just be 'db', but can't test this now.
        # if successful, print(unpack) should output a float and a signed integer that is -1 or 1.
        #print(data)
        #print(len(data))
        unpack = struct.unpack('ff', data)

        
        print(unpack(1))
        
