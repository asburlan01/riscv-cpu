TEST_DIRS := \
	toplev \
	fetch/fetch \
	fetch/btb \
	fetch/bpu \
	execute/alu \
	execute/cmp \
	execute/execute

SIM ?= icarus
PROJ_ROOT := $(shell dirname $(PWD)) 

.PHONY: all
all: $(TEST_DIRS) 

.PHONY: $(TEST_DIRS)
$(TEST_DIRS):
	@cd $@ && $(MAKE) SIM=${SIM} PROJ_ROOT=${PROJ_ROOT}

.PHONY: clean
clean:
	$(foreach TEST, $(TEST_DIRS), $(MAKE) -C $(TEST) clean;)

