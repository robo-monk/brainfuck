import os
from datetime import datetime as time

start = time.now()
print(" Benchmarking ")
os.system("make && ./brainfuck hello.b")
print("Done in " + str(time.now() - start))
