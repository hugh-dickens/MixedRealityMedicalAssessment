#!/bin/bash
py GUI.py &
py A_Save_holo_angles.py & 

py B_myo_save_all.py &
py C_TCP_Polhemus.py &

$SHELL