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
  
  def print_emg(self):
    #print(list(self.emg_data_queue).index(2))   
    print(" ")
    #print(self.emgList)
    
    
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
    #print(type(self.dataA))
    breakpoint()
    header = self.dataA[0]
    data = self.dataA[1:len(self.dataA)]
    
    pathPrefix = str(os.getcwd())
    pathSuffix = '\Data_ID_2\Raw_CSV_'
    
    pathCSV = pathPrefix +  pathSuffix
    CSVsuffix = '.csv'
    filenameTimeStr = datetime.now().strftime('%Y-%m-%d--%H-%M-%S')
    
    filename = pathCSV + filenameTimeStr + CSVsuffix
    print (filename)
    
    #with open('C:/Users/pzhan/Desktop/Myo-CV-Spasticity-Assessment/thalmicMyo/examples/Recorded-Data/raw_EMG.csv', 'w', encoding='UTF8', newline='') as f:
    with open(filename, 'w', encoding='UTF8', newline='') as f:    
        writer = csv.writer(f)
        
        print('header: ', header)
        print('data: ', data)
        
        # write the header
        writer.writerow(header)
    
        # write multiple rows
        writer.writerows(data)    
    

'''
class Plot(object):

  def __init__(self, listener):
    self.n = listener.n
    self.listener = listener
    self.fig = plt.figure()
    self.axes = [self.fig.add_subplot('81' + str(i)) for i in range(1, 9)]
    [(ax.set_ylim([-100, 100])) for ax in self.axes]
    self.graphs = [ax.plot(np.arange(self.n), np.zeros(self.n))[0] for ax in self.axes]
    plt.ion()

  def update_plot(self):
    emg_data = self.listener.get_emg_data()
    emg_data = np.array([x[1] for x in emg_data]).T
    for g, data in zip(self.graphs, emg_data):
      if len(data) < self.n:
        # Fill the left side with zeroes.
        data = np.concatenate([np.zeros(self.n - len(data)), data])
      g.set_ydata(data)
    plt.draw()

  def main(self):
    while True:
      self.update_plot()
      plt.pause(1.0 / 30)
'''

def main():
  myo.init(sdk_path="C:\\Users\\dicke\\packages\\MyoSDK.2.1.0")
  hub = myo.Hub()
  listener = EmgCollector(1)
  
  with hub.run_in_background(listener.on_event):
    for i in range(0,5000):     # If the data array is [None], then change the range to higher than 3000.
                                # Otherwise, the data recordings will happen before the Myo even initialises, recording no values
        listener.print_emg()
        print(i)
        #emgMatrix = listener.get_emg_data()

  emgMatrix = listener.get_emg_data()
  print(type(emgMatrix))
  SaveRoutine(emgMatrix).save_to_CSV()

if __name__ == '__main__':
  main()
  