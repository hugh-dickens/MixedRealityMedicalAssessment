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

from collections import deque
from threading import Lock, Thread
from datetime import datetime

import myo
import numpy as np
import csv
import os
import sys

class EmgCollector(myo.DeviceListener):
  def __init__(self, n):
    self.n = n
    self.lock = Lock()
    self.emg_data_queue = deque(maxlen=n)
    self.emgList = [None]

  def on_connected(self, event):
    event.device.stream_emg(True)


  def on_emg(self, event):
    with self.lock:
      dateTimeStr = datetime.now().strftime('%Y-%m-%d %H:%M:%S.%f')
      #self.emg_data_queue.append((dateTimeObj, event.emg))
      if self.emgList[0] == None: # If list is empty
        self.emgList[0] =  [['EMG_Pod01'], ['EMG_Pod02'], ['EMG_Pod03'],
                            ['EMG_Pod04'], ['EMG_Pod05'], ['EMG_Pod06'],
                            ['EMG_Pod07'], ['EMG_Pod08'], ['Timestamp']]   
      self.emgList.append([event.emg[0], event.emg[1], event.emg[2],
                           event.emg[3], event.emg[4], event.emg[5],
                           event.emg[6], event.emg[7], dateTimeStr])
      
    
    
  def get_emg_data(self):
    with self.lock: 
      return self.emgList      
    
'''
Save arrays into CSV file
'''
class SaveRoutine(object):
  def __init__(self, dataA): #, listenerB):
    self.dataA = dataA
    #self.listenerB = listenerB    

  def save_to_CSV(self):  
    # field names 
    fields = ['EMG 1', 'EMG 2', 'EMG 3', 'EMG 4', 'EMG 5', 'EMG 6', 'EMG 7', 'EMG 8', 'Timestamp'] 
    
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

    filename_EMG = "%s_%s_%s_EMGCalibration.csv" % (ID, condition, trial)
      
    with open(directory + filename_EMG, 'w', encoding = 'UTF8', newline = '') as f:
        writer = csv.writer(f)
        # write the header
        writer.writerow(fields)
        # write multiple rows
        writer.writerows(rows) 
    # sys.exit()

def main():
  myo.init(sdk_path="C:\\Users\\dicke\\packages\\MyoSDK.2.1.0")
  hub = myo.Hub()
  listener = EmgCollector(1)

  try:
    with hub.run_in_background(listener.on_event):
        while True:
            f = open(prot_directory + "KeyboardInterruptBoolean.txt", "r")
            keyboardVariable = str(f.read())
            if (keyboardVariable == "1"):
                raise KeyboardInterrupt
                    ### Could try just saving the data here
            else:
                pass  
  except KeyboardInterrupt:
    emgMatrix = listener.get_emg_data()
    SaveRoutine(emgMatrix).save_to_CSV()

if __name__ == '__main__':
    while True:
        prot_directory = "ProtocolData./"
        f = open(prot_directory + "StartCalibrating.txt", "r")
        runVariablecalib = str(f.read())
        ## if script A writes a 1 to the .txt file then a keyboard interrupt will be thrown to stop recording emg data
        if (runVariablecalib == "1"):
            main()
  