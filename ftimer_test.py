import unittest
import ftimer
import time

import ftimer

TICK_INTERVAL = 0.001

class Test(unittest.TestCase):

	def tickForAWhile(self, duration):
		t0 = time.time()
		while time.time() < t0 + duration:
			ftimer.tick()
			time.sleep(TICK_INTERVAL)

	def test_callback(self):
		i = [0]
		handle = [None]
		def callback():
			i[0] += 1
			print i[0],

			handle[0] = ftimer.addCallback(0.01, callback)

		handle[0] = ftimer.addCallback(0.01, callback)
		print 'test_callback'
		self.tickForAWhile(1)
		handle[0].cancel()
		print 'ok'

	def test_timer(self):
		print 'test_timer'
		i = [0]
		def callback():
			i[0] += 1
			print i[0],

		handle = [None]
		handle[0] = ftimer.addTimer(0.01, callback)
		self.tickForAWhile(1)
		handle[0].cancel()
		print 'ok'
		self.tickForAWhile(0.5)

if __name__ == '__main__':
	unittest.main()
