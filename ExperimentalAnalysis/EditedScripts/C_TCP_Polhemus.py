#!/usr/bin/env python
import socket
import struct
import numpy as np
from datetime import datetime
import csv
import tkinter as tk 
import tkinter.font as tkFont
import os
import sys
import copy
import time

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
    self.angular_list_pol = []
    self.output_sensor1List = []
    self.output_sensor2List = []
    self.output_sensor3List = []
    self.date_time_list =[]
    self.milliseconds = []

    self.counter  = 0 
    self.temp_time = 0
    self.angle_temp = 0


  def get_angle(self):
      
    # need a way of fixing which sensor is which joint, at the moment it is just random
        prot_directory = "ProtocolData./"
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
            time_diff = abs(self.temp_time - int(dt_object_polhemus3)) / 1000000
            self.temp_time = copy.deepcopy(int(dt_object_polhemus3))
            
            
            a = np.array([output_sensor1[1], output_sensor1[2], output_sensor1[3]])
            b = np.array([output_sensor2[1], output_sensor2[2], output_sensor2[3]])
            c = np.array([output_sensor3[1], output_sensor3[2], output_sensor3[3]])
            self.output_sensor1List.append(a)
            self.output_sensor2List.append(b)
            self.output_sensor3List.append(c)

            ba = a - b
            bc = c - b

            cosine_angle = np.dot(ba, bc) / (np.linalg.norm(ba) * np.linalg.norm(bc))
            angle = np.arccos(cosine_angle)
            angle_diff = (self.angle_temp - np.degrees(angle))
            
            angular_vel_pol = abs(angle_diff/ time_diff)

            self.angle_temp = copy.deepcopy(np.degrees(angle))
            self.angle_list.append(np.degrees(angle))
            self.angular_list_pol.append(angular_vel_pol)

            ### read the keyboard interrupt boolean variable from script A
            f = open(prot_directory+"KeyboardInterruptBoolean.txt", "r")
            keyboardVariable = str(f.read())
            ## if script A writes a 1 to the .txt file then a keyboard interrupt will be thrown to stop recording polhemus data
            if (keyboardVariable == "1"):
                raise KeyboardInterrupt
            else:
                pass

        else:
            pass
        
  def get_final_data(self):
    return self.date_time_list, self.milliseconds,  self.angle_list, self.angular_list_pol, self.output_sensor1List, self.output_sensor2List, self.output_sensor3List

  def save_and_quit(self):
    print('Trial over')
    
    date_time, milliseconds, angle, angularList, sensor1List, sensor2List, sensor3List = self.get_final_data()

    # field names 
    fields = ['Timestamp','Milliseconds' , 'Angle', 'Angular Velocity', 'Sensor 1', 'Sensor 2', 'Sensor 3'] 
    rows = zip(date_time, milliseconds ,angle, angularList, sensor1List, sensor2List, sensor3List)
    prot_directory = "ProtocolData./"
    f = open(prot_directory + "ParticipantID.txt", "r")
    ID = str(f.read())
    g = open(prot_directory + "Condition.txt", "r")
    condition = str(g.read())
    h = open(prot_directory + "Trial.txt", "r")
    trial = str(h.read())

    # Directory
    directory = "./Data_ID_%s/" % ID
  
    # try:
    #     os.mkdir(directory)
    # except OSError as e:
    #     pass
        # print("Directory exists")

    filename_pol = "%s_%s_%s_POLGroundTruth.csv" % (ID, condition, trial)

    with open(directory + filename_pol, 'w') as f:
    
    # with open(filename_pol, 'w') as f:
        # using csv.writer method from CSV package
        writer = csv.writer(f,delimiter=',')
        writer.writerow(fields)
        # for word in yourList:
        #   wr.writerow([word])
        for row in rows:
          writer.writerow(row)
    if (int(trial) >=30):
        print('-------------------quitting file--------------------')
        sys.exit()


def main():
    main_polhemus = PolhemusAngleCollector()
    try:
        while True:
            ## keyboard interrupt signal is within the get_angle function
            main_polhemus.get_angle()     
                      
    except KeyboardInterrupt:
        main_polhemus.save_and_quit()  

if __name__ == '__main__':
    while True:
        prot_directory = "ProtocolData./"
        f = open(prot_directory + "StartRunning.txt", "r")
        runVariablePol = str(f.read())
        ## if script A writes a 1 to the .txt file then a keyboard interrupt will be thrown to stop recording emg data
        if (runVariablePol == "1"):
            main()
        elif (runVariablePol == "0"):
            time.sleep(1)