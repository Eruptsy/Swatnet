module auth

import core.crud

pub fn get_rank(usern string) int {
	mut u := crud.User{}
	return u.find(usern).plan
}

pub fn is_premium(usern string) bool {
	mut u := crud.User{}
	if u.find(usern).plan > 0 && u.find(usern).plan < 7 {
		return true
	}
	return false
}

pub fn is_reseller(usern string) bool {
	mut u := crud.User{}
	if u.find(usern).admin == 1 {
		return true
	}
	return false
}

pub fn is_admin(usern string) bool {
	mut u := crud.User{}
	if u.find(usern).admin == 2 {
		return true
	}
	return false
}

pub fn is_owner(usern string) bool {
	mut u := crud.User{}
	if u.find(usern).admin == 3 {
		return true
	}
	return false
}