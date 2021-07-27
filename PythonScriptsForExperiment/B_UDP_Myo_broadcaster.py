## Script used to stream EMG data to the hololens interface
import socket
import struct
from collections import deque
from threading import Lock, Thread
from datetime import datetime

import myo
import numpy as np
import csv
import tkinter as tk 
import tkinter.font as tkFont
import os
from pynput.keyboard import Key, Controller
import sys
import time

class EmgCollector(myo.DeviceListener):
  """
  Collects EMG data in a queue with *n* maximum number of elements.
  """

  def __init__(self, n):
    self.n = n
    self.lock = Lock()
    self.emg_data_queue = deque(maxlen=n)

  def get_emg_data(self):
    with self.lock:
      return list(self.emg_data_queue)

  def on_connected(self, event):
    event.device.stream_emg(True)

  def on_emg(self, event):
    with self.lock:
      self.emg_data_queue.append((event.timestamp, event.emg))
      

class packet(object):

  def __init__(self, listener):
    self.n = listener.n
    self.listener = listener
    self.emg_data_packet = []
    self.emg_total = []

  def update_packet(self):
    emg_data = self.listener.get_emg_data()
    emg_data = np.array([x[1] for x in emg_data]).T
    emg_data = abs(emg_data)
    temp_list = []
    if len(emg_data) == 8:
      datetime_object = str(datetime.now())
      dt_object1 = datetime_object[11:]
      dt_object_ms = datetime_object[20:]
      emg_ave = [sum(i) for i in emg_data]
      temp_list.append(dt_object1)
      temp_list.append(dt_object_ms)
      temp_list.extend(emg_ave)
      self.emg_total.append(temp_list)
      # print(self.emg_total)
      return (emg_data.sum(axis=0)).sum(axis=0)

  def save_and_quit_EMG(self):

    # field names 
    fields = ['Timestamp', 'Milliseconds','EMG 1', 'EMG 2', 'EMG 3', 'EMG 4', 'EMG 5', 'EMG 6', 'EMG 7', 'EMG 8'] 
    
    # data rows of csv file 
    rows = self.emg_total
    prot_directory = "ProtocolData./"
    f = open(prot_directory + "ParticipantID.txt", "r")
    ID = str(f.read())
    g = open(prot_directory + "Condition.txt", "r")
    condition = str(g.read())
    h = open(prot_directory + "Trial.txt", "r")
    trial = str(h.read())

    # Directory
    directory = "./Data_ID_%s/" % ID
  
    try:
        os.mkdir(directory)
    except OSError as e:
        print("Directory exists")

    filename_EMG = "%s_%s_%s_EMG.csv" % (ID, condition, trial)

    # with open(directory + filename_GUI, 'w') as f:
      
    with open(directory + 'temp.csv', 'w') as f:
        # using csv.writer method from CSV package
        write = csv.writer(f)
        write.writerow(fields)
        write.writerows(rows)
    ## remove duplicate data:
    from more_itertools import unique_everseen
    
    with open(directory + 'temp.csv','r') as f, open(directory + filename_EMG,'w') as out_file:
      out_file.writelines(unique_everseen(f))
    # delete the temp file
    ## check this for errors
    os.remove(directory + 'temp.csv')
    sys.exit()


  def main(self):
    prot_directory = "ProtocolData./"
    try:
      sock = socket.socket(socket.AF_INET, # Internet
                                  socket.SOCK_DGRAM) # UDP
      counter = 0
      
      while True:
        ### read the keyboard interrupt boolean variable from script A.
        emg_data = self.update_packet()
        counter +=1
        if ((counter % 5000) == 0) & (emg_data is not None):
          print(emg_data)
          emg_data = str(emg_data)
          sock.sendto(emg_data.encode('utf-8'), ("192.168.1.139", 9050))   
          f = open(prot_directory + "KeyboardInterruptBoolean.txt", "r")
          keyboardVariable = str(f.read())
          ## if script A writes a 1 to the .txt file then a keyboard interrupt will be thrown to stop recording emg data
          if (keyboardVariable == "1"):
            raise KeyboardInterrupt
          ### Could try just saving the data here
          else:
            pass  
            # print(self.emg_total)       
            # REmember this should be the holo ip
            # Same port as we specified in UDPComm.cs 
    except KeyboardInterrupt:
      self.save_and_quit_EMG()  

def main():
  ### enter the path to your own MyoSDK package and .dll file here. Download 
  # with Nuget @ https://www.nuget.org/packages/MyoSDK/2.1.0 and insert .dll file within
  # /bin folder if required.
  myo.init(sdk_path="C:\\Users\\dicke\\packages\\MyoSDK.2.1.0")
  hub = myo.Hub()
  listener = EmgCollector(10)   # TRY changing this to different values - see what happens
  with hub.run_in_background(listener.on_event):
    packet(listener).main()


if __name__ == '__main__':
  while True:
    prot_directory = "ProtocolData./"
    f = open(prot_directory + "StartRunning.txt", "r")
    runVariable = str(f.read())
    ## if script A writes a 1 to the .txt file then a keyboard interrupt will be thrown to stop recording emg data
    if (runVariable == "1"):
      main()

  