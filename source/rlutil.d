/**
 * About: Description
 * This file provides some useful utilities for console mode
 * roguelike game development with C and C++. It is aimed to
 * be cross-platform (at least Windows and Linux).
 *
 * $(B Important notes):
 * $(UL
 * $(LI Font styles have no effect on windows platform.)
 * $(LI Light background colors are not supported. Non-light equivalents are used on Posix platforms.)
 * )
 *
 * License:
 * <a href="http://www.boost.org/LICENSE_1_0.txt">Boost License</a>
 * Authors:
 * <a href="http://github.com/robik">Robert 'Robik' Pasiński</a>
 */

module rlutil;

import std.stdio : printf;
import std.process : executeShell;
import std.string : toStringz;
import std.c.stdio;
import std.c.stdlib;

version(Windows)
    enum Windows = true;
else
    enum Windows = false;

version(Linux)
    enum Linux = true;
else
    enum Linux = false;
    
version (Windows) {
	import std.c.windows.windows;
}

version (Posix) {
	import std.stdio,
	std.conv,
	std.string,
	core.sys.posix.unistd,
	core.sys.posix.sys.ioctl,
	core.sys.posix.termios,
	core.sys.posix.fcntl,
	core.sys.posix.sys.time;
}

import core.sys.linux.termios, core.sys.posix.termios;

/// Define: RLUTIL_USE_ANSI
/// Define this to use ANSI escape sequences also on Windows
/// (defaults to using WinAPI instead).
enum RLUTIL_USE_ANSI = true;

alias RLUTIL_STRING_T = string;

/// Function: getch
/// Get character without waiting for Return to be pressed.
/// Windows has this in conio.h
int getch() {
	// Here be magic.
	termios oldt, newt;
	int ch;
	tcgetattr(STDIN_FILENO, &oldt);
	newt = oldt;
	newt.c_lflag &= ~(ICANON | ECHO);
	tcsetattr(STDIN_FILENO, TCSANOW, &newt);
	ch = getchar();
	tcsetattr(STDIN_FILENO, TCSANOW, &oldt);
	return ch;
}

/// Function: kbhit
/// Determines if keyboard has been hit.
/// Windows has this in conio.h
int kbhit() {
	// Here be dragons.
	static termios oldt, newt;
	int cnt = 0;
	tcgetattr(STDIN_FILENO, &oldt);
	newt = oldt;
	newt.c_lflag    &= ~(ICANON | ECHO);
	newt.c_iflag     = 0; // input mode
	newt.c_oflag     = 0; // output mode
	newt.c_cc[VMIN]  = 1; // minimum time to wait
	newt.c_cc[VTIME] = 1; // minimum characters to wait for
	tcsetattr(STDIN_FILENO, TCSANOW, &newt);
	ioctl(0, FIONREAD, &cnt); // Read count
	timeval tv;
	tv.tv_sec  = 0;
	tv.tv_usec = 100;
	select(STDIN_FILENO+1, null, null, null, &tv); // A small time delay
	tcsetattr(STDIN_FILENO, TCSANOW, &oldt);
	return cnt; // Return number of characters
}

/// Function: gotoxy
/// Same as <rlutil.locate>.
//void gotoxy(int x, int y) {
	//locate(x,y);
//}

/**
 * Enums: Color codes
 *
 * BLACK - Black
 * BLUE - Blue
 * GREEN - Green
 * CYAN - Cyan
 * RED - Red
 * MAGENTA - Magenta / purple
 * BROWN - Brown / dark yellow
 * GREY - Grey / dark white
 * DARKGREY - Dark grey / light black
 * LIGHTBLUE - Light blue
 * LIGHTGREEN - Light green
 * LIGHTCYAN - Light cyan
 * LIGHTRED - Light red
 * LIGHTMAGENTA - Light magenta / light purple
 * YELLOW - Yellow (bright)
 * WHITE - White (bright)
 */
enum {
	BLACK,
	BLUE,
	GREEN,
	CYAN,
	RED,
	MAGENTA,
	BROWN,
	GREY,
	DARKGREY,
	LIGHTBLUE,
	LIGHTGREEN,
	LIGHTCYAN,
	LIGHTRED,
	LIGHTMAGENTA,
	YELLOW,
	WHITE
};

