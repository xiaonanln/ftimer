from heap cimport *
from objvector cimport *
from time import time
import traceback

cdef double MIN_TIMER_INTERVAL = 0.001

cdef class Timer:
	cdef double t
	cdef object cb
	cdef bint cancelled;
	cdef bint repeat

	def __cinit__(self, double t, object cb, bint repeat):
		self.t = t
		self.cb = cb
		self.repeat = repeat
		self.cancelled = False

	cpdef cancel(self):
		self.cancelled = True

cdef class TimeManager:
	cdef heap_t *heap;

	def __cinit__(self):
		self.heap = heap_create()

	def __dealloc__(self):
		heap_free(self.heap)

	cdef addTimer(self, double t, object cb, bint repeat):
		if repeat and t < MIN_TIMER_INTERVAL:
			t = MIN_TIMER_INTERVAL

		cdef Timer timer = Timer(t, cb, repeat)
		heap_push(self.heap, time() + t, timer)
		return timer

	cdef tick(self):
		cdef double t = time()
		cdef double next_t = heap_min_t(self.heap)
		cdef Timer timer

		if t < next_t:
			# no timer can be triggered
			return

		# some timer is fired
		while True:
			timer = heap_pop(self.heap, &next_t)
			if not timer.cancelled:
				try:
					timer.cb()
				except:
					traceback.print_exc()

				if timer.repeat:
					heap_push(self.heap, t + timer.t, timer)

			next_t = heap_min_t(self.heap)
			if t < next_t:
				break

cdef size_t XLIST_LENGTH = 65536

cdef class XTimeManager:
	cdef heap_t *heap
	cdef objvector_t *xlist[65536]
	cdef int xcursor
	cdef double xcursortime

	def __cinit__(self):
		cdef int i
		self.heap = heap_create()
		for i in xrange(sizeof(self.xlist) / sizeof(self.xlist[0])):
			self.xlist[i] = objvector_create()

		self.xcursor = 0
		self.xcursortime = time()

	def __dealloc__(self):
		cdef int i
		heap_free(self.heap)
		for i in xrange(sizeof(self.xlist) / sizeof(self.xlist[0])):
			objvector_free(self.xlist[i])

	cdef Timer addTimer(self, double t, object cb, bint repeat):
		cdef double tt = time() + t
		cdef double dt = tt - self.xcursortime
		cdef int ti = <int>(dt * 1000)
		if ti < 0: ti = 0

		cdef Timer timer = Timer(t, cb, repeat)

		if ti < XLIST_LENGTH:
			ti = (self.xcursor + ti) & (XLIST_LENGTH-1)
			objvector_push(self.xlist[ti], timer)
		else:
			# put timer to the heap
			heap_push(self.heap, tt, timer)

		return timer

	cdef tick(self):
		cdef int i, j
		cdef double t = time()

		# tick timers in xlist
		cdef double dt = t - self.xcursortime
		cdef int ti = <int>(dt * 1000)
		if ti > XLIST_LENGTH:
			ti = XLIST_LENGTH

		cdef int xcursor
		cdef PyObject **objs
		cdef size_t count
		cdef Timer timer
		cdef int ti2
		cdef int tmpi

		if ti > 0:
			xcursor = self.xcursor
			self.xcursor = (xcursor + ti) & (XLIST_LENGTH - 1)
			self.xcursortime += ti * 0.001

			for i in xrange(ti):
				# trigger all callbacks at this index
				objs = objvector_items(self.xlist[xcursor], &count) # get all objs from xlist

				for j in xrange(count):
					timer = <Timer>objs[j]
					if not timer.cancelled:
						try:
							timer.cb()
						except:
							traceback.print_exc()

						if timer.repeat:
							ti2 = <int>((t + timer.t - self.xcursortime) * 1000)
							assert ti2 < XLIST_LENGTH
							if ti2 < 0: ti2 = 0
							ti2 = (self.xcursor + ti2) & (XLIST_LENGTH - 1)
							objvector_push(self.xlist[ti2], timer)

				objvector_clear(self.xlist[xcursor])
				xcursor = (xcursor + 1) & (XLIST_LENGTH - 1)

		# tick timers in heap
		cdef double next_t = heap_min_t(self.heap)

		if t < next_t:
			# no timer can be triggered
			return

		# some timer is fired
		while True:
			timer = heap_pop(self.heap, &next_t)
			if not timer.cancelled:
				try:
					timer.cb()
				except:
					traceback.print_exc()

				if timer.repeat:
					heap_push(self.heap, t + timer.t, timer)

			next_t = heap_min_t(self.heap)
			if t < next_t:
				break

cdef TimeManager timeManager = TimeManager()

def addCallback(t, cb):
	return timeManager.addTimer(t, cb, False)

def addTimer(t, cb):
	return timeManager.addTimer(t, cb, True)

def tick():
	timeManager.tick()

