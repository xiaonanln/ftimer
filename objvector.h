#ifndef _OBJVECTOR_H_
#define _OBJVECTOR_H_

#include "Python.h"

typedef struct objvector objvector_t;

objvector_t *objvector_create(void);
void objvector_free(objvector_t *v);

void objvector_push(objvector_t *v, PyObject *obj);
size_t objvector_size(objvector_t *v);

PyObject **objvector_items(objvector_t *v, size_t *len);
void objvector_clear(objvector_t *v);

#endif//_OBJVECTOR_H_
