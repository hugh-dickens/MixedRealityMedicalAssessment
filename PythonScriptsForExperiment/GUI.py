import tkinter as tk 
import tkinter.font as tkFont

import numpy as np
import csv
import os 

Participant_ID=0
condition = "Default"
trial = 0
window = tk.Tk() 

fontStyle_title = tkFont.Font(family="Lucida Grande", size=20)
fontStyle_ID = tkFont.Font(family="Lucida Grande", size=10)

lbl_title = tk.Label(window, text="Welcome to the experiment!", font=fontStyle_title)
lbl_title.pack()


def on_change_ID(e1):
    global Participant_ID
    Participant_ID = e1.widget.get()
    # print(Participant_ID)    

lbl_ID = tk.Label(window, text = "Participant ID:", font = fontStyle_ID )
lbl_ID.pack()
entry_ID = tk.Entry(window)
entry_ID.pack()    
# Calling on_change when you press the return key
entry_ID.bind("<Return>", on_change_ID)  

def on_change_condition(e2):
    global condition
    condition = e2.widget.get()
    # print(Participant_ID)    

lbl_ID = tk.Label(window, text = "Condition (fast, medium, or slow):", font = fontStyle_ID )
lbl_ID.pack()
entry_ID = tk.Entry(window)
entry_ID.pack()    
# Calling on_change when you press the return key
entry_ID.bind("<Return>", on_change_condition)  

def on_change_trial(e3):
    global trial
    trial = e3.widget.get()
    # print(Participant_ID)    

lbl_ID = tk.Label(window, text = "Trial number:", font = fontStyle_ID )
lbl_ID.pack()
entry_ID = tk.Entry(window)
entry_ID.pack()    
# Calling on_change when you press the return key
entry_ID.bind("<Return>", on_change_trial)  

def helloCallBack():
   print("It worked")

def stopFunction():
    ID = str(Participant_ID)

    # Directory
    directory = "./Data_ID_%s/" % ID
  
    try:
        os.mkdir(directory)
    except OSError as e:
        print("Directory exists")

    filename_GUI = "%s_%s_%s_GUI.csv" % (ID, condition, trial)

    with open(directory + filename_GUI, 'w') as f:
    
        # using csv.writer method from CSV package
        writer = csv.writer(f,delimiter=',')
        

btn_startRecording = tk.Button(
    text="Click me to start recording!",
    width=25,
    height=5,
    bg="blue",
    fg="yellow",
    command = helloCallBack,
)
btn_startRecording.pack()

btn_stopRecording = tk.Button(
      text="Click me to stop\nrecording and save!",
      width=25,
      height=5,
      bg="blue",
      fg="yellow",
      command = stopFunction,
  )
btn_stopRecording.pack()


window.mainloop()

