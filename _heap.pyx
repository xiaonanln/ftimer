from heap cimport *

cdef class Heap:
	"""Heap class is not used by ftimer directly, but is used in heap unittest.
	"""

	cdef heap_t *heap

	def __cinit__(self):
		self.heap = heap_create()
		if self.heap == NULL:
			raise MemoryError()

	cpdef void push(self, double t, object obj) except*:
		heap_push(self.heap, t, obj)

	cpdef tuple pop(self):
		cdef double t
		cdef object obj = heap_pop(self.heap, &t)
		return t, obj

	cpdef size_t size(self):
		return heap_size(self.heap)

	def __len__(self):
		return self.size()

