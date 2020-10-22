import os
import sys
from datetime import datetime
import time

def test():
    os.system("make")
    print(" Benchmarking ")
    start = time.time()
    os.system("./brainfuck hello.b")
    return time.time() - start

def analyze_tests(tests):
    return {
            "average" : sum(tests)/len(tests),
            "diviation": max(tests) - min(tests),
            "best": min(tests),
            "worse": max(tests)
    }

if sys.argv[1] == "loop":
    tests = []
    n = 0
    while (True):
        n += 1
        tests.append(test())
        print("Finished running test #" + str(n))
        print("Results so far:")
        print(str(analyze_tests(tests)))
        time.sleep(9)
else:
    print("Done in :" +  str(test()))


