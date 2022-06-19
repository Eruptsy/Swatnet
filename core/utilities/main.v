module utilities

import os

pub fn current_time() string {
    return (os.execute("sudo timedatectl set-timezone America/New_York; date +\"%m/%d/%y-%I:%M\"").output).trim_space()
}