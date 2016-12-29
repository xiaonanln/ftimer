#include "heap.h"
#include "common.h"

#define DEFAULT_HEAP_CAPACITY	(512)


struct heap_item {
	double t;
	PyObject *obj;
};

struct heap {
	size_t size;
	size_t capacity;
	struct heap_item *items;
};

static int heap_grow(heap_t *h);

heap_t *heap_create()
{
	heap_t *heap = (heap_t *)malloc(sizeof(struct heap));
	if (heap == NULL) {
		PyErr_NoMemory();
		return NULL;
	}

	heap->items = malloc(sizeof(struct heap_item) * DEFAULT_HEAP_CAPACITY);
	if (heap->items == NULL) {
		free(heap);
		PyErr_NoMemory();
		return NULL;
	}

	heap->size = 0;
	heap->capacity = DEFAULT_HEAP_CAPACITY;
	return heap;
}

void heap_free(heap_t *h)
{
	size_t i;
	for (i = 0; i < h->size; i++) {
		Py_DECREF(h->items[i].obj);
	}

	free(h->items);
	free(h);
}

inline int heap_empty(heap_t *h)
{
	return h->size <= 0;
}

inline int heap_full(heap_t *h)
{
	return h->size >= h->capacity;
}

void heap_push(heap_t *h, double t, PyObject *obj)
{
	unsigned int index, parent;

	if (heap_full(h)) {
		if (!heap_grow(h)) {
			PyErr_NoMemory();
			return ;
		}
	}

	for (index = h->size++; index; index = parent) {
		parent = (index - 1) >> 1;
		if (h->items[parent].t <= t) break;
		h->items[index] = h->items[parent];
	}

	h->items[index].t = t;
	h->items[index].obj = obj;
	Py_INCREF(obj);
}

static int heap_grow(heap_t *h)
{
	size_t new_capacity = h->capacity << 1;
	struct heap_item *new_items = (struct heap_item *)realloc(h->items, new_capacity * sizeof(struct heap_item));
	if (new_items == NULL) {
		return 0;
	}
	// realloc succeed, items are already copied
	h->items = new_items;
	h->capacity = new_capacity;
	return 1;
}

double heap_min_t(heap_t *h)
{
	if (!heap_empty(h)) {
		return h->items[0].t;
	} else {
		return EVER;
	}
}

PyObject *heap_pop(heap_t *h, double *t)
{
	unsigned int index, swap, other;
	if (heap_empty(h)) {
		PyErr_SetString(PyExc_IndexError, "pop from empty heap");
		return NULL;
	}
	// get the min item
	*t = h->items[0].t;
	PyObject *obj = h->items[0].obj;
	//Py_DECREF(*obj);

	// remove the max item
	struct heap_item maxitem = h->items[--h->size];
	for (index = 0; 1; index = swap) {
		swap = (index << 1) + 1;
		if (swap >= h->size) break;
		other = swap + 1;
		if (other < h->size && h->items[other].t <= h->items[swap].t) {
			swap = other;
		}
		if (maxitem.t <= h->items[swap].t) {
			break;
		}

		h->items[index] = h->items[swap];
	}

	h->items[index] = maxitem;
	return obj;
}

size_t heap_size(heap_t *h)
{
	return h->size;
}

