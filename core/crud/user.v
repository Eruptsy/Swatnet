module crud

import os
import x.json2
import crypto.sha1

import crud
import core.logger

const db_filepath_linux = os.getwd() + "/assets/db/users.db"
const db_filepath_windws = os.getwd() + "\\assets\\db\\users.db"

const plan_filepath_linux = os.getwd() + "/assets/db/plans.json"
const plan_filepath_windows = os.getwd() + "/assets/db/plans.json"

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

pub fn locate_plan_db() string {
	if os.exists(plan_filepath_linux) {
		return plan_filepath_linux
	} else {
		return plan_filepath_windows
	}
}

pub fn (mut u User) parse(line string) []string {
	return line.replace("('", "").replace("')", "").split("','")
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
	users_db.write("('${new_user_count}','${usern}','no_key','${user_ip}','${hid_pw}','0','0','0','0','0','00/00/00')\n".bytes()) or { 
		logger.console_log("failed_to_write_to_db", "Unable to write to database file....!", true)
		return ""
	}
	users_db.close()
	return "[+] User: ${usern} has been successfully created"
}

pub fn (mut u User) update_user(usern string, new_plan string, new_maxtime string, new_conn string, new_expiry string) string {
	check_user := u.find(usern)
	if check_user.username.len < 2 { return "[ x ] Error, No user found to update!" }
	current_users := os.read_lines(crud.locate_db()) or { return "[ x ] Error, No db found to update user!" }

	mut new_db := ""
	for usr in current_users {
		if usr.len < 2 { return "" }
		user_info := u.parse(usr)
		//  0     1       2        3                          4                      5   6   7   8   9      10
		//('3','root','no_key','1.1.1.1','8efd86fb78a56a5145ed7739dcb00c78581c5375','0','0','0','0','0','00/00/00')
		if user_info[1] == usern {
			new_db += "('${user_info[0]}','${usern}','${user_info[2]}','${user_info[3]}','${user_info[4]}','${new_plan}','${new_maxtime}','${new_conn}','${user_info[8]}','${user_info[9]}','${new_expiry}')\n"
		} else { new_db += "${usr}\n" }
	}

	os.write_file(crud.locate_db(), new_db) or { return "[ x ] Error, No db found to update user!" }
	return "[ + ] User: ${usern} has been successfully updated!"
}

pub fn (mut u User) update_plan(usern string, plan string) string {
	plans_db := os.read_file(crud.locate_plan_db()) or { return "[ x ] Error, Unable to locate plans DB" }

	raw_plan := json2.raw_decode(plans_db) or { return "[ x ] Error, Unable to read JSON format" }
	plans := raw_plan.as_map()


	match plan {
		"1" {
			json_plan_info := json2.raw_decode((plans["1"] or { return "[ x ] Error, Unable to read JSON format" }).str()) or { return "[ x ] Error, Unable to read JSON format" }
			plan_info := json_plan_info.as_map()
			// plan_name := (plan_info["plan_name"] or { return "[ x ] Error, Unable to read JSON format" }).str()
			plan_maxtime := (plan_info["plan_maxtime"] or { return "[ x ] Error, Unable to read JSON format" }).str()
			plan_maxconn := (plan_info["plan_maxconn"] or { return "[ x ] Error, Unable to read JSON format" }).str()
			plan_length := (plan_info["plan_length"] or { return "[ x ] Error, Unable to read JSON format" }).str()
			u.update_user(usern, plan, plan_maxtime, plan_maxconn, plan_length)
		}
		"2" {
			json_plan_info := json2.raw_decode((plans["2"] or { return "[ x ] Error, Unable to read JSON format" }).str()) or { return "[ x ] Error, Unable to read JSON format" }
			plan_info := json_plan_info.as_map()
			// plan_name := (plan_info["plan_name"] or { return "[ x ] Error, Unable to read JSON format" }).str()
			plan_maxtime := (plan_info["plan_maxtime"] or { return "[ x ] Error, Unable to read JSON format" }).str()
			plan_maxconn := (plan_info["plan_maxconn"] or { return "[ x ] Error, Unable to read JSON format" }).str()
			plan_length := (plan_info["plan_length"] or { return "[ x ] Error, Unable to read JSON format" }).str()
			u.update_user(usern, plan, plan_maxtime, plan_maxconn, plan_length)
		}
		"3" {
			json_plan_info := json2.raw_decode((plans["3"] or { return "[ x ] Error, Unable to read JSON format" }).str()) or { return "[ x ] Error, Unable to read JSON format" }
			plan_info := json_plan_info.as_map()
			// plan_name := (plan_info["plan_name"] or { return "[ x ] Error, Unable to read JSON format" }).str()
			plan_maxtime := (plan_info["plan_maxtime"] or { return "[ x ] Error, Unable to read JSON format" }).str()
			plan_maxconn := (plan_info["plan_maxconn"] or { return "[ x ] Error, Unable to read JSON format" }).str()
			plan_length := (plan_info["plan_length"] or { return "[ x ] Error, Unable to read JSON format" }).str()
			u.update_user(usern, plan, plan_maxtime, plan_maxconn, plan_length)
		}
		"4" {
			json_plan_info := json2.raw_decode((plans["4"] or { return "[ x ] Error, Unable to read JSON format" }).str()) or { return "[ x ] Error, Unable to read JSON format" }
			plan_info := json_plan_info.as_map()
			// plan_name := (plan_info["plan_name"] or { return "[ x ] Error, Unable to read JSON format" }).str()
			plan_maxtime := (plan_info["plan_maxtime"] or { return "[ x ] Error, Unable to read JSON format" }).str()
			plan_maxconn := (plan_info["plan_maxconn"] or { return "[ x ] Error, Unable to read JSON format" }).str()
			plan_length := (plan_info["plan_length"] or { return "[ x ] Error, Unable to read JSON format" }).str()
			u.update_user(usern, plan, plan_maxtime, plan_maxconn, plan_length)
		}
		"5" {
			json_plan_info := json2.raw_decode((plans["5"] or { return "[ x ] Error, Unable to read JSON format" }).str()) or { return "[ x ] Error, Unable to read JSON format" }
			plan_info := json_plan_info.as_map()
			// plan_name := (plan_info["plan_name"] or { return "[ x ] Error, Unable to read JSON format" }).str()
			plan_maxtime := (plan_info["plan_maxtime"] or { return "[ x ] Error, Unable to read JSON format" }).str()
			plan_maxconn := (plan_info["plan_maxconn"] or { return "[ x ] Error, Unable to read JSON format" }).str()
			plan_length := (plan_info["plan_length"] or { return "[ x ] Error, Unable to read JSON format" }).str()
			u.update_user(usern, plan, plan_maxtime, plan_maxconn, plan_length)
		}
		"6" {
			json_plan_info := json2.raw_decode((plans["6"] or { return "[ x ] Error, Unable to read JSON format" }).str()) or { return "[ x ] Error, Unable to read JSON format" }
			plan_info := json_plan_info.as_map()
			// plan_name := (plan_info["plan_name"] or { return "[ x ] Error, Unable to read JSON format" }).str()
			plan_maxtime := (plan_info["plan_maxtime"] or { return "[ x ] Error, Unable to read JSON format" }).str()
			plan_maxconn := (plan_info["plan_maxconn"] or { return "[ x ] Error, Unable to read JSON format" }).str()
			plan_length := (plan_info["plan_length"] or { return "[ x ] Error, Unable to read JSON format" }).str()
			u.update_user(usern, plan, plan_maxtime, plan_maxconn, plan_length)
		} else {
			return "[ x ] Error, Cannot find Plan!"
		}
	}
	return "User: ${usern} has been successfully updated!"
}

