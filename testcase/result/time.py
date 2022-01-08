import matplotlib.pyplot as plt
import pandas as pd
import numpy as np

run = ["Single Thread", "Multiple Thread", "Single GPU"]
time = [362.181, 36.6829, 2.43379]
speedup = [time[0] / i for i in time]

filename = "candy"

# bar chart for different thread number's CPU, COMM, IO time
fig, ax = plt.subplots()
x = np.arange(len(time))
ax.bar(run, time, label="Execuation Time")
ax.set_xlabel("Total Execution Time")
ax.set_ylabel("Runtime (seconds)")
ax.set_title(f"{filename} Time Profile")
ax.legend(loc="upper right")
fig.savefig(f"./{filename}_timeprofile.png")


# line seperate speedup factor
fig, ax = plt.subplots()
ax.plot(run, speedup, label='Speedup Time')
ax.set_xlabel("Thread Number")
ax.set_ylabel("Speedup")
ax.set_title(f"{filename} Speedup Factor")
ax.legend(loc="upper right")
fig.savefig(f"./{filename}_speedup.png")
