import sys, os, time, random

from .zmap_scan import *

class ZMAP:

    def gen_scan_name() -> str:
        chars = "qwertyuiopasdfghjklzxcvbnm1234567890"
        sttr = ""
        for i in range(0, 10):
            sttr += chars[random.randrange(0, len(chars))]
        return sttr

    def start_scan(time) -> str:
        scan_name = ZMAP.gen_scan_name()
        file_name = ZMAP.gen_scan_name() + ".txt"

        # Starting ZMAP Scan
        os.system("screen -dmS {0} zmap -p22 -o {1}".format(scan_name, file_name))
        print("[ + ] New ZMAP Scan Started. Scan name: {0} | File name: {1}".format(scan_name, file_name))

        # Starting a timer
        for i in range(0, int(time)):
            time.sleep(1)
        
        # Stop scanning
        os.system("screen -xS {0} -X quit".format(scan_name))

        print("[ + ] Scan has finished....")

        return file_name # Return the filename to then bruteforce!