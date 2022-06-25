/*
	import core.attack

	args := os.args.clone()

	mut a := attack.prepare(args, attack.AttackType.all)
	if typeof(a).name != typeof(AttackInfo{}).name || a != Responses.success {
		println(attack.response_err(a))
	}

*/
module attack

import core.crud

pub type Attack = Responses | AttackInfo | AttackType

// Attack.FIELD
pub struct AttackInfo {
	pub mut:
		host	string
		port 	string
		time	string
		method	string
		user    crud.User
		attk_t  AttackType
}

pub enum AttackType {
	_none
	bots
	api
	raw
	telnet
	all
}

// Respones.EnumElement
pub enum Responses {
	error

	// Attack Type Response
	invalid_attack_type

	// Input Responses
	invalid_arg
	invalid_host
	invliad_url
	invalid_ip
	invalid_port
	invalid_time
	invalid_method

	// Valid Response
	success
}

// crud.VARI
pub const invalid_arg = "[ x ] Error, Invalid argument!"
pub const invalid_host = "[ x ] Error, Invalid host provided!"
pub const invalid_port = "[ x ] Error, Inalid port provided!"
pub const invalid_time = "[ x ] Error, Invalid time provided!"
pub const invalid_method = "[ x ] Error, Invalid method provided!"
pub const internal_err = "[ x ] Error, Internal code error!"

pub fn response_err(r Responses) string {
	match r {
		.invalid_arg {
			return invalid_arg
		}
		.invalid_host {
			return invalid_host
		}
		.invalid_port {
			return invalid_port
		}
		.invalid_time {
			return invalid_time
		}
		.invalid_method {
			return invalid_method
		} else { return internal_err }
	}
}

// use this function then a.send_attack
pub fn prepare(args []string, user_info crud.User, attack_type AttackType) Attack {
	if args.len < 4 {
		return Responses.invalid_arg
	}

	mut a := AttackInfo{}
	a.host = args[0]
	a.port = args[1]
	a.time = args[3]
	a.method = args[4]
	a.user = user_info
	a.attk_t = attack_type

	if a.filter_inputs() != Responses.success { 
		return a.filter_inputs()
	}

	if a.user.username == "" { 
		return Responses.error
	}

	// Validate Plan Info With Attack Info
	return a
}

pub fn (mut a AttackInfo) filter_inputs() Responses {
	ip := a.host

	
	if (ip.starts_with("https://") == false && ip.starts_with("http://") == false) || char_count(ip, ".") != 3 {
		return Responses.invalid_host
	}

	first_digit := ip.split(".")[0]
	second_digit := ip.split(".")[1]
	third_digit := ip.split(".")[2]
	last_digit := ip.split(".")[3]

	if (first_digit.int() == 0 || first_digit.int() > 255) || (second_digit.int() == 0 || second_digit.int() > 255) || (third_digit.int() == 0 || third_digit.int() > 255) || (last_digit.int() == 0 || last_digit.int() > 255) {
		return Responses.invalid_ip
	}

	// Port Validation
	if a.port.int() == 0 || a.port.int() > 65500 {
		return Responses.invalid_port
	}

	// Time Validation
	if a.time.int() == 0 || a.time.int() < 20000 {
		return Responses.invalid_time
	}

	return Responses.success
}

pub fn (mut a AttackInfo) send_attack() {
	// Check if any API, Bots, Telnet or Raw protocols avaliable with the method used
	// use crud functions to get info for attack protocol to match the method being used
}

pub fn char_count(str string, ch string) int {
	mut c := 0
	for i in 0..str.len {
		mut cch := str[i].ascii_str()

		if cch == ch {
			c++
		}
	}
	return c
}