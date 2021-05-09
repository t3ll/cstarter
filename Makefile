CLEANUP := rm -f

PATH_SRC = src/

PATH_BUILD = build/
PATH_BIN   = build/bin/
PATH_DEPS  = build/depends/
PATH_OBJS  = build/objs/

PATH_TEST = test/

PATH_TEST_BIN     = build/test/bin/
PATH_TEST_DEPS    = build/test/depends/
PATH_TEST_OBJS    = build/test/objs/
PATH_TEST_RESULTS = build/test/results/

BUILD_PATHS = $(PATH_BUILD) $(PATH_BIN) $(PATH_DEPS) $(PATH_OBJS) \
	      $(PATH_TEST_BIN) $(PATH_TEST_DEPS) $(PATH_TEST_OBJS) $(PATH_TEST_RESULTS)

CREATE_BUILD_PATHS := $(shell mkdir -p $(BUILD_PATHS))

SRC  = $(wildcard $(PATH_SRC)*.c)
OBJS = $(patsubst $(PATH_SRC)%.c,$(PATH_OBJS)%.o,$(SRC))
DEPS = $(patsubst $(PATH_SRC)%.c,$(PATH_DEPS)%.d,$(SRC))

TESTS        = $(wildcard $(PATH_TEST)*.c)
TEST_DEPS    = $(patsubst $(PATH_TEST)%.c,$(PATH_TEST_DEPS)%.d,$(TESTS))
TEST_RESULTS = $(patsubst $(PATH_TEST)%.c,$(PATH_TEST_RESULTS)%.txt,$(TESTS))

CC          = gcc
LINK        = gcc

CFLAGS      = -g -Werror -I. -I$(PATH_SRC)
TEST_CFLAGS = -g -Werror -I. -I$(PATH_SRC) -I$(PATH_TEST)

DEP_FLAGS   = -MM -MG -MF

#---------------------------------------
# Program
#---------------------------------------

program: $(PATH_BIN)program

$(PATH_BIN)program: build
	$(CC) $(CFLAGS) -o $(PATH_BIN)program $(OBJS)

#---------------------------------------
# Run
#---------------------------------------

run: program
	$(PATH_BIN)program

#---------------------------------------
# Build 
#---------------------------------------

build: $(OBJS)

$(PATH_OBJS)%.o: $(PATH_SRC)%.c
	$(CC) -c $(CFLAGS) $< -o $@

#---------------------------------------
# Deps
#---------------------------------------

include $(DEPS)

$(PATH_DEPS)%.d: $(PATH_SRC)%.c
	set -e; rm -f $@; \
	$(CC) $(DEP_FLAGS) $@.1 $<; \
	sed 's,\($*\)\.o[ :]*,$(PATH_OBJS)\1.o $@ : ,g' < $@.1 > $@; \
	rm $@.1;

#---------------------------------------
# Test
#---------------------------------------

test: $(TEST_RESULTS)
	! grep -s FAILED $(PATH_TEST_RESULTS)*.txt

$(PATH_TEST_RESULTS)%.txt: $(PATH_TEST_BIN)%.out
	-./$< > $@ 2>&1

$(PATH_TEST_BIN)test_%.out: $(PATH_TEST_OBJS)test_%.o $(PATH_OBJS)%.o
	$(LINK) -o $@ $^

$(PATH_TEST_OBJS)%.o: $(PATH_TEST)%.c
	$(CC) -c $(TEST_CFLAGS) $< -o $@

#---------------------------------------
# Deps (Test)
#---------------------------------------

include $(TEST_DEPS)

$(PATH_TEST_DEPS)%.d: $(PATH_TEST)%.c
	set -e; rm -f $@; \
	$(CC) $(DEP_FLAGS) $@.1 $<; \
	sed 's,\($*\)\.o[ :]*,$(PATH_TEST_OBJS)\1.o $@ : ,g' < $@.1 > $@; \
	rm $@.1;

#--------------------------------------
# Clean
#---------------------------------------

.PHONY: clean

clean:
	$(CLEANUP) -r $(PATH_BUILD)

.PRECIOUS: $(PATH_DEPENDS)%.d
.PRECIOUS: $(PATH_OBJS)%.o
.PRECIOUS: $(PATH_TEST_BIN)test_%.out
.PRECIOUS: $(PATH_TEST_DEPS)%.d
.PRECIOUS: $(PATH_TEST_OBJS)%.o
.PRECIOUS: $(PATH_TEST_RESULTS)%.txt