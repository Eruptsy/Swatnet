module crud

import os

const blacklist_file = os.getwd() + "/assets/db/blacklist.db"

pub fn read_blacklist() []string {
	return os.read_lines(blacklist_file) or { return [] }
}

pub fn blacklist_bot(ip string) int {
	if ip != "" {
		mut file := os.open_append(blacklist_file) or { return -1 /* error locating file */ }
		file.write("${ip}\n".bytes()) or { return -1 /* error writing to file */ }
		file.close()
		return 1 /* successfully logged */
	}
	return 0 /* Didnt write to file */
}