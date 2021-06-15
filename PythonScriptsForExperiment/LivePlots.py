# Minimum script for reading and unpacking messages from UDPComm.cs
import socket
import struct
import matplotlib.pyplot as plt
import numpy as np
import keyboard
import sys

## NOTE: Packet structure from sender script (UDPComm.cs on Hololens):
# private struct PacketOperator_t
# {
    # public float Angle;
    # public float AngularVelocity;
# };

angle = []
angularVel = []
counter = 0
counterList = []

if __name__ == '__main__':
    UDP_IP = ""  # No IP specified, as we receive from any IP address (that's on the same subnet, 192.1.168.xxx)
    UDP_PORT = 9995  # Same port as we specified in UDPComm.cs

    sock = socket.socket(socket.AF_INET, # Internet
                         socket.SOCK_DGRAM) # UDP
    sock.bind((UDP_IP, UDP_PORT))
    
    
    while True:
        
        # if 0 pressed then read the data packets sent from the hololens and plot the live data
        if keyboard.read_key() == '0':
            
            while True:
                
                counter+=1
                counterList.append(counter)
                data, addr = sock.recvfrom(1024)  # buffr size is 1024 bytes
                # Unpacks two floats from data : angle and angular velocity / append to lists 
                unpack = struct.unpack('ff', data)
                angle.append(unpack[0])
                angularVel.append(unpack[1])
                print(angle)

                def live_plotter(counterList,angle):
                    
                    fig = plt.figure()
                    ax = fig.add_subplot(1, 2, 1)
                    plt.ylim([0,180])
                    plt.xticks(rotation=45, ha='right')
                    plt.subplots_adjust(bottom=0.30)
                    plt.title('Angle against time')
                    plt.ylabel('Angle (degrees)')
                    plt.xlabel('psuedo-time')
                    ax.plot(angle[-100:])
                    plt.show()
                    

                if counter%100 == 0:
                    live_plotter(counterList,angle)

        ## Plot and save the data when 1 is pressed 
                if keyboard.is_pressed('1'):
                    plt.close()
                    fig = plt.figure()
                    ax = fig.add_subplot(1, 2, 1)
                    plt.ylim([0,180])
                    plt.xticks(rotation=45, ha='right')
                    plt.subplots_adjust(bottom=0.30)
                    plt.title('Angle against time')
                    plt.ylabel('Angle (degrees)')
                    plt.xlabel('psuedo-time')
                    ax.plot(angle)
                    
                    ax = fig.add_subplot(1, 2, 2)
                    plt.ylim([-30,30])
                    plt.xticks(rotation=45, ha='right')
                    plt.subplots_adjust(bottom=0.30)
                    plt.title('Angular velocity against time')
                    plt.ylabel('Angular velocity (degrees/s)')
                    plt.xlabel('psuedo-time')
                    ax.plot(angularVel)

                    plt.show()

                    ## Write to txt file
                    f = open("TrialData.txt", "w")
                    
                    f.write(str(angle))
                    f.write(",")
                    f.write(str(angularVel))
                    f.write(",")
                    f.close()
                    # Exit the app
                    sys.exit(0)

                    

        
