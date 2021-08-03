#!/bin/bash
py GUI.py &
py A_angle_live_plots.py & 
py B_UDP_Myo_broadcaster.py &
py C_TCP_Polhemus.py &
py D_Myo_Calibrate.py &