SOURCES := $(shell find src -name '*.sh') src/bashly.yml

.PHONY: all
all: dotm completions.bash

dotm: $(SOURCES)
	bashly generate -u

completions.bash: $(SOURCES)
	rm -f completions.bash
	bashly add comp script

.PHONY: test
test:
	./test/bats/bin/bats ./test/*.bats
