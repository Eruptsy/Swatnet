import os

fn main() {
	mut args := os.args.clone()
	if args.len < 2 {
		println("[ x ] Error, Invalid argument provided.\r\nUsage: ${args[0]} <port> <bot_pw>")
	}
}