pub fn (mut u User) add_ongoing_attack(usern string) string {
	check_user := u.find(usern)
	if check_user.username.len < 2 { return "[ x ] Error, No user found to update!" }
	current_users := os.read_lines(crud.locate_db()) or { return "[ x ] Error, No db found to update user!" }

	mut new_db := ""
	for usr in current_users {
		if usr.len < 2 { return "" }
		user_info := u.parse(usr)
		//  0     1       2        3                          4                      5   6   7   8   9      10
		//('3','root','no_key','1.1.1.1','8efd86fb78a56a5145ed7739dcb00c78581c5375','0','0','0','0','0','00/00/00')
		if user_info[1] == usern {
			new_db += "('${user_info[0]}','${usern}','${user_info[2]}','${user_info[3]}','${user_info[4]}','${user_info[5]}','${user_info[6]}','${user_info[7]}','${user_info[8].int()+1}','${user_info[9]}','${user_info[10]}')\n"
		} else { new_db += "${usr}\n" }
	}

	os.write_file(crud.locate_db(), new_db) or { return "[ x ] Error, No db found to update user!" }
	return "[ + ] User: ${usern} has been successfully updated!"
}

pub fn (mut u User) remove_ongoing_attack(usern string) string {
	check_user := u.find(usern)
	if check_user.username.len < 2 { return "[ x ] Error, No user found to update!" }
	current_users := os.read_lines(crud.locate_db()) or { return "[ x ] Error, No db found to update user!" }

	mut new_db := ""
	for usr in current_users {
		if usr.len < 2 { return "" }
		user_info := u.parse(usr)
		//  0     1       2        3                          4                      5   6   7   8   9      10
		//('3','root','no_key','1.1.1.1','8efd86fb78a56a5145ed7739dcb00c78581c5375','0','0','0','0','0','00/00/00')
		if user_info[1] == usern {
			new_db += "('${user_info[0]}','${usern}','${user_info[2]}','${user_info[3]}','${user_info[4]}','${user_info[5]}','${user_info[6]}','${user_info[7]}','${user_info[8].int()-1}','${user_info[9]}','${user_info[10]}')\n"
		} else { new_db += "${usr}\n" }
	}

	os.write_file(crud.locate_db(), new_db) or { return "[ x ] Error, No db found to update user!" }
	return "[ + ] User: ${usern} has been successfully updated!"
}