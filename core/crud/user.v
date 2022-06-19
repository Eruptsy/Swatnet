module crud

import os
import crypto.sha1

import crud
import core.logger

const db_filepath_linux = os.getwd() + "/assets/db/users.db"
const db_filepath_windws = os.getwd() + "\\assets\\db\\users.db"

pub struct User {
	pub mut:
		id			int
		username	string
		key			string
		ip			string
		password	string
		plan		int
		maxtime		int
		conn		int
		ongoing		int
		admin		int
		expiry		string
}

pub fn locate_db() string {
	if os.exists(db_filepath_linux) {
		return db_filepath_linux
	} else {
		return db_filepath_windws
	}
}

pub fn (mut u User) parse(line string) []string {
	return line.replace("('", "").replace("')", "").split(",")
}

pub fn (mut u User) user_count() int {
	return (os.read_lines(crud.locate_db()) or { [''] }).len
}

pub fn (mut non User) find(usern string) User {
	mut u := User{}
	users := os.read_lines(crud.locate_db()) or {
		println("[x] Error, Unable to read database....!")
		return u
	}

	for user in users {
		if user.len < 3 { return u }
		user_info := u.parse(user)
		if user_info[1] == usern {
			u.id = user_info[0].int()
			u.username = user_info[1]
			u.key	= user_info[2]
			u.ip = user_info[3]
			u.password = user_info[4]
			u.plan = user_info[5].int()
			u.maxtime	= user_info[6].int()
			u.conn = user_info[7].int()
			u.ongoing	= user_info[8].int()
			u.admin = user_info[9].int()
			u.expiry = user_info[10]
			return u
		}
	}
	return u
}

pub fn (mut u User) create(usern string, passw string, user_ip string) string {
	if u.find(usern).username.len > 2 { return "[x] Error, Username already taken...!" }
	mut users_db := os.open_append(crud.locate_db()) or { 
		logger.console_log("failed_to_open_db", "Unable to write to database file....!", true)
		return "[x] Error, Something went wrong trying to add user to database....!"
	}
	new_user_count := u.user_count()
	hid_pw := sha1.sum(passw.bytes()).hex()
	users_db.write("('${new_user_count}','${usern}','${user_ip}','${hid_pw}','0','0','0','0','0','00/00/00')\n".bytes()) or { 
		logger.console_log("failed_to_write_to_db", "Unable to write to database file....!", true)
		return ""
	}
	users_db.close()
	return "[+] User: ${usern} has been successfully created"
}