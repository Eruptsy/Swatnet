module cnc

import net

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