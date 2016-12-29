cdef extern from "objvector.h":
	ctypedef struct objvector_t:
		pass

	ctypedef struct PyObject:
		pass

	objvector_t *objvector_create()
	void objvector_free(objvector_t *v)

	void objvector_push(objvector_t *v, object obj)
	size_t objvector_size(objvector_t *v)

	PyObject **objvector_items(objvector_t *v, size_t *len)
	void objvector_clear(objvector_t *v)
