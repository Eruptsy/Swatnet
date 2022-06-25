import os

fn main() {
	mut args := os.args.clone()
	 if args.len < 2 {
		println("[ x ] Error, Invalid arguments")
		exit(0)
	}

	ip := args[1]

	if char_count(ip, ".") != 3 { 
		println("[ x ] Error, Invalid IP")
		exit(0)
	}

	if ip.split(".").len < 3 {
		println("[ x ] Error_2, Invalid IP")
		exit(0)
	}

	first_digit := ip.split(".")[0]
	second_digit := ip.split(".")[1]
	third_digit := ip.split(".")[2]
	last_digit := ip.split(".")[3]

	if (first_digit.int() == 0 || first_digit.int() > 255) || (second_digit.int() == 0 || second_digit.int() > 255) || (third_digit.int() == 0 || third_digit.int() > 255) || (last_digit.int() == 0 || last_digit.int() > 255) {
		println("[ x ] Error, Invalid IP")
		exit(0)
	}

	println("[ + ] Valid IP")
}

pub fn char_count(str string, ch string) int {
	mut c := 0
	for i in 0..str.len {
		mut cch := str[i].ascii_str()

		if cch == ch {
			c++
		}
	}
	return c
}