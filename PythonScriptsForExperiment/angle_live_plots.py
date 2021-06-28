# This scipt plots both angle and angular velocity in real time and stores all the data to a txt file.
# On exit of the app it also displays the plots for the whole trial.

# Minimum script for reading and unpacking messages from UDPComm.cs
import socket
import struct
import matplotlib.pyplot as plt
import matplotlib.animation as animation
import keyboard
import sys


## NOTE: Packet structure from sender script (UDPComm.cs on Hololens):
# private struct PacketOperator_t
# {
    # public float Angle;
    # public float AngularVelocity;
# };


# # if __name__ == '__main__':
# def socket_bind():



#     return sock


def angle_plotting():

    UDP_IP = ""  # No IP specified, as we receive from any IP address (that's on the same subnet, 192.1.168.xxx)
    UDP_PORT = 9995  # Same port as we specified in UDPComm.cs

    sock = socket.socket(socket.AF_INET, # Internet
                         socket.SOCK_DGRAM) # UDP
    sock.bind((UDP_IP, UDP_PORT))

    while True:
        
        # if 0 pressed then read the data packets sent from the hololens and plot the live data
        # if keyboard.read_key() == '0':
        x_len = 300
        y1_range = [0,180]
        y2_range = [-50,50]
        angle = []
        angularVel = []
        fig, axs = plt.subplots(1, 2)
        axs[0].set_xlabel('Samples')
        axs[1].set_xlabel('Samples')
        axs[0].set_ylabel('Angle (deg)')
        axs[1].set_ylabel('Angular Velocity (deg/s)')
        fig.align_xlabels()
        axs[0].set_title('Angle evolution over time')
        axs[1].set_title('Angular velocity evolution over time')
        
        xs = list(range(0,300))
        ys1 = [0]*x_len
        ys2 = [0]*x_len
        
        axs[0].set_ylim(y1_range)
        axs[1].set_ylim(y2_range)

        while True:

            # Create a blank line. We will update the line in animate
            
            line1, = axs[0].plot(xs, ys1)
            line2, = axs[1].plot(xs, ys2)

            def animate(i, ys1, ys2, angle, angularVel):

                data, addr = sock.recvfrom(1024)  # buffr size is 1024 bytes
                # Unpacks two floats from data : angle and angular velocity / append to lists
                unpack = struct.unpack('ff', data)
                angle.append(unpack[0])
                angularVel.append(unpack[1])
                ys1.append(unpack[0])
                ys2.append(unpack[1])
                
                ys1 = ys1[-x_len:]
                ys2 = ys2[-x_len:]

                # Update line with new Y values
                line1.set_ydata(ys1)
                line2.set_ydata(ys2)

                return line1, line2, 
                
            # Set up plot to call animate() function periodically
            ani = animation.FuncAnimation(fig,
                animate,
                fargs=(ys1,ys2,angle,angularVel),
                interval=2,
                blit=True)

            figure = plt.gcf()  # get current figure
            figure.set_size_inches(9, 6) # set figure's size manually to your full screen (32x18)0
            
            plt.show()

            ### On shutting the live plots, it enters here which displays plots for the whole trial
            # and then saves the data to a .txt file.
            
            fig = plt.figure()
            ax = fig.add_subplot(1, 2, 1)
            plt.ylim([0,180])
            plt.xticks(rotation=45, ha='right')
            plt.subplots_adjust(bottom=0.30)
            plt.title('Angle against time')
            plt.ylabel('Angle (degrees)')
            plt.xlabel('Samples')
            ax.plot(angle)
            
            ax = fig.add_subplot(1, 2, 2)
            plt.ylim([-50,50])
            plt.xticks(rotation=45, ha='right')
            plt.subplots_adjust(bottom=0.30)
            plt.title('Angular velocity against time')
            plt.ylabel('Angular velocity (degrees/s)')
            plt.xlabel('Samples')
            ax.plot(angularVel)

            figure = plt.gcf()  # get current figure
            figure.set_size_inches(9, 6) # set figure's size manually to your full screen (32x18)
            plt.savefig('TrialData.png',bbox_inches='tight', dpi=200)
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

              
# def checking_func():
#     while True:
#         print("hello world")
    

if __name__ == '__main__':
    # sock = socket_bind()
    angle_plotting()
    # checking_func()
    
