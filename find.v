import core.crud

fn main() {
	mut t := crud.User{}
	println(t.find("root"))
}