#!/usr/bin/env python
import socket
import struct
import numpy as np

TCP_IP = '127.0.0.1'
TCP_PORT = 7234  # change to what polhemus is sending to
BUFFER_SIZE = 1024
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((TCP_IP, TCP_PORT))
# s.close()

counter  = 0 
while True:

    output_sensor1 = []
    output_sensor2 = []
    output_sensor3 = []
    counter +=1
    data = s.recv(BUFFER_SIZE)
    if counter % 500 ==0:
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
        
        
        a = np.array([output_sensor1[1], output_sensor1[2], output_sensor1[3]])
        b = np.array([output_sensor2[1], output_sensor2[2], output_sensor2[3]])
        c = np.array([output_sensor3[1], output_sensor3[2], output_sensor3[3]])

        ba = a - b
        bc = c - b

        cosine_angle = np.dot(ba, bc) / (np.linalg.norm(ba) * np.linalg.norm(bc))
        angle = np.arccos(cosine_angle)

        print(np.degrees(angle))



