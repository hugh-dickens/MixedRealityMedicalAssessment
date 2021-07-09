#!/usr/bin/env python
import socket
import struct

TCP_IP = '127.0.0.1'
TCP_PORT = 7234  # change to what polhemus is sending to
BUFFER_SIZE = 1024
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((TCP_IP, TCP_PORT))
data = s.recv(BUFFER_SIZE)  # receives one packet and disconnects, modify into loop
# will need to do some byte unpacking like other udp scripts
s.close()
# data = b'LY\x01C \x00"\x00\xe6\xe0\x03\x00\x13)\x10\x00\xc0<\xb6@L@(\xc0\xc9?~?\xc9j\xf6\xc2M!6@\x96\xb6\xd0A\r\n'
# snum = struct.unpack('b', data[2:3])[0]
# pno = [struct.unpack('f', data[i:i+4])[0] for i in range(8,29,4)]

output = []
output.append(struct.unpack('b', data[2:3])[0])
[output.append(struct.unpack('f', data[i:i+4])[0]) for i in range(16,37,4)]
print(data)
print(output)
