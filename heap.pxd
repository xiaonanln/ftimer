cdef extern from "heap.h":
	ctypedef struct PyObject:
		pass

	ctypedef struct heap_t:
		pass

	heap_t *heap_create()
	void heap_free(heap_t *h)
	void heap_push(heap_t *h, double t, obj)
	double heap_min_t(heap_t *h)
	object heap_pop(heap_t *h, double *t)
	size_t heap_size(heap_t *h)