/**
 * Consts: ANSI color strings
 *
 * ANSI_CLS - Clears screen
 * ANSI_BLACK - Black
 * ANSI_RED - Red
 * ANSI_GREEN - Green
 * ANSI_BROWN - Brown / dark yellow
 * ANSI_BLUE - Blue
 * ANSI_MAGENTA - Magenta / purple
 * ANSI_CYAN - Cyan
 * ANSI_GREY - Grey / dark white
 * ANSI_DARKGREY - Dark grey / light black
 * ANSI_LIGHTRED - Light red
 * ANSI_LIGHTGREEN - Light green
 * ANSI_YELLOW - Yellow (bright)
 * ANSI_LIGHTBLUE - Light blue
 * ANSI_LIGHTMAGENTA - Light magenta / light purple
 * ANSI_LIGHTCYAN - Light cyan
 * ANSI_WHITE - White (bright)
 */
RLUTIL_STRING_T ANSI_CLS = "\033[2J";
RLUTIL_STRING_T ANSI_BLACK = "\033[22;30m";
RLUTIL_STRING_T ANSI_RED = "\033[22;31m";
RLUTIL_STRING_T ANSI_GREEN = "\033[22;32m";
RLUTIL_STRING_T ANSI_BROWN = "\033[22;33m";
RLUTIL_STRING_T ANSI_BLUE = "\033[22;34m";
RLUTIL_STRING_T ANSI_MAGENTA = "\033[22;35m";
RLUTIL_STRING_T ANSI_CYAN = "\033[22;36m";
RLUTIL_STRING_T ANSI_GREY = "\033[22;37m";
RLUTIL_STRING_T ANSI_DARKGREY = "\033[01;30m";
RLUTIL_STRING_T ANSI_LIGHTRED = "\033[01;31m";
RLUTIL_STRING_T ANSI_LIGHTGREEN = "\033[01;32m";
RLUTIL_STRING_T ANSI_YELLOW = "\033[01;33m";
RLUTIL_STRING_T ANSI_LIGHTBLUE = "\033[01;34m";
RLUTIL_STRING_T ANSI_LIGHTMAGENTA = "\033[01;35m";
RLUTIL_STRING_T ANSI_LIGHTCYAN = "\033[01;36m";
RLUTIL_STRING_T ANSI_WHITE = "\033[01;37m";

/// Function: getANSIColor
/// Return ANSI color escape sequence for specified number 0-15.
///
/// See <Color Codes>
string getANSIColor(const(int) c) {
	switch (c) {
		case 0 : return ANSI_BLACK;
		case 1 : return ANSI_BLUE; // non-ANSI
		case 2 : return ANSI_GREEN;
		case 3 : return ANSI_CYAN; // non-ANSI
		case 4 : return ANSI_RED; // non-ANSI
		case 5 : return ANSI_MAGENTA;
		case 6 : return ANSI_BROWN;
		case 7 : return ANSI_GREY;
		case 8 : return ANSI_DARKGREY;
		case 9 : return ANSI_LIGHTBLUE; // non-ANSI
		case 10: return ANSI_LIGHTGREEN;
		case 11: return ANSI_LIGHTCYAN; // non-ANSI;
		case 12: return ANSI_LIGHTRED; // non-ANSI;
		case 13: return ANSI_LIGHTMAGENTA;
		case 14: return ANSI_YELLOW; // non-ANSI
		case 15: return ANSI_WHITE;
		default: return "";
	}
}

/**
 * Consts: Key codes for keyhit()
 *
 * KEY_ESCAPE  - Escape
 * KEY_ENTER   - Enter
 * KEY_SPACE   - Space
 * KEY_INSERT  - Insert
 * KEY_HOME    - Home
 * KEY_END     - End
 * KEY_DELETE  - Delete
 * KEY_PGUP    - PageUp
 * KEY_PGDOWN  - PageDown
 * KEY_UP      - Up arrow
 * KEY_DOWN    - Down arrow
 * KEY_LEFT    - Left arrow
 * KEY_RIGHT   - Right arrow
 * KEY_F1      - F1
 * KEY_F2      - F2
 * KEY_F3      - F3
 * KEY_F4      - F4
 * KEY_F5      - F5
 * KEY_F6      - F6
 * KEY_F7      - F7
 * KEY_F8      - F8
 * KEY_F9      - F9
 * KEY_F10     - F10
 * KEY_F11     - F11
 * KEY_F12     - F12
 * KEY_NUMDEL  - Numpad del
 * KEY_NUMPAD0 - Numpad 0
 * KEY_NUMPAD1 - Numpad 1
 * KEY_NUMPAD2 - Numpad 2
 * KEY_NUMPAD3 - Numpad 3
 * KEY_NUMPAD4 - Numpad 4
 * KEY_NUMPAD5 - Numpad 5
 * KEY_NUMPAD6 - Numpad 6
 * KEY_NUMPAD7 - Numpad 7
 * KEY_NUMPAD8 - Numpad 8
 * KEY_NUMPAD9 - Numpad 9
 */
