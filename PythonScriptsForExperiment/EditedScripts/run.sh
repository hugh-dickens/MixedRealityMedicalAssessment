#!/bin/bash
py GUI.py &
py A1_Save_holo_angles.py & 
py B_UDP_Myo_broadcaster.py &
py C_TCP_Polhemus.py &
py D_Myo_Calibrate.py &

$SHELL