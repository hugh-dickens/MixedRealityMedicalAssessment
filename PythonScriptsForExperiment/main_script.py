## Main script --> simultaneously runs the angle and EMG live plotting scipts
## and then saves all data to ..... 


import angle_live_plot_v2
import EMG_live_plots
from threading import Thread


if __name__ == '__main__':

    ## Cannot plot both figures live simultaneously at the moment. This seems to be a problem with TKinter as opposed
    # to running the two scripts simultanously (works with printing)

    Thread(target = EMG_live_plots.main).start()
    
    # Thread(target = angle_live_plots.angle_plotting).start()
    Thread(target = angle_live_plot_v2.main).start()




    
    
    
    