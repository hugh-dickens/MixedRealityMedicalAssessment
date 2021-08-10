
import socket
import struct
import csv
from datetime import datetime

import os
import sys
import signal
import time

class AngleCollector():
  """
  Collects angle data in a queue with *n* maximum number of elements.
  """

  def __init__(self):

    self.UDP_IP = ""  # No IP specified, as we receive from any IP address (that's on the same subnet, 192.1.168.xxx)
    self.UDP_PORT = 9995  # Same port as we specified in UDPComm.cs

    self.sock = socket.socket(socket.AF_INET, # Internet
                        socket.SOCK_DGRAM) # UDP
    self.sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    self.sock.bind((self.UDP_IP, self.UDP_PORT))
    self.angle = []
    self.angularVel =[]
    self.date_time_list =[]
    self.milliseconds = []


  def get_angle_data(self):
    data, addr = self.sock.recvfrom(1024)  # buffr size is 1024 bytes
    # Unpacks two floats from data : angle and angular velocity / append to lists
    unpack = struct.unpack('ff', data)
    self.angle.append(unpack[0])
    self.angularVel.append(unpack[1])
    datetime_object_angle = str(datetime.now())
    dt_object2 = datetime_object_angle[11:]
    dt_object3 = datetime_object_angle[20:]
    self.date_time_list.append(dt_object2)
    self.milliseconds.append(dt_object3)
    f = open(prot_directory+"KeyboardInterruptBoolean.txt", "r")
    keyboardVariableHolo = str(f.read())
    ## if script A writes a 1 to the .txt file then a keyboard interrupt will be thrown to stop recording polhemus data
    if (keyboardVariableHolo == "1"):
        raise KeyboardInterrupt
    else:
        pass

  def get_final_data(self):
    return self.date_time_list, self.milliseconds,  self.angle, self.angularVel

  def save_and_quit(self):
    date_time, milliseconds, angle, angularVel = self.get_final_data()

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

    # Directory
    directory = "./Data_ID_%s/" % ID

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
    try:
        while True:
            self.get_angle_data()
    except KeyboardInterrupt:
        self.save_and_quit()

            
if __name__ == '__main__':
  counter_bool = True
  while True:
    prot_directory = "ProtocolData./"
    f = open(prot_directory + "StartRunning.txt", "r")
    runVariableHolo = str(f.read())
    ## if script A writes a 1 to the .txt file then a keyboard interrupt will be thrown to stop recording emg data
    if (runVariableHolo == "1" and counter_bool == True):
        counter_bool == False
        A = AngleCollector()
        A.main_plot()
    elif(runVariableHolo == "1" and counter_bool == False):
        A.main_plot()
    elif (runVariableHolo == "0"):
      time.sleep(1)
  
