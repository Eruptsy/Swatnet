module logger

import core.config
import core.utilities

pub fn console_log(log_type string, msg string, err_t bool) {
	mut err := ""

	c_time := utilities.current_time()

	if err_t == true {
		err += "${config.Red}[ x ]${config.Default} ${config.Cyan}[ $c_time ] Error, ${log_type}\r\n"
	} else { err += "${config.Green}[ + ]${config.Default} ${config.Cyan}[ $c_time ] ${log_type}\r\n" }

	err += "=> ${msg}${config.Default}\r\n"
	println(err)
}