#!/usr/bin/env python
# ISP Downtime Monitoring | [pi]-----[router]-----[google]
# pip install socket
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


	def check_connectivity(self):
		try:
			with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
				s.settimeout(3)
				s.connect((self.host, self.port))
			if self.failure:
				duration = time.time() - self.failure
				self.write_to_file(str(duration)[:6], '✅UP')
				self.failure = None

		except OSError as error:
			if not self.failure:
				self.failure = time.time()
				self.write_to_file('','❌DOWN')



	def write_to_file(self, duration, msg):
		tm = (datetime.now().strftime('%Y-%m-%d %H:%M:%S.%f')[:-3])
		print(template.format(NAME=self.name, TIME=tm, LENGTH=duration, ERROR=msg))

		with open('internet.log', 'a+', encoding='utf-8') as f:
			f.write(template.format(NAME=self.name, TIME=tm, LENGTH=duration, ERROR=msg+"\n"))



if __name__ == "__main__":
	# check first isp-router second google.nl
	servers = [Server('google','8.8.8.8',53,None)]
	# servers = [Server('router','192.168.2.254',80,None), Server('google','8.8.8.8',53,None)]
	servers[0].write_to_file('','Start-Monitorig')

	# check more often if there's already an issue.
	while True:
		try:
			time.sleep(0.2)
			for server in servers:
				server.check_connectivity()

		except KeyboardInterrupt:
			print("\nGood bye! Hope your ISP issues are resolved!")
			exit()
# tracert 8.8.8.8
