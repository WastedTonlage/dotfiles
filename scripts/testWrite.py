import sys
import datetime
import curses 
import time

def loop(screen):
	screen.clear()
	attempts = 0
	longest = datetime.timedelta()
	screen.nodelay(1)
	while True:
		if (screen.getch() == ord("q")):
			break
		with open(sys.argv[1], "rb+") as file:
			file.seek(0, 2)
			end = file.tell()
			file.seek(int(end/2))
			file.write(b'\x90')
			before = datetime.datetime.now()
			file.seek(int(end/2))
			file.write(b'\x90')
			after = datetime.datetime.now()
			diff = after-before
			attempts += 1
			if diff > longest:
				longest = diff
			screen.addstr(0, 0, "Attempts since restart: " + str( attempts) + " " * 30)
			screen.addstr(1, 0, "Max time: " + str(longest.microseconds / 1e6)  + "s" + " " * 30)
			time.sleep(0.1)

curses.wrapper(loop)