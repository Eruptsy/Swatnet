module logger

import core.config
import core.utilities

pub fn console_log(log_type string, msg string, err_t bool) {
	mut err := ""

	c_time := utilities.current_time()

	if err_t == true {
		err += "${config.red}[ x ]${config.default} ${config.cyan}[ $c_time ] Error, ${log_type}\r\n"
	} else { err += "${config.green}[ + ]${config.default} ${config.cyan}[ $c_time ] ${log_type}\r\n" }

	err += "=> ${msg}${config.default}\r\n"
	println(err)
}