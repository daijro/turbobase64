'''
Runtime speed test using Matplotlib
pip install matplotlib

Creates a 2d plot comparing the runtime of the base64 encoding functions
# x axis is length of input string
# y axis is the average runtime in microseconds
'''

import matplotlib.pyplot as plt
from timeit import timeit
import base64
import turbob64
import os


trials = 1000

def test64(length, function):
    rbytes = os.urandom(length)
    return timeit(lambda: function(rbytes), number=trials)

# create chart
fig, ax = plt.subplots()
ax.set_title('Base64 Encoding Speed')
ax.set_xlabel('Length of Input String')
ax.set_ylabel(f'Time in microseconds for {trials} Iterations')
for l in range(10000, 50000, 500):
    print(l, end='\r')
    ax.plot(l, test64(l, base64.b64encode) / trials * 1e6, color='blue', marker='.')
    ax.plot(l, test64(l, turbob64.b64senc) / trials * 1e6, color='green', marker='.')
    ax.plot(l, test64(l, turbob64.b64xenc) / trials * 1e6, color='purple', marker='.')
    if turbob64.cpu_set >= 0x32:
        ax.plot(l, test64(l, turbob64.b64v128enc) / trials * 1e6, color='orange', marker='.')
    if turbob64.cpu_set >= 0x50:
        ax.plot(l, test64(l, turbob64.b64v128aenc) / trials * 1e6, color='gray', marker='.')
    if turbob64.cpu_set >= 0x60:
        ax.plot(l, test64(l, turbob64.b64v256enc) / trials * 1e6, color='black', marker='.')
    if turbob64.cpu_set >= 0x800:
        ax.plot(l, test64(l, turbob64.b64v512enc) / trials * 1e6, color='red', marker='.')

ax.legend(['python standard lib', 'mem efficient scalar', 'fast scalar', 'ssse3', 'avx', 'avx2', 'avx512'], loc='upper left')

plt.show()