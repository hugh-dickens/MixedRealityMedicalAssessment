# Minimum script for reading and unpacking messages from UDPComm.cs
import socket
import struct
import matplotlib.pyplot as plt
import matplotlib.animation as animation
from matplotlib import style
import time

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
        data, addr = sock.recvfrom(1024)  # buffr size is 1024 bytes
        
        # Unpacks two floats from data : angle and angular velocity
        unpack = struct.unpack('ff', data)
        print(unpack[0])
        print(unpack[1])

        ### Attempt at plotting to figure, this may be easier to do in a seperate python scipt. at the moment just plots and waits to be shut doesnt
        # live plot.

        fig = plt.figure()
        ax = fig.add_subplot(1, 1, 1)

        def animate(i, xs, ys):

            # Format plot
            ax.plot(xs, label="Angle")
            ax.plot(ys, label="Angular Velocity")
            plt.ylim([-50,50])
            plt.xticks(rotation=45, ha='right')
            plt.subplots_adjust(bottom=0.30)
            plt.title('Vals')
            plt.ylabel('Angle')
            plt.xlabel('Time')
            plt.legend()

        time.sleep(0.3)
        ani = animation.FuncAnimation(fig, animate, fargs=(unpack[0], unpack[1]), interval=10)
        plt.show()
        

