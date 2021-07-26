#!/bin/bash
py A_angle_live_plots.py & 
py B_UDP_Myo_broadcaster.py &
py C_TCP_Polhemus.py &