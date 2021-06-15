### Attempt at plotting to figure, this may be easier to do in a seperate python scipt. at the moment just plots and waits to be shut doesnt
        # live plot.

import matplotlib.pyplot as plt
import matplotlib.animation as animation
from matplotlib import style
import time

fig = plt.figure()
ax = fig.add_subplot(1, 1, 1)

def animate(i, xs, ys):

    # Draw x and y lists
    ax.clear()
    # Format plot
    ax.plot(xs, label="Angle")
    ax.plot(ys, label="Angular Velocity")
    plt.ylim([-50,50])
    plt.xticks(rotation=45, ha='right')
    plt.subplots_adjust(bottom=0.30)
    plt.title('Vals')
    plt.ylabel('Angle')
    plt.xlabel('Time')
    plt.legend()

time.sleep(0.3)
ani = animation.FuncAnimation(fig, animate, fargs=(unpack[0], unpack[1]), interval=10)
plt.show()