const int KEY_ESCAPE  = 0;
const int KEY_ENTER   = 1;
const int KEY_SPACE   = 32;

const int KEY_INSERT  = 2;
const int KEY_HOME    = 3;
const int KEY_PGUP    = 4;
const int KEY_DELETE  = 5;
const int KEY_END     = 6;
const int KEY_PGDOWN  = 7;

const int KEY_UP      = 14;
const int KEY_DOWN    = 15;
const int KEY_LEFT    = 16;
const int KEY_RIGHT   = 17;

const int KEY_F1      = 18;
const int KEY_F2      = 19;
const int KEY_F3      = 20;
const int KEY_F4      = 21;
const int KEY_F5      = 22;
const int KEY_F6      = 23;
const int KEY_F7      = 24;
const int KEY_F8      = 25;
const int KEY_F9      = 26;
const int KEY_F10     = 27;
const int KEY_F11     = 28;
const int KEY_F12     = 29;

const int KEY_NUMDEL  = 30;
const int KEY_NUMPAD0 = 31;
const int KEY_NUMPAD1 = 127;
const int KEY_NUMPAD2 = 128;
const int KEY_NUMPAD3 = 129;
const int KEY_NUMPAD4 = 130;
const int KEY_NUMPAD5 = 131;
const int KEY_NUMPAD6 = 132;
const int KEY_NUMPAD7 = 133;
const int KEY_NUMPAD8 = 134;
const int KEY_NUMPAD9 = 135;

/// Function: getkey
/// Reads a key press (blocking) and returns a key code.
///
/// See <Key codes for keyhit()>
///
/// Note:
/// Only Arrows, Esc, Enter and Space are currently working properly.
int getkey() {
version(Posix)
	int cnt = kbhit(); // for ANSI escapes processing

	int k = getch();
	switch(k) {
		case 0: {
			int kk;
			switch (kk = getch()) {
				case 71: return KEY_NUMPAD7;
				case 72: return KEY_NUMPAD8;
				case 73: return KEY_NUMPAD9;
				case 75: return KEY_NUMPAD4;
				case 77: return KEY_NUMPAD6;
				case 79: return KEY_NUMPAD1;
				case 80: return KEY_NUMPAD4;
				case 81: return KEY_NUMPAD3;
				case 82: return KEY_NUMPAD0;
				case 83: return KEY_NUMDEL;
				default: return kk-59+KEY_F1; // Function keys
			}}
		case 224: {
			int kk;
			switch (kk = getch()) {
				case 71: return KEY_HOME;
				case 72: return KEY_UP;
				case 73: return KEY_PGUP;
				case 75: return KEY_LEFT;
				case 77: return KEY_RIGHT;
				case 79: return KEY_END;
				case 80: return KEY_DOWN;
				case 81: return KEY_PGDOWN;
				case 82: return KEY_INSERT;
				case 83: return KEY_DELETE;
				default: return kk-123+KEY_F1; // Function keys
			}}
		case 13: return KEY_ENTER;
version (Windows)
		case 27: return KEY_ESCAPE;
version (Posix) {
		case 155: // single-character CSI
		case 27: {
			// Process ANSI escape sequences
			if (cnt >= 3 && getch() == '[') {
				switch (k = getch()) {
					case 'A': return KEY_UP;
					case 'B': return KEY_DOWN;
					case 'C': return KEY_RIGHT;
					case 'D': return KEY_LEFT;
				}
			} else return KEY_ESCAPE;
		}
}
		default: return k;
	}
}

/// Function: setColor
/// Change color specified by number (Windows / QBasic colors).
///
/// See <Color Codes>
void setColor(int c) {
	if (Windows == true) {
		//HANDLE hConsole = GetStdHandle(STD_OUTPUT_HANDLE);
		//SetConsoleTextAttribute(hConsole, (WORD)c);
	}
	else {
		printf("%s", getANSIColor(c).toStringz);
	}
}

void cls() {
	if (Windows == true) {
		// TODO: This is cheating...
		executeShell("cls");
	}

	else {
		printf("%s", "\033[2J\033[H".toStringz);
	}
}
