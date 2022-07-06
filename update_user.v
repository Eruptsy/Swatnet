import os
import core.crud
import core.logger

fn main() {
	mut args := os.args.clone()
	mut u := crud.User{}

	if args.len < 3 {
		logger.console_log("invalid_argument", "Invalid arguments provided.\r\nUsage: ${args[0]} <username> <plan_number> <new_maxtime> <new_conn> <new_expiry>", true)
		exit(0)
	}

	logger.console_log("user_updated", (u.update_user(args[1], args[2], args[3], args[4], args[5]).replace("[ x ] Error, ", "").replace("[ + ]", "")), false)
}