#---------------------------------------
# Vars
#---------------------------------------

CLEANUP := rm -f

PATH_SRC = src/

PATH_BUILD = build/
PATH_BIN   = build/bin/
PATH_DEPS  = build/depends/
PATH_OBJS  = build/objs/

PATH_TEST_SRC = test/

PATH_TEST_BIN     = build/test/bin/
PATH_TEST_DEPS    = build/test/depends/
PATH_TEST_OBJS    = build/test/objs/
PATH_TEST_RESULTS = build/test/results/

BUILD_PATHS = $(PATH_BUILD) $(PATH_BIN) $(PATH_DEPS) $(PATH_OBJS) \
	      $(PATH_TEST_BIN) $(PATH_TEST_DEPS) $(PATH_TEST_OBJS) $(PATH_TEST_RESULTS)


SRC  = $(wildcard $(PATH_SRC)*.c)
OBJS = $(patsubst $(PATH_SRC)%.c,$(PATH_OBJS)%.o,$(SRC))
DEPS = $(patsubst $(PATH_SRC)%.c,$(PATH_DEPS)%.d,$(SRC))

SRC_TEST     = $(wildcard $(PATH_TEST_SRC)*.c)
DEPS_TEST    = $(patsubst $(PATH_TEST_SRC)%.c,$(PATH_TEST_DEPS)%.d,$(SRC_TEST))
TEST_RESULTS = $(patsubst $(PATH_TEST_SRC)%.c,$(PATH_TEST_RESULTS)%.txt,$(SRC_TEST))

CC          = gcc
LINK        = gcc
CFLAGS      = -g -Werror -I. -I$(PATH_SRC)
TEST_CFLAGS = -g -Werror -I. -I$(PATH_SRC) -I$(PATH_TEST_SRC)
DEPS_FLAGS   = -MM -MG -MF

#---------------------------------------
# Init
#---------------------------------------

CREATE_BUILD_PATHS := $(shell mkdir -p $(BUILD_PATHS))

#---------------------------------------
# Target: dist 
#---------------------------------------

.PHONY: dist

dist: $(PATH_BIN)program

$(PATH_BIN)program: build
	$(CC) $(CFLAGS) -o $(PATH_BIN)program $(OBJS)

#---------------------------------------
# Target: run
#---------------------------------------

run: dist
	@$(PATH_BIN)program

#---------------------------------------
# Target: build 
#---------------------------------------

build: $(OBJS)

$(PATH_OBJS)%.o: $(PATH_SRC)%.c
	$(CC) -c $(CFLAGS) $< -o $@

#---------------------------------------
# Gen & Include build deps
#---------------------------------------

include $(DEPS)

$(PATH_DEPS)%.d: $(PATH_SRC)%.c
	@set -e; rm -f $@; \
	$(CC) $(DEPS_FLAGS) $@.1 $<; \
	sed 's,\($*\)\.o[ :]*,$(PATH_OBJS)\1.o $@ : ,g' < $@.1 > $@; \
	rm $@.1;

#---------------------------------------
# Target: test
#---------------------------------------

.PHONY: test

test:
	@$(MAKE) run_test --silent

run_test: $(TEST_RESULTS)
	@-! grep -s FAILED $(PATH_TEST_RESULTS)*.txt

$(PATH_TEST_RESULTS)%.txt: $(PATH_TEST_BIN)%.out
	@-./$< > $@ 2>&1

$(PATH_TEST_BIN)test_%.out: $(PATH_TEST_OBJS)test_%.o $(PATH_OBJS)%.o
	$(LINK) -o $@ $^

$(PATH_TEST_OBJS)%.o: $(PATH_TEST_SRC)%.c
	$(CC) -c $(TEST_CFLAGS) $< -o $@

#---------------------------------------
# Gen & Include test deps
#---------------------------------------

include $(DEPS_TEST)

$(PATH_TEST_DEPS)%.d: $(PATH_TEST_SRC)%.c
	@set -e; rm -f $@; \
	$(CC) $(DEPS_FLAGS) $@.1 $<; \
	sed 's,\($*\)\.o[ :]*,$(PATH_TEST_OBJS)\1.o $@ : ,g' < $@.1 > $@; \
	rm $@.1;

#--------------------------------------
# Target: clean
#---------------------------------------

.PHONY: clean

clean:
	@$(CLEANUP) -r $(PATH_BUILD)

#--------------------------------------
# .PRECIOUS
#---------------------------------------

.PRECIOUS: $(PATH_DEPENDS)%.d
.PRECIOUS: $(PATH_OBJS)%.o
.PRECIOUS: $(PATH_TEST_BIN)test_%.out
.PRECIOUS: $(PATH_TEST_DEPS)%.d
.PRECIOUS: $(PATH_TEST_OBJS)%.o
.PRECIOUS: $(PATH_TEST_RESULTS)%.txt
