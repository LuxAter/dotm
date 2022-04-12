SOURCES := $(shell find src -name '*.sh') src/bashly.yml

dotm: $(SOURCES)
	bashly generate -u

completions.bash: $(SOURCES)
	bashly add comp script

.PHONY: test
test:
	./test/bats/bin/bats ./test/*.bats

.PHONY: all
all: dotm completions.bash
