#!/usr/bin/env python
# ISP Downtime Monitoring | [pi]---->[router]---->[google] <- [ ❌✅ ]
# pip install socket
import socket
from datetime import datetime
from time import strftime, localtime, time

template = "{NAME}\t{TIME}\t{LENGTH}\t{ERROR}"

class Server():
	def __init__(self, name, host, port, failure):
		self.name = name
		self.host = host
		self.port = port
		self.failure = failure

	def check_connectivity(self):
		try:
			with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
				s.settimeout(3)
				s.connect((self.host, self.port))
			if self.failure:
				self.write_to_file()
				self.failure = None

		except OSError as error:
			if not self.failure:
				self.failure = time()

	def write_to_file(self):
		duration = time() - self.failure
		tm = (datetime.now().strftime('%Y-%m-%d %H:%M:%S'))
		msg = template.format(NAME=self.name, TIME=tm, LENGTH=duration, ERROR='❌')
		print(msg)		

		if duration > 3.5:
			with open('internet.log', 'a+', encoding='utf-8') as f:
				f.write(msg+'\n')




if __name__ == "__main__":
	# check isp-router and google.nl
	servers = [Server('router', '192.168.2.254', 80, None), Server('google', '8.8.8.8', 53, None)]
	
	servers[0].failure = time()
	servers[0].check_connectivity()

	# check more often if there's already an issue.
	while True:
		try:
			for server in servers:
				server.check_connectivity()

		except KeyboardInterrupt:
			print("\nGood bye! Hope your ISP issues are resolved!")
			exit()
# 
