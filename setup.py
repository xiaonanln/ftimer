from distutils.core import setup
from Cython.Build import cythonize

ext_modules = cythonize(['*.pyx'])
for mod in ext_modules:
	mod.sources.append('heap.c')
	mod.sources.append('objvector.c')

setup(
  name = 'ftimer',
  ext_modules = ext_modules,
)
