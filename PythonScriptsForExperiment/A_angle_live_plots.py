from matplotlib import pyplot as plt
import socket
import struct
import csv
import matplotlib.animation as animation
from datetime import datetime

import tkinter as tk 
import tkinter.font as tkFont


class AngleCollector():
  """
  Collects angle data in a queue with *n* maximum number of elements.
  """

  def __init__(self):

    self.UDP_IP = ""  # No IP specified, as we receive from any IP address (that's on the same subnet, 192.1.168.xxx)
    self.UDP_PORT = 9995  # Same port as we specified in UDPComm.cs

    self.sock = socket.socket(socket.AF_INET, # Internet
                         socket.SOCK_DGRAM) # UDP
    self.sock.bind((self.UDP_IP, self.UDP_PORT))
    self.angle = []
    self.angularVel =[]
    self.x_len = 300
    self.ys1 = [0]*self.x_len
    self.ys2 = [0]*self.x_len
    self.x = 0
    self.y = 0
    self.date_time_list =[]
    self.milliseconds = []


  def get_angle_data(self):
    data, addr = self.sock.recvfrom(1024)  # buffr size is 1024 bytes
    # Unpacks two floats from data : angle and angular velocity / append to lists
    unpack = struct.unpack('ff', data)
    self.angle.append(unpack[0])
    self.angularVel.append(unpack[1])
    self.ys1.append(unpack[0])
    self.ys2.append(unpack[1])
    datetime_object_angle = str(datetime.now())
    dt_object2 = datetime_object_angle[11:]
    dt_object3 = datetime_object_angle[20:]
    self.date_time_list.append(dt_object2)
    self.milliseconds.append(dt_object3)

# FOR CHECKING WITHOUT THE HOLOLENS 
    # self.x +=0.01
    # self.y +=0.01
    # self.angle.append(self.x)
    # self.angularVel.append(self.y)
    # self.ys1.append(self.x)
    # self.ys2.append(self.y)
    
    self.ys1 = self.ys1[-self.x_len:]
    self.ys2 = self.ys2[-self.x_len:]

    return self.ys1, self.ys2 

  def get_final_data(self):
    return self.date_time_list, self.milliseconds,  self.angle, self.angularVel

class plotting(AngleCollector):

  def __init__(self):
    # setup the axes/ graphs
    self.AngleCollector = AngleCollector()
    self.x_len = 300
    self.y1_range = [0,180]
    self.y2_range = [-50,50]
    self.x_len = 300
    self.ys1 = [0]*self.x_len
    self.ys2 = [0]*self.x_len
    # self.fig, self.axs = plt.subplots(2, 2)
    self.fig, self.axs = plt.subplots(1, 2)
    self.axs[0].set_xlabel('Samples')
    self.axs[1].set_xlabel('Samples')
    self.axs[0].set_ylabel('Angle (deg)')
    self.axs[1].set_ylabel('Angular Velocity (deg/s)')
    self.fig.align_xlabels()
    self.axs[0].set_title('Angle evolution over time')
    self.axs[1].set_title('Angular velocity evolution over time')
    
    self.xs = list(range(0,300))
    
    self.axs[0].set_ylim(self.y1_range)
    self.axs[1].set_ylim(self.y2_range)

    self.line1, = self.axs[0].plot(self.xs, self.ys1)
    self.line2, = self.axs[1].plot(self.xs, self.ys2)


  def animate(self,i):
    ys1, ys2 = self.AngleCollector.get_angle_data()
    # Update line with new Y values
    self.line1.set_ydata(ys1)
    self.line2.set_ydata(ys2)

    return self.line1, self.line2,  ## this line might not be needed

  def plot_final(self,Participant_ID):
      ### On shutting the live plots, it enters here which displays plots for the whole trial
      # and then saves the data to a .txt file.
    date_time, milliseconds, angle, angularVel = self.AngleCollector.get_final_data()
    fig = plt.figure(1)
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
    ID = str(Participant_ID)
    filename_image = "TrialData_%s.png" % ID
    plt.savefig(filename_image ,bbox_inches='tight', dpi=200)
    plt.show()

  def save_and_quit(self, Participant_ID):
    
    date_time, milliseconds, angle, angularVel = self.AngleCollector.get_final_data()

    # field names 
    fields = ['Timestamp','Milliseconds' , 'Angle', 'Angular Velocity'] 
    rows = zip(date_time, milliseconds ,angle, angularVel)

    ID = str(Participant_ID)
    filename_angle = "AngleData_%s.csv" % ID
      
    with open(filename_angle, 'w') as f:
        # using csv.writer method from CSV package
        writer = csv.writer(f,delimiter=',')
        writer.writerow(fields)
        # for word in yourList:
        #   wr.writerow([word])
        for row in rows:
          writer.writerow(row)


  def main(self,Participant_ID):
    ani = animation.FuncAnimation(self.fig,
        self.animate,
        fargs=(),
        interval=2,
        blit=True)

    figure = plt.gcf()  # get current figure
    figure.set_size_inches(9, 6) # set figure's size manually to your full screen (32x18)0
    
    plt.show()

    self.plot_final(Participant_ID)
    self.save_and_quit(Participant_ID)


def main(Participant_ID):
    # listener = AngleCollector()
    plotting().main(Participant_ID)
        
if __name__ == '__main__':
  Participant_ID = 0
  window = tk.Tk() 

  fontStyle_title = tkFont.Font(family="Lucida Grande", size=20)
  fontStyle_ID = tkFont.Font(family="Lucida Grande", size=10)

  lbl_title = tk.Label(window, text="Welcome to the experiment for angle live plotting!", font=fontStyle_title)
  lbl_title.pack()


  def on_change(e):
    Participant_ID = e.widget.get()
    print(e.widget.get())

  lbl_ID = tk.Label(window, text = "Participant ID:", font = fontStyle_ID )
  lbl_ID.pack()
  entry_ID = tk.Entry(window)
  entry_ID.pack()    
  # Calling on_change when you press the return key
  entry_ID.bind("<Return>", on_change)  

  def runFunction():
    main(Participant_ID)
      
  btn_startRecording = tk.Button(
      text="Click me to start recording!",
      width=25,
      height=5,
      bg="blue",
      fg="yellow",
      command = runFunction,
  )
  btn_startRecording.pack()

  window.mainloop()
  
