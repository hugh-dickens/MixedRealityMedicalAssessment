import tkinter as tk 
import tkinter.font as tkFont

window = tk.Tk() 

fontStyle_title = tkFont.Font(family="Lucida Grande", size=20)
fontStyle_ID = tkFont.Font(family="Lucida Grande", size=10)

lbl_title = tk.Label(window, text="Welcome to the experiment!", font=fontStyle_title)
lbl_title.pack()


def on_change(e):
    print(e.widget.get())

lbl_ID = tk.Label(window, text = "Participant ID:", font = fontStyle_ID )
lbl_ID.pack()
entry_ID = tk.Entry(window)
entry_ID.pack()    
# Calling on_change when you press the return key
entry_ID.bind("<Return>", on_change)  

button = tk.Button(
    text="Click me to start recording!",
    width=25,
    height=5,
    bg="blue",
    fg="yellow",
)
button.pack()

window.mainloop()