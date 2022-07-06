#include <ncurses.h>

#flag curses -lncurses

fn C.initscr()
fn C.addstr(&char)
fn C.refresh()
fn C.getch()
fn C.endwin()

fn main() {
	C.initscr()

	C.addstr(&char("Test".str))
	C.refresh()

	C.addstr(&char("Lul".str))
	C.refresh()

	C.getch()

	C.endwin()
}