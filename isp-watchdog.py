#!/usr/bin/env python
# internet ISP-Watchdog | ISP Downtime Monitoring.
import socket
import time
from datetime import datetime

template = "{NAME}\t{TIME}\t{MSG}"

class Server():
	def __init__(self, name, host, port, failure):
		self.name = name
		self.host = host
		self.port = port
		self.failure = failure

	def watchdog(self):
		try:
			with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
				sock.settimeout(2)
				sock.connect((self.host, self.port))
				return True
		except socket.error:
			return False


	# report only isp or router down!
	def check_connectivity(self):
		if self.watchdog():
			if self.failure:
				now = (datetime.now().strftime('%Y-%m-%d %H:%M:%S.%f')[:-3])
				print(template.format(NAME=self.name,TIME=now,MSG="UP"))
				self.failure = None
			return True
		else:
			if not self.failure:
				self.failure = (datetime.now().strftime('%Y-%m-%d %H:%M:%S.%f')[:-3])
				print(template.format(NAME=self.name,TIME=self.failure,MSG="DOWN"))
			return False

if __name__ == "__main__":
	# check first isp-router second google.nl
	router = Server('router','192.168.2.254',80,True)
	isp = Server('google','google.nl',80,True)

	while True:
		try:
			time.sleep(0.5)
			# check more often if there's already an issue.
			if router.check_connectivity():
				isp.check_connectivity()
		except KeyboardInterrupt:
			print("\nGood bye! Hope your ISP issues are resolved!")
			exit()
#
