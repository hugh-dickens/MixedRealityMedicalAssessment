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

  def save_and_quit_EMG(self, Participant_ID):

    # field names 
    fields = ['Timestamp', 'Milliseconds','EMG 1', 'EMG 2', 'EMG 3', 'EMG 4', 'EMG 5', 'EMG 6', 'EMG 7', 'EMG 8'] 
    
    # data rows of csv file 
    rows = self.emg_total
      
    with open('temp.csv', 'w') as f:
        # using csv.writer method from CSV package
        write = csv.writer(f)
        write.writerow(fields)
        write.writerows(rows)
    ## remove duplicate data:
    from more_itertools import unique_everseen
    ID = str(Participant_ID)
    filename_EMG = "EMGData_%s.csv" % ID
    with open('temp.csv','r') as f, open(filename_EMG,'w') as out_file:
      out_file.writelines(unique_everseen(f))
    # delete the temp file
    import os
    os.remove('temp.csv')


  def main(self, Participant_ID):
    try:
      sock = socket.socket(socket.AF_INET, # Internet
                                  socket.SOCK_DGRAM) # UDP
      counter = 0
      while True:
        emg_data = self.update_packet()
        counter +=1
        if ((counter % 5000) == 0) & (emg_data is not None):
          ### Could try just saving the data here
            print(emg_data)
            emg_data = str(emg_data)
            sock.sendto(emg_data.encode('utf-8'), ("192.168.1.139", 9050))   
            # print(self.emg_total)       
            # REmember this should be the holo ip
            # Same port as we specified in UDPComm.cs 
    except KeyboardInterrupt:
      self.save_and_quit_EMG(Participant_ID)  

def main(Participant_ID):
  ### enter the path to your own MyoSDK package and .dll file here. Download 
  # with Nuget @ https://www.nuget.org/packages/MyoSDK/2.1.0 and insert .dll file within
  # /bin folder if required.
  myo.init(sdk_path="C:\\Users\\dicke\\packages\\MyoSDK.2.1.0")
  hub = myo.Hub()
  listener = EmgCollector(10)   # TRY changing this to different values - see what happens
  with hub.run_in_background(listener.on_event):
    packet(listener).main(Participant_ID)


if __name__ == '__main__':
  Participant_ID = 0
  window = tk.Tk() 

  fontStyle_title = tkFont.Font(family="Lucida Grande", size=20)
  fontStyle_ID = tkFont.Font(family="Lucida Grande", size=10)

  lbl_title = tk.Label(window, text="Welcome to the experiment for EMG broadcasting!", font=fontStyle_title)
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
    

        
