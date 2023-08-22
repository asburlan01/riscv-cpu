
TEST_DIRS := toplev fetch

SIM ?= icarus

.PHONY: all
all: $(TEST_DIRS)

.PHONY: $(TEST_DIRS)
$(TEST_DIRS):
	@cd $@ && $(MAKE) SIM=${SIM}

.PHONY: clean
clean:
	$(foreach TEST, $(TEST_DIRS), $(MAKE) -C $(TEST) clean;)

