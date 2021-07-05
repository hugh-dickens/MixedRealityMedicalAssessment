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

## Script has been altered to also send UDP packets of EMG data to the Hololens app.
import socket
from matplotlib import pyplot as plt
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

  # myo.DeviceListener

  def on_connected(self, event):
    event.device.stream_emg(True)

  def on_emg(self, event):
    with self.lock:
      self.emg_data_queue.append((event.timestamp, event.emg))

class Plot(object):

  def __init__(self, listener):
    self.n = listener.n
    self.listener = listener
    self.emg_data_total = []
    self.fig = plt.figure(2)
    self.axes = [self.fig.add_subplot('81' + str(i)) for i in range(1, 9)]
    [(ax.set_ylim([-100, 100])) for ax in self.axes]
    self.graphs = [ax.plot(np.arange(self.n), np.zeros(self.n))[0] for ax in self.axes]
    plt.ion()

  def update_plot_packet(self, sock):
    emg_data = self.listener.get_emg_data()
    emg_data = np.array([x[1] for x in emg_data]).T
    self.emg_data_total.append(emg_data)
    ABS_emg_data = abs(emg_data)
    ABS_emg_data = (ABS_emg_data.sum(axis=0)).sum(axis=0) / 45
    print(ABS_emg_data)
    EMG_SEND = str(ABS_emg_data)
    sock.sendto(EMG_SEND.encode('utf-8'), ("192.168.1.139", 9050)) 
    for g, data in zip(self.graphs, emg_data):
      if len(data) < self.n:
        # Fill the left side with zeroes.
        data = np.concatenate([np.zeros(self.n - len(data)), data])
      g.set_ydata(data)
    plt.draw()

  def get_final_data_EMG(self):
    return self.emg_data_total

  def save_and_quit_EMG(self):
    EMG_data_final = self.get_final_data_EMG()
    ## Write to txt file
    f = open("EMGData.txt", "w")
    f.write(str(EMG_data_final))
    f.write(",")
    f.close()
  

  def main(self):
    sock = socket.socket(socket.AF_INET, # Internet
                                socket.SOCK_DGRAM) # UDP
    while True:
      self.update_plot_packet(sock)
      plt.pause(1.0 / 30)
      self.save_and_quit_EMG()

def main():
  ### enter the path to your own MyoSDK package and .dll file here. Download 
  # with Nuget @ https://www.nuget.org/packages/MyoSDK/2.1.0 and insert .dll file within
  # /bin folder if required.
  myo.init(sdk_path="C:\\Users\\dicke\\packages\\MyoSDK.2.1.0")
  hub = myo.Hub()
  listener = EmgCollector(512)
  with hub.run_in_background(listener.on_event):
    Plot(listener).main()


if __name__ == '__main__':
  main()
