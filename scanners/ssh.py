import os, sys, time, paramiko
from ssh_core.paramiko import *

t = SSH("46.31.77.155", "root", "Lol123!")
print(t.connect())