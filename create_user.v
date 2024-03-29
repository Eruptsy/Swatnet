import os

import core.crud
import core.logger

fn main() {
	mut args := os.args.clone()
	mut u := crud.User{}

	if args.len < 3 {
		logger.console_log("invalid_argument", "Invalid arguments provided.\r\nUsage: ${args[0]} <username> <password>", true)
		exit(0)
	}

	search_for_user := u.find(args[1])
	if search_for_user.username != "" {
		logger.console_log("user_taken", "Username already taken....!", true)
		exit(0)
	}

	logger.console_log("user_created", u.create(args[1], args[2], args[3]).replace("[ x ] Error, ", "").replace("[ + ]", ""), false)
}