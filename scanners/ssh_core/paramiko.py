import sys, os, time, paramiko

class SSH():
    global device_ip
    global device_user
    global device_pass
    ssh = None

    def __init__(self, i, usr, pw):
        self.device_ip = i
        self.device_user = usr
        self.device_pass = pw
        
    def connect(self):
        self.SSH = paramiko.client.SSHClient()
        self.SSH.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        print("{0} {1} {2}".format(self.device_ip, self.device_user, self.device_pass))
        try:
            self.connect(self.ip, username=self.device_user, password=self.device_pass)
        except:
            print("failed to login")