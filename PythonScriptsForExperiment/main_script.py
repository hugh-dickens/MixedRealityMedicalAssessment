## Main script --> simultaneously runs the angle and EMG live plotting scipts
## and then saves all data to ..... 


import angle_live_plots
import EMG_live_plots
from threading import Thread


if __name__ == '__main__':
    # bind socket for angle plotting
    # sock = angle_live_plots.socket_bind()

    Thread(target = EMG_live_plots.main).start()
    
    Thread(target = angle_live_plots.angle_plotting).start()


    
    
    
    