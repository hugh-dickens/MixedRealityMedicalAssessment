## Script used to stream EMG data to the hololens interface
import socket
import struct
from collections import deque
from threading import Lock, Thread
from datetime import datetime

import myo
import numpy as np
import csv
# import tkinter as tk 
# import tkinter.font as tkFont
import os
# from pynput.keyboard import Key, Controller
import sys
import time
import copy

class EmgCollector(myo.DeviceListener):
  """
  Collects EMG data in a queue with *n* maximum number of elements.
  """

  def __init__(self, n):
    self.n = n
    self.lock = Lock()
    self.emg_data_queue = deque(maxlen=n)
    self.emgList = [None]
    self.counter = 0
    self.sum_emg_list= deque(maxlen=75) 

  def get_emg_data(self):
    with self.lock: 
      return self.emgList  

  def get_packet_emg_data(self):
    with self.lock:
      return self.sum_emg_list 
      ########### CHECK THIS
      #return list(self.emgList) this wasnt actually there 

  def on_connected(self, event):
    event.device.stream_emg(True)

  def on_emg(self, event):
    
    with self.lock:
      dateTimeStr = datetime.now().strftime('%Y-%m-%d %H:%M:%S.%f')
      dateTime = dateTimeStr[:19]
      millis = dateTimeStr[20:]
      #self.emg_data_queue.append((dateTimeObj, event.emg))
      if self.emgList[0] == None: # If list is empty
        self.emgList[0] =  [0, 0, 0,
                            0,0, 0,
                            0, 0, 0] 
        pass
        # self.emgList[0] =  [['EMG_Pod01'], ['EMG_Pod02'], ['EMG_Pod03'],
        #                     ['EMG_Pod04'], ['EMG_Pod05'], ['EMG_Pod06'],
        #                     ['EMG_Pod07'], ['EMG_Pod08'], ['Timestamp']]
      self.counter+=1   
      self.emgList.append([event.emg[0], event.emg[1], event.emg[2],
                           event.emg[3], event.emg[4], event.emg[5],
                           event.emg[6], event.emg[7], dateTime, millis])
      temp_list = copy.deepcopy(self.emgList[self.counter])
      temp_list.pop()
      temp_list.pop()
      results = [int(i) for i in temp_list]
      res =  [abs(ele) for ele in results]
      temp = (sum(res))
      self.sum_emg_list.append(temp)

class SaveRoutine(object):
  def __init__(self, dataA): #, listenerB):
    self.dataA = dataA
    #self.listenerB = listenerB    

  def save_to_CSV(self):  
    # field names 
    fields = ['EMG 1', 'EMG 2', 'EMG 3', 'EMG 4', 'EMG 5', 'EMG 6', 'EMG 7', 'EMG 8', 'Timestamp', 'Milliseconds'] 
    
    # data rows of csv file 
    rows = self.dataA[1:len(self.dataA)]
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
      
    with open(directory + filename_EMG, 'w', encoding = 'UTF8', newline = '') as f:
        writer = csv.writer(f)
        # write the header
        writer.writerow(fields)
        # write multiple rows
        writer.writerows(rows) 
        
    if int(trial) >=20:
      print('-------------------quitting file--------------------')
      sys.exit()

class packet(object):

  def __init__(self, listener):
    self.n = listener.n
    self.listener = listener
    self.emg_data_packet = []

  def main(self):
    prot_directory = "ProtocolData./"
    try:
      sock = socket.socket(socket.AF_INET, # Internet
                                  socket.SOCK_DGRAM) # UDP
      counter = 0
      while True:
        emg_data = self.listener.get_packet_emg_data()
        counter +=1
        if ((counter % 800000) == 0) :
          emg_data = sum(emg_data)/5
          emg_data = str(int(emg_data))
          # print(emg_data)
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
      emgMatrix = self.listener.get_emg_data()
      SaveRoutine(emgMatrix).save_to_CSV()

def main():
  ### enter the path to your own MyoSDK package and .dll file here. Download 
  # with Nuget @ https://www.nuget.org/packages/MyoSDK/2.1.0 and insert .dll file within
  # /bin folder if required.
  myo.init(sdk_path="C:\\Users\\dicke\\packages\\MyoSDK.2.1.0")
  hub = myo.Hub()
  listener = EmgCollector(1)   # TRY changing this to different values - see what happens
  with hub.run_in_background(listener.on_event):
    packet(listener).main()


if __name__ == '__main__':
  while True:
    prot_directory = "ProtocolData./"
    f = open(prot_directory + "StartRunning.txt", "r")
    runVariableMyo = str(f.read())
    ## if script A writes a 1 to the .txt file then a keyboard interrupt will be thrown to stop recording emg data
    if (runVariableMyo == "1"):
      main()
    elif (runVariableMyo == "0"):
      time.sleep(1)

  