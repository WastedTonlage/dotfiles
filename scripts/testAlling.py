import sys
import signal
import datetime
import socket
import time
import collections
import random
import curses 
import threading
import concurrent.futures

IP = "192.168.135.43"
PORT = 1234
sockLock = threading.Lock()
Chip = collections.namedtuple('Chip', ['Id', 'CustomerNumber', 'WashCode', 'TargetWeight'])
chips = [] 
stop = False

with open("Chips.txt", "r") as chipFile:
	for chip in chipFile.readlines():
		fields = chip.split("|")
		chips.append(Chip(fields[0], fields[1], fields[2], fields[3]))

def senderThread(chip):
	if stop:
		return
	print("running serverthread")
	sockLock.acquire()
	chipSock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	chipSock.connect((IP, PORT))
	chipText =  '{{"Command": "Chip", "Chip": "{}"}}'.format(chip.Id)
	chipSock.send(b'\x02' + bytes( chipText, "utf-8") + b'\x03')
	res = chipSock.recv(1024)
	print(res)
	chipSock.close()
	sockLock.release()
	time.sleep(1)
	sockLock.acquire()
	garmentSock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	garmentSock.connect((IP, PORT))
	garmentSortedText =  '{{"Command":"GarmentSorted", "Chip": "{}", "Bin": "{}", "Weight":"0.636769", "Status":"0", "StatusText":"OK", "RFIDTagStatus":"1", "RFIDTagStatusText":"OK"}}'.format(chip.Id, chip.WashCode)
	garmentSock.send(b'\x02' + bytes( garmentSortedText, "utf-8") + b'\x03')
	res = garmentSock.recv(1024)
	print(res)
	garmentSock.close()
	sockLock.release()

def updateScreen(screen, pending, finished):
	screen.nodelay(1)
	#print("updating screen")
	if (screen.getch() == ord("q")):
		return False	
	screen.addstr(0, 0, "Started threads since restart: " + str( pending ) + " " * 30)
	screen.addstr(1, 0, "Finished threads since restart: " + str( finished ) + " " * 30)
	return True

def loop(screen):
	pending = 0
	finished = 0
	exe = concurrent.futures.ThreadPoolExecutor()
	all_futures = []
	while pending < 1000:
		all_futures.append(exe.submit(senderThread, random.choice(chips)))
		pending += 1
		#senderThread(random.choice(chips))
		if not updateScreen(screen, pending, finished):
			break
	for future in concurrent.futures.as_completed(all_futures):
		print(future)
		finished += 1
		if not updateScreen(screen, pending, finished):
			stop = True
			break

curses.wrapper(loop)