import tkinter as tk 
import tkinter.font as tkFont
import os
import sys
import signal
import time

prot_directory = "ProtocolData./"
p = open(prot_directory +"KeyboardInterruptBoolean.txt", "w")
p.write(str(0))
p.close()
p = open(prot_directory +"StartRunning.txt", "w")
p.write(str(0))
p.close()
p = open(prot_directory +"StartCalibrating.txt", "w")
p.write(str(0))
p.close()

####start time
global startTime, startAssessment
startTime = time.time()
startAssessment = 0 # 0 = dont run, 1 = start run, 2 = running

Participant_ID = 0
condition, trial = "default", 0 
window = tk.Tk() 

fontStyle_title = tkFont.Font(family="Lucida Grande", size=20)
fontStyle_ID = tkFont.Font(family="Lucida Grande", size=10)

lbl_title = tk.Label(window, text="Welcome to the experiment! Please enter the details below:", font=fontStyle_title)
lbl_title.pack()

def on_change_ID(e1):
    Participant_ID = e1.widget.get()
    f = open(prot_directory +"ParticipantID.txt", "w")
    f.write(Participant_ID)
    f.close()
# print(Participant_ID)    

lbl_ID = tk.Label(window, text = "Participant ID:", font = fontStyle_ID )
lbl_ID.pack()
entry_ID = tk.Entry(window)
entry_ID.pack()    
# Calling on_change when you press the return key
entry_ID.bind("<Return>", on_change_ID)  

def on_change_condition(e2):
    condition = e2.widget.get()
    g = open(prot_directory +"Condition.txt", "w")
    g.write(condition)
    g.close()
    # print(Participant_ID)    

lbl_ID = tk.Label(window, text = "Condition (fast, medium, or slow):", font = fontStyle_ID )
lbl_ID.pack()
entry_ID = tk.Entry(window)
entry_ID.pack()    
# Calling on_change when you press the return key
entry_ID.bind("<Return>", on_change_condition)  

# def on_change_trial(e3):
#     trial = e3.widget.get()
#     h = open(prot_directory +"Trial.txt", "w")
#     h.write(trial)
#     h.close()   

# lbl_ID = tk.Label(window, text = "Trial number:", font = fontStyle_ID )
# lbl_ID.pack()
# entry_ID = tk.Entry(window)
# entry_ID.pack()    
# # Calling on_change when you press the return key
# entry_ID.bind("<Return>", on_change_trial)  

def calibFunction():
    p = open(prot_directory +"StartCalibrating.txt", "w")
    p.write(str(1))
    p.close()

def runFunction():
    # Init timer - this will be in the run function for the first script but automatic for the other 
    # scripts
    p = open(prot_directory +"StartRunning.txt", "w")
    p.write(str(1))
    p.close()
    print('Button stop')
    time.sleep(5)
    global startTime, startAssessment
    startAssessment = 1
    startTime = time.time()



    
# def stopFunction():
    '''
    p = open(prot_directory +"KeyboardInterruptBoolean.txt", "w")
    p.write(str(1))
    p.close()
    p = open(prot_directory +"StartRunning.txt", "w")
    p.write(str(0))
    p.close()
    p = open(prot_directory +"StartCalibrating.txt", "w")
    p.write(str(0))
    p.close()
    '''
    # print('Button stop')

def restartGUI():
    p = open(prot_directory +"KeyboardInterruptBoolean.txt", "w")
    p.write(str(1))
    p.close()
    p = open(prot_directory +"StartRunning.txt", "w")
    p.write(str(0))
    p.close()
    p = open(prot_directory +"StartCalibrating.txt", "w")
    p.write(str(0))
    p.close()
    time.sleep(1)
    p = open(prot_directory +"KeyboardInterruptBoolean.txt", "w")
    p.write(str(0))
    p.close()


btn_Calibrate = tk.Button(
    text="Click me to calibrate!",
    width=25,
    height=5,
    bg="blue",
    fg="yellow",
    command = calibFunction,
)
btn_Calibrate.pack()

btn_startRecording = tk.Button(
    text="Click me to start recording!",
    width=25,
    height=5,
    bg="blue",
    fg="yellow",
    command = runFunction,
)
btn_startRecording.pack()

# btn_stopRecording = tk.Button(
#     text="Click me to stop\nrecording and save!",
#     width=25,
#     height=5,
#     bg="blue",
#     fg="yellow",
#     command = stopFunction,
# )
# btn_stopRecording.pack()

btn_restartGUI = tk.Button(
    text="Click me to restart \nGUI after calibration!",
    width=25,
    height=5,
    bg="blue",
    fg="yellow",
    command = restartGUI,
)

btn_restartGUI.pack()
step = 0

while True:
    window.update_idletasks()
    window.update()
    while startAssessment >= 1:
        now = time.time()
        delta = now - startTime

        window.update_idletasks()
        window.update()

        if (trial < 20):
            window.update_idletasks()
            window.update()

            if (delta <= 7):
                print('time delta: ', delta)

            else:
                p = open(prot_directory +"KeyboardInterruptBoolean.txt", "w")
                p.write(str(1))
                p.close()
                p = open(prot_directory +"StartRunning.txt", "w")
                p.write(str(0))
                p.close()
                p = open(prot_directory +"StartCalibrating.txt", "w")
                p.write(str(0))
                p.close()
                trial+=1
                h = open(prot_directory +"Trial.txt", "w")
                h.write(str(trial))
                h.close()  

                print('======================= Saved to CSV =======================')
                time.sleep(3)

                p = open(prot_directory +"KeyboardInterruptBoolean.txt", "w")
                p.write(str(0))
                p.close()
                p = open(prot_directory +"StartRunning.txt", "w")
                p.write(str(1))
                p.close()
                p = open(prot_directory +"StartCalibrating.txt", "w")
                p.write(str(1))
                p.close()
                startTime = time.time()

        else:
            sys.exit()