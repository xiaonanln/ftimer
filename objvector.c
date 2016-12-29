#include "objvector.h"

#define DEFAULT_OBJVECTOR_CAPACITY	(100)

struct objvector {
	size_t size;
	size_t capacity;
	PyObject **objs;
};

static int objvector_grow(objvector_t *v); 

objvector_t *objvector_create()
{
	objvector_t *v = (objvector_t *)malloc(sizeof(struct objvector));
	if (v == NULL) {
		PyErr_NoMemory();
		return NULL;
	}
	PyObject **objs = (PyObject **)malloc(sizeof(PyObject*) * DEFAULT_OBJVECTOR_CAPACITY); 
	if (objs == NULL) {
		free(v);
		PyErr_NoMemory();
		return NULL;
	}

	v->objs = objs;
	v->size = 0;
	v->capacity = DEFAULT_OBJVECTOR_CAPACITY;
	return v;
}

void objvector_free(objvector_t *v)
{
	PyObject *obj;
	size_t i;

	for (i = 0; i < v->size; i++) {
		obj = v->objs[i];
		Py_DECREF(obj);
	}

	free(v->objs);
	free(v);
}

void objvector_push(objvector_t *v, PyObject *obj)
{
	if (v->size >= v->capacity) {
		if (!objvector_grow(v)) {
			PyErr_NoMemory();
			return;
		}
	}
	v->objs[v->size++] = obj;
	Py_INCREF(obj);
}

size_t objvector_size(objvector_t *v)
{
	return v->size;
}

void objvector_clear(objvector_t *v)
{
	size_t i;
	for (i = 0; i < v->size; i++) {
		Py_DECREF(v->objs[i]);
	}
	v->size = 0;
}

static int objvector_grow(objvector_t *v)
{
	size_t new_capacity = v->capacity << 1;
	PyObject **new_objs = (PyObject **)realloc(v->objs, new_capacity * sizeof(PyObject *));
	if (new_objs == NULL) {
		return 0;
	}
	// realloc succeed, items are already copied
	v->objs = new_objs;
	v->capacity = new_capacity;
	return 1;
}

PyObject **objvector_items(objvector_t *v, size_t *len)
{
	*len = v->size;
	return v->objs;
}
