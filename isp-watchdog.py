#!/usr/bin/env python
# ISP Downtime Monitoring | [pi]-----[router]-----[google]
# pip install 
import socket
import time
from datetime import datetime

template = "{NAME}\t{TIME}\t{LENGTH}\t{ERROR}"

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

		# except OSError as error:				
		except socket.error:
			return False


	def write_file(self, duration, msg):
		tm = (datetime.now().strftime('%Y-%m-%d %H:%M:%S.%f')[:-3])
		print(template.format(NAME=self.name, TIME=tm, LENGTH=duration, ERROR=msg))

		with open('internet.log', 'a+', encoding='utf-8') as f:
			f.write(template.format(NAME=self.name, TIME=tm, LENGTH=duration, ERROR=msg+"\n"))


	# report only isp or router down!
	def check_connectivity(self):
		if self.watchdog():
			if self.failure:
				duration = time.time() - self.failure
				self.write_file(str(duration)[:6], '✅UP')
				self.failure = None
		else:
			if not self.failure:
				self.failure = time.time()
				self.write_file('','❌DOWN')


if __name__ == "__main__":
	# check first isp-router second google.nl
	servers = [Server('router','192.168.2.254',80,None), Server('google','8.8.8.8',53,None)]
	servers[0].write_file('','Start-Monitorig')

	# check more often if there's already an issue.
	while True:
		try:
			time.sleep(0.5)
			for server in servers:
				server.check_connectivity()

		except KeyboardInterrupt:
			print("\nGood bye! Hope your ISP issues are resolved!")
			exit()
# timedatectl 
