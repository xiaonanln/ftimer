all: build

.PHONY: build clean heaptest profile test

build:
	python setup.py build_ext --inplace

clean:
	rm -rf build
	rm -rf $(patsubst %.pyx,%.so,$(wildcard *.pyx))
	rm -rf *~
	rm -rf .*~
	rm -rf .*.swp
	rm -rf $(patsubst %.pyx,%.c,$(wildcard *.pyx))

test: build
	python ftimer_test.py

heaptest: build
	python heap_test.py

profile: build
	cd ftimer_vs_asiocore; python profile_timer.py ftimer

compare: build
	cd ftimer_vs_asiocore; python profile_timer.py asiocore; python profile_timer.py ftimer

