# Sinw wave plot tool
import numpy as np
import matplotlib.pyplot as plt
f =0.5 #frequency of sine wave
# f =2
A =5# maximum amplitude of sine wave
# A = 1 
x = np.arange(-6.28, 6.28, 0.01)# array arranged from -pi to +pi and with small increment of 0.01
# x = np.arange(-3.14, 3.14, 0.01)
#y = A*np.sin(f*x)
y = A*np.tan(f*x)
plt.plot(x,y)
plt.xlabel('angle')
plt.ylabel('amplitude')
plt.show()

