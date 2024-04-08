#!/usr/bin/env python
# internet ISP-Watchdog | ISP Downtime Monitoring.
import socket
import time
from datetime import datetime

template = "{NAME}\t{NOW}\t{MSG}"

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

	def write_file(self,msg):
		self.failure = (datetime.now().strftime('%Y-%m-%d %H:%M:%S.%f')[:-3])
		print(template.format(NAME=self.name,NOW=self.failure,MSG=msg))
		with open('internet.log', 'a+', encoding='utf-8') as f:
			f.write(template.format(NAME=self.name,NOW=self.failure,MSG=msg+"\n"))


	# report only isp or router down!
	def check_connectivity(self):
		if self.watchdog():
			if self.failure:
				self.write_file('UP')
				self.failure = None
			return True
		else:
			if not self.failure:
				self.write_file('DOWN')
			return False

if __name__ == "__main__":
	# check first isp-router second google.nl
	router = Server('router','192.168.2.254',80,True)
	isp = Server('google','google.nl',80,True)

	# check more often if there's already an issue.
	while True:
		try:
			time.sleep(0.5)
			if router.check_connectivity():
				isp.check_connectivity()
		except KeyboardInterrupt:
			print("\nGood bye! Hope your ISP issues are resolved!")
			exit()
#
