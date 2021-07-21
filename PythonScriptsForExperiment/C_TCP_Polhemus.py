#!/usr/bin/env python
import socket
import struct
import numpy as np
from datetime import datetime
import csv
import tkinter as tk 
import tkinter.font as tkFont

class PolhemusAngleCollector():
  """
  Collects angle data in a queue with *n* maximum number of elements.
  """
  def __init__(self):

    TCP_IP = '127.0.0.1'
    TCP_PORT = 7234  # change to what polhemus is sending to
    self.BUFFER_SIZE = 1024
    self.s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    self.s.connect((TCP_IP, TCP_PORT))
    # s.close()
    self.angle_list = []
    self.date_time_list =[]
    self.milliseconds = []

    self.counter  = 0 

  def get_angle(self):
    # need a way of fixing which sensor is which joint, at the moment it is just random

        output_sensor1 = []
        output_sensor2 = []
        output_sensor3 = []
        self.counter +=1
        
        if self.counter % 500 ==0:
            data = self.s.recv(self.BUFFER_SIZE)
            # output[0] = sensor number
            # for x and y see the calibrater
            # output[1] = x
            # output[2] = y
            # output[3] = z which is up and down
            # output[4] = angle
            # output[5] = angle
            # output[6] = angle
            output_sensor1.append(struct.unpack('b', data[2:3])[0])
            [output_sensor1.append(struct.unpack('f', data[i:i+4])[0]) for i in range(16,37,4)]
            output_sensor2.append(struct.unpack('b', data[44:45])[0])
            [output_sensor2.append(struct.unpack('f', data[i:i+4])[0]) for i in range(58,79,4)]
            output_sensor3.append(struct.unpack('b', data[86:87])[0])
            [output_sensor3.append(struct.unpack('f', data[i:i+4])[0]) for i in range(100,121,4)]
            datetime_object_polhemus = str(datetime.now())
            dt_object_polhemus2 = datetime_object_polhemus[11:]
            dt_object_polhemus3 = datetime_object_polhemus[20:]
            self.date_time_list.append(dt_object_polhemus2)
            self.milliseconds.append(dt_object_polhemus3)
            
            
            a = np.array([output_sensor1[1], output_sensor1[2], output_sensor1[3]])
            b = np.array([output_sensor2[1], output_sensor2[2], output_sensor2[3]])
            c = np.array([output_sensor3[1], output_sensor3[2], output_sensor3[3]])

            ba = a - b
            bc = c - b

            cosine_angle = np.dot(ba, bc) / (np.linalg.norm(ba) * np.linalg.norm(bc))
            angle = np.arccos(cosine_angle)

            self.angle_list.append(np.degrees(angle))

        else:
            pass
        
  def get_final_data(self):
    return self.date_time_list, self.milliseconds,  self.angle_list

  def save_and_quit(self, Participant_ID):
    
    date_time, milliseconds, angle = self.get_final_data()

    # field names 
    fields = ['Timestamp','Milliseconds' , 'Angle'] 
    rows = zip(date_time, milliseconds ,angle)

    ID = str(Participant_ID)
    filename_pol = "PolhemusGroundTruth_%s.csv" % ID
    
    with open(filename_pol, 'w') as f:
        # using csv.writer method from CSV package
        writer = csv.writer(f,delimiter=',')
        writer.writerow(fields)
        # for word in yourList:
        #   wr.writerow([word])
        for row in rows:
          writer.writerow(row)

def main(Participant_ID):
    main_polhemus = PolhemusAngleCollector()
    try:
        while True:
            main_polhemus.get_angle()
    except KeyboardInterrupt:
      main_polhemus.save_and_quit(Participant_ID)  
    
        
if __name__ == '__main__':

  Participant_ID = 0
  window = tk.Tk() 

  fontStyle_title = tkFont.Font(family="Lucida Grande", size=20)
  fontStyle_ID = tkFont.Font(family="Lucida Grande", size=10)

  lbl_title = tk.Label(window, text="Welcome to the experiment for the Polhemus!", font=fontStyle_title)
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




