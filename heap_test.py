import unittest
import ftimer
from _heap import Heap
import random

class Test(unittest.TestCase):
	def test_basic(self):
		heap = Heap()
		N = 100000
		for i in xrange(N):
			t = random.random()
			heap.push(t, t * 2)
			self.assertEqual(i+1, heap.size())

		last_t = None
		for i in xrange(N):
			t, obj = heap.pop()
			self.assertEqual(t*2, obj)
			if last_t is not None:
				self.assertLessEqual(last_t, t)

			self.assertEqual(N-i-1, heap.size())

			last_t = t

	def test_fuzzy(self):
		N = 100000
		heap = Heap()

		for i in xrange(N):
			if len(heap) > 0 and random.random() < 0.5:
				n1, n2 = heap.pop()
				self.assertEqual(n2, n1 * 2)
			else:
				n1 = random.randint(1, 10000)
				n2 = n1 * 2
				heap.push(n1, n2)

if __name__ == '__main__':
	unittest.main()

