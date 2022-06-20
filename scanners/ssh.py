import os, sys, time, paramiko

from ssh_core.paramiko import *
from ssh_core.zmap_scan import *

HELP_MENU = """    Tools              Description
______________________________________________________
    -z                 Start a new ZMAP Scan
    -b                 Bruteforce a ZMAP list
                           -f <zmap_list>
    -l                 Load bots
                           -f <bruteforced_list>
    -a                 Auto Scan ( All of the Above)
    -c                 Clean/Filter a Bruteforced list
"""

if len(os.args) < 1:
    print("[ x ] Error, Invalid arguments provided!\r\n{0}".format(HELP_MENU))
    exit(0)

for arg in os.args:
    if arg == "-z":
        pass
        # Start ZMAP Scan
    elif arg == "-b":
        pass
        # Start bruteforcing the last ZMAP Scan
    elif arg == "-l":
        pass
        # Load bots from the last bruteforced list
    elif arg == "-a":
        pass
        # Auto scan
    elif arg == "-c":
        pass
        # Clean/Filter the last bruteforced list