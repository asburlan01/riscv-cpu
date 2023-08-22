
.PHONY: test
test:
	${MAKE} -C tests

.PHONY: clean
clean:
	${MAKE} -C tests clean
