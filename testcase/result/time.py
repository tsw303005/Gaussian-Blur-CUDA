import matplotlib.pyplot as plt
import pandas as pd
import numpy as np

run = ["Single Thread", "Multiple Thread", "Single GPU"]
time = [46.6573, 4.82201, 0.701165]
speedup = [time[0] / i for i in time]

filename = "view"

# bar chart for different thread number's CPU, COMM, IO time
fig, ax = plt.subplots()
x = np.arange(len(time))
ax.bar(run, time, label="Execuation Time")
ax.set_ylabel("Runtime (seconds)")
ax.set_title(f"{filename} Time Profile")
ax.legend(loc="upper right")
fig.savefig(f"./{filename}_timeprofile.png")


# line seperate speedup factor
fig, ax = plt.subplots()
ax.plot(run, speedup, label='Speedup Time')
ax.set_ylabel("Speedup")
ax.set_title(f"{filename} Speedup Factor")
ax.legend(loc="upper right")
fig.savefig(f"./{filename}_speedup.png")