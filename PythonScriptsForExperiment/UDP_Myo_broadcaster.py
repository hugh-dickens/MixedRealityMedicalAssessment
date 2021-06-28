# Minimum script for reading and unpacking messages from UDPComm.cs 
# this scipt has been integrated into 01_main_scipt.py
import socket
import struct
from collections import deque
from threading import Lock, Thread

import myo
import numpy as np

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

  def update_packet(self):
    emg_data = self.listener.get_emg_data()
    emg_data = np.array([x[1] for x in emg_data]).T
    emg_data = abs(emg_data)
    if len(emg_data) == 8:
        return (emg_data.sum(axis=0)).sum(axis=0)
    # for data in emg_data:
    #   if len(data) > self.n:

    #     # Fill the left side with zeroes.
    #     self.emg_data_packet.append(data)

  def main(self):
    UDP_IP = ""  # No IP specified, as we receive from any IP address (that's on the same subnet, 192.1.168.xxx)
    UDP_PORT = 9995  # Same port as we specified in UDPComm.cs

    sock = socket.socket(socket.AF_INET, # Internet
                                socket.SOCK_DGRAM) # UDP
    counter = 0
    while True:
      emg_data = str(self.update_packet())
      counter +=1
      if ((counter % 10000) == 0) & (emg_data is not None):
          print(emg_data)
          sock.sendto(emg_data.encode('utf-8'), (UDP_IP, UDP_PORT)) 
          ## need to then do something with emg data

def main():
  ### enter the path to your own MyoSDK package and .dll file here. Download 
  # with Nuget @ https://www.nuget.org/packages/MyoSDK/2.1.0 and insert .dll file within
  # /bin folder if required.
  myo.init(sdk_path="C:\\Users\\dicke\\packages\\MyoSDK.2.1.0")
  hub = myo.Hub()
  listener = EmgCollector(10)
  with hub.run_in_background(listener.on_event):
    packet(listener).main()


if __name__ == '__main__':
    while True:
        data = main()
    

        
