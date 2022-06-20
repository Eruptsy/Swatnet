import sys, os, time, paramiko

class SSH():
    global device_ip
    global device_user
    global device_pass
    global SSH

    def __init__(self, i, usr, pw):
        self.device_ip = i
        self.device_user = usr
        self.device_pass = pw

    def change_device(self, ip, usr, pw) -> None:
        self.device_ip = ip
        self.device_user = usr
        self.device_pass = pw
        
    def connect(self) -> int:
        self.SSH = paramiko.client.SSHClient()
        self.SSH.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        try:
            self.SSH.connect(self.device_ip, username=self.device_user, password=self.device_pass)
            print("[ + ] Authorized")
            return 1
        except:
            print("[ x ] Authorization Failed")
            return -1

    def close(self) -> None:
        self.SSh.close()

    def brute(self, ip: str, user: str, pw: str) -> int:
        self.device_ip = ip
        self.device_user = user
        self.device_pass = pw
        check_auth = self.connect()
        if check_auth: 
            self.close()
            return 1
        return 0
        
    def send_cmd(self, cmd) -> int:
        try:
            self.connect()
            stdin, stdout, stderr = self.SSH.exec_command(cmd)
            self.close()
            print("[ + ] Payload successfully sent!")
            return 1
        except:
            print("[ x ] Failed to send payload")
            return -1