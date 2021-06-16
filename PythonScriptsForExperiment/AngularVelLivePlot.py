# Attempt number 3 for efficient live plotting
# plots in real time but doesnt store the data

# Minimum script for reading and unpacking messages from UDPComm.cs
import socket
import struct
import matplotlib.pyplot as plt
import matplotlib.animation as animation
import time
import keyboard
import sys

## NOTE: Packet structure from sender script (UDPComm.cs on Hololens):
# private struct PacketOperator_t
# {
    # public float Angle;
    # public float AngularVelocity;
# };


if __name__ == '__main__':
    UDP_IP = ""  # No IP specified, as we receive from any IP address (that's on the same subnet, 192.1.168.xxx)
    UDP_PORT = 9995  # Same port as we specified in UDPComm.cs

    sock = socket.socket(socket.AF_INET, # Internet
                         socket.SOCK_DGRAM) # UDP
    sock.bind((UDP_IP, UDP_PORT))
  
    while True:
        
        # if 0 pressed then read the data packets sent from the hololens and plot the live data
        if keyboard.read_key() == '0':
            x_len = 300
            y_range = [0,180]
            angle = []
            angularVel = []
            fig = plt.figure()
            ax = fig.add_subplot(1, 1, 1)
            xs = list(range(0,300))
            ys = [0]*x_len
            ax.set_ylim(y_range)

            while True:

                # Create a blank line. We will update the line in animate
                line, = ax.plot(xs, ys)

                # Add labels
                plt.title('Angle evolution over time')
                plt.xlabel('Samples')
                plt.ylabel('Angle (deg)')


                def animate(i, ys):

                    data, addr = sock.recvfrom(1024)  # buffr size is 1024 bytes
                    # Unpacks two floats from data : angle and angular velocity / append to lists
                    unpack = struct.unpack('ff', data)
                    ys.append(unpack[0])
                    print(unpack[0])
                    
                    ys = ys[-x_len:]

                    # Update line with new Y values
                    line.set_ydata(ys)

                    return line,
                   
                # Set up plot to call animate() function periodically
                ani = animation.FuncAnimation(fig,
                    animate,
                    fargs=(ys,),
                    interval=2,
                    blit=True)
                plt.show()
                    

        
