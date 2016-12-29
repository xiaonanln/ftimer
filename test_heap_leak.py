from _heap import Heap
import random

h = Heap()
while True:
	h.push(random.random(), random.random())
	t, obj = h.pop()
	assert h.size() == 0

