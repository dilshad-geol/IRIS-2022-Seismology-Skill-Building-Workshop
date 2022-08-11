import pandas as pd
import matplotlib.pyplot as plt
import os

#os.system('FetchEvent --lon -94.5:-94 --lat 14:19 --mag 4:10 -o oaxaca.eve')
df = pd.read_csv("oaxaca.eve",sep="|",header=None)
pd.set_option('display.max_columns', None)
#print(df.head())
plt.plot(df[2],df[4],'+')
plt.xlabel('Latitude')
plt.ylabel('Depth')
plt.xlim(14.5,18)
plt.ylim(390,0)
plt.gca().xaxis.tick_top()
plt.gca().xaxis.set_label_position("top")
plt.show()
