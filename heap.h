#ifndef _HEAP_H_
#define _HEAP_H_

#include "Python.h"

typedef struct heap heap_t;

heap_t *heap_create(void);
void heap_free(heap_t *h);

void heap_push(heap_t *h, double t, PyObject *obj);
double heap_min_t(heap_t *h);

PyObject *heap_pop(heap_t *h, double *t);

size_t heap_size(heap_t *h);

#endif//_HEAP_H_
