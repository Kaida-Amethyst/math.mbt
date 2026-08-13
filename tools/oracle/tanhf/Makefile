CC ?= cc
CFLAGS ?= -O2
CFLAGS += -std=c11 -Wall -Wextra -Wpedantic
CPPFLAGS += $(shell pkg-config --cflags mpfr)
LDLIBS += $(shell pkg-config --libs mpfr)

GENERATOR := build/generate
OUTPUT := ../../../src/test/tanhf/oracle_test.mbt
SAMPLES_PER_STRATUM ?= 4096
MAX_ULP ?= 2

.PHONY: all generate verify clean

all: generate

$(GENERATOR): generate.c
	mkdir -p build
	$(CC) $(CPPFLAGS) $(CFLAGS) $< $(LDLIBS) -o $@

generate: $(GENERATOR)
	$(GENERATOR) --samples-per-stratum $(SAMPLES_PER_STRATUM) --max-ulp $(MAX_ULP) > $(OUTPUT).tmp
	mv $(OUTPUT).tmp $(OUTPUT)

verify: $(GENERATOR)
	$(GENERATOR) --samples-per-stratum $(SAMPLES_PER_STRATUM) --max-ulp $(MAX_ULP) > $(OUTPUT).tmp
	cmp $(OUTPUT).tmp $(OUTPUT)
	rm $(OUTPUT).tmp

clean:
	rm -rf build
