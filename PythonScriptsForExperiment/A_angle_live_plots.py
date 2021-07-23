from matplotlib import pyplot as plt
import socket
import struct
import csv
import matplotlib.animation as animation
from datetime import datetime

import tkinter as tk 
import tkinter.font as tkFont
import os
import sys
import signal

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

  def save_plot_and_data(self):
      ### On shutting the live plots, it enters here which displays plots for the whole trial
      # and then saves the data to a .csv file.
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
    prot_directory = "ProtocolData./"
    f = open(prot_directory + "ParticipantID.txt", "r")
    ID = str(f.read())
    g = open(prot_directory +"Condition.txt", "r")
    condition = str(g.read())
    h = open(prot_directory +"Trial.txt", "r")
    trial = str(h.read())
    
    directory = "./Data_ID_%s/" % ID
    try:
        os.mkdir(directory)
    except OSError as e:
        print("Directory exists")

    filename_image = "%s_%s_%s_HoloAngle.png" % (ID, condition, trial)
    # Directory
    directory = "./Data_ID_%s/" % ID
    plt.savefig(directory + filename_image ,bbox_inches='tight', dpi=200)

    # field names 
    fields = ['Timestamp','Milliseconds' , 'Angle', 'Angular Velocity'] 
    rows = zip(date_time, milliseconds ,angle, angularVel)
    f = open(prot_directory +"ParticipantID.txt", "r")
    ID = str(f.read())
    g = open(prot_directory +"Condition.txt", "r")
    condition = str(g.read())
    h = open(prot_directory +"Trial.txt", "r")
    trial = str(h.read())
    
    filename_angle = "%s_%s_%s_HoloData.csv" % (ID, condition, trial)

    with open(directory + filename_angle, 'w') as f:
      
        # using csv.writer method from CSV package
        writer = csv.writer(f,delimiter=',')
        writer.writerow(fields)
        for row in rows:
          writer.writerow(row)
    sys.exit()


  def main_plot(self):
    ani = animation.FuncAnimation(self.fig,
        self.animate,
        fargs=(),
        interval=2,
        blit=True)

    figure = plt.gcf()  # get current figure
    figure.set_size_inches(9, 6) # set figure's size manually to your full screen (32x18)0
    
    plt.show()
    self.save_plot_and_data()
    # self.save_and_quit()
        
if __name__ == '__main__':
  prot_directory = "ProtocolData./"
  p = open(prot_directory +"KeyboardInterruptBoolean.txt", "w")
  p.write(str(0))
  p.close()

  Participant_ID = 0
  condition, trial = "default", 0 
  window = tk.Tk() 

  fontStyle_title = tkFont.Font(family="Lucida Grande", size=20)
  fontStyle_ID = tkFont.Font(family="Lucida Grande", size=10)

  lbl_title = tk.Label(window, text="Welcome to the experiment! Please enter the details below:", font=fontStyle_title)
  lbl_title.pack()

  def on_change_ID(e1):
    Participant_ID = e1.widget.get()
    f = open(prot_directory +"ParticipantID.txt", "w")
    f.write(Participant_ID)
    f.close()
    # print(Participant_ID)    

  lbl_ID = tk.Label(window, text = "Participant ID:", font = fontStyle_ID )
  lbl_ID.pack()
  entry_ID = tk.Entry(window)
  entry_ID.pack()    
  # Calling on_change when you press the return key
  entry_ID.bind("<Return>", on_change_ID)  

  def on_change_condition(e2):
      condition = e2.widget.get()
      g = open(prot_directory +"Condition.txt", "w")
      g.write(condition)
      g.close()
      # print(Participant_ID)    

  lbl_ID = tk.Label(window, text = "Condition (fast, medium, or slow):", font = fontStyle_ID )
  lbl_ID.pack()
  entry_ID = tk.Entry(window)
  entry_ID.pack()    
  # Calling on_change when you press the return key
  entry_ID.bind("<Return>", on_change_condition)  

  def on_change_trial(e3):
      trial = e3.widget.get()
      h = open(prot_directory +"Trial.txt", "w")
      h.write(trial)
      h.close()   

  lbl_ID = tk.Label(window, text = "Trial number:", font = fontStyle_ID )
  lbl_ID.pack()
  entry_ID = tk.Entry(window)
  entry_ID.pack()    
  # Calling on_change when you press the return key
  entry_ID.bind("<Return>", on_change_trial)  

  def runFunction():
    p = plotting()
    p.main_plot()
      
  def stopFunction():
    p = open(prot_directory +"KeyboardInterruptBoolean.txt", "w")
    p.write(str(1))
    p.close()
  
  btn_startRecording = tk.Button(
      text="Click me to start recording!",
      width=25,
      height=5,
      bg="blue",
      fg="yellow",
      command = runFunction,
  )
  btn_startRecording.pack()

  btn_stopRecording = tk.Button(
      text="Click me to stop\nrecording and save!",
      width=25,
      height=5,
      bg="blue",
      fg="yellow",
      command = stopFunction,
  )
  btn_stopRecording.pack()


  window.mainloop()
  
