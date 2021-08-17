# The MIT License (MIT)
#
# Copyright (c) 2017 Niklas Rosenstein
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.

from matplotlib import pyplot as plt
from collections import deque
from threading import Lock, Thread
from datetime import datetime
import socket
import struct
# import global_var

import myo
import numpy as np
import csv
import os
import sys
import time
import copy


'''
Set filename and path
'''
# pathPrefix = str(os.getcwd())

prot_directory = "ProtocolData./"
f = open(prot_directory + "ParticipantID.txt", "r")
ID = str(f.read())
f.close()
# g = open(prot_directory + "Condition.txt", "r")
# condition = str(g.read())
# h = open(prot_directory + "Trial.txt", "r")
# trial = str(h.read())

# Directory
directory = "./Data_ID_%s/" % ID

try:
  os.mkdir(directory)
except OSError as e:
  pass

# pathSuffix = r'\Recorded-Data\Raw_EMG_'
#pathSuffix = r'\thalmicMyo\examples\Recorded-Data\Raw_EMG_'

pathCSV = directory
CSVsuffix = '.csv'
filenameTimeStr = datetime.now().strftime('%Y-%m-%d--%H-%M-%S')

global filename
filename = pathCSV + filenameTimeStr + CSVsuffix


'''
EMG Collector
'''
class EmgCollector(myo.DeviceListener):
  global emgMatrix
  
  def __init__(self, n):
    self.n = n
    self.lock = Lock()
    self.emg_data_queue = deque(maxlen=n)
    
    self.delayCounterEMG = 200    
    self.emgCounter = 0
    self.prevEmgCounter = 0
    
    # Calibration
    self.calib = 0 #NEW
    self.armRelax = np.zeros(8)
    self.armFlex = np.zeros(8)    
    self.armExt = np.zeros(8)        
    self.cocontract = np.zeros(8)  
    self.emgList = [None]
    self.counter = 0
    self.sum_emg_list = deque(maxlen=75)  
    
    # Open CSV file
    global filename
    print(filename)
    
    # Create CSV
    with open(filename, 'w', encoding='UTF8', newline='') as file:    
        writer = csv.writer(file)
        
        header = ['EMG_Pod01', 'EMG_Pod02', 'EMG_Pod03',
                  'EMG_Pod04', 'EMG_Pod05', 'EMG_Pod06',
                  'EMG_Pod07', 'EMG_Pod08', 'Timestamp']  
        writer.writerow(header)
        
    self.f = open(filename, "a")  # Open to append
    
  def get_emg_data(self):
    with self.lock: 
      return self.emgList     
    
  def on_connected(self, event):
    event.device.stream_emg(True)

  def on_emg(self, event):
    with self.lock:      
      dateTimeStr = datetime.now().strftime('%Y-%m-%d %H:%M:%S.%f')
      
      # Save EMG data by appending to tbe end if the CSV
      self.f.write(str(event.emg[0]) + ", " + str(event.emg[1]) + ", "
          + str(event.emg[2]) + ", " + str(event.emg[3]) + ", " + str(event.emg[4]) + ", "
          + str(event.emg[5]) + ", " + str(event.emg[6]) + ", " + str(event.emg[7]) + ", "
          + dateTimeStr + "\n")  # str(event.timestamp) + "\n")
      
      self.counter += 1   
      self.emgList.append([event.emg[0], event.emg[1], event.emg[2],
                           event.emg[3], event.emg[4], event.emg[5],
                           event.emg[6], event.emg[7]])  

      temp_list = copy.deepcopy(self.emgList[self.counter])

      results = [int(i) for i in temp_list]
      res =  [abs(ele) for ele in results]
      temp = (sum(res))
      self.sum_emg_list.append(temp)
      #print('printing')

  def get_packet_emg_data(self):
    with self.lock:
      return self.sum_emg_list


'''
Run EMG
'''
class RunEMG(object):
  def __init__(self, listener):
    self.listener = listener
    self.prevEmgCount = listener.prevEmgCounter
    self.emgCount = listener.emgCounter    

  def main(self):
    sock = socket.socket(socket.AF_INET, # Internet
                                  socket.SOCK_DGRAM) # UDP
    counter = 0        
    while True:
      # Open Myo Exit .txt to read
      prot_directory = "ProtocolData./"
      myof = open(prot_directory + "MyoExit.txt", "r") 
      myofValue = str(myof.read()) 
      myof.close()
      emg_data = self.listener.get_packet_emg_data()
      counter +=1
    #   print(counter)
      if ((counter % 1000) == 0) :
        emg_data = sum(emg_data)/5
        emg_data = str(int(emg_data))
        # print(emg_data)
        sock.sendto(emg_data.encode('utf-8'), ("192.168.1.139", 9050))
        print(emg_data)
      
      if (myofValue == '0'):
        pass
      else:
        print('------------------ Myo System Exit ------------------')        
        sys.exit()
    
'''
main
'''
def main():
  myo.init(sdk_path="C:\\Users\\dicke\\packages\\MyoSDK.2.1.0")
  hub = myo.Hub()
  listener = EmgCollector(1)
  
  with hub.run_in_background(listener.on_event):
    RunEMG(listener).main()
      
    
if __name__ == '__main__': 
  main()
    
  
      
