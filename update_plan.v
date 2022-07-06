import os

import core.crud
import core.logger

fn main() {
	mut args := os.args.clone()
	mut u := crud.User{}

	if args.len < 2 {
		logger.console_log("invalid_argument", "Invalid arguments provided.\r\nUsage: ${args[0]} <username> <plan_number>", true)
		exit(0)
	}
	
	logger.console_log("update_user_attempt", u.update_plan(args[1], "1").replace("[ x ] Error, ", "").replace("[ + ]", ""), false)
}