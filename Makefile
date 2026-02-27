.PHONY: all compile clean check format lint credo test-unit

###-----------------------------------------------------------------------------
### DEVELOPMENT TARGETS
###-----------------------------------------------------------------------------
all: compile

compile:
	mix compile

clean:
	mix clean

###-----------------------------------------------------------------------------
### CODE QUALITY TARGETS
###-----------------------------------------------------------------------------
check: lint credo

format:
	mix format

lint:
	mix format --check-formatted

credo:
	mix credo --strict

###-----------------------------------------------------------------------------
### TEST TARGETS
###-----------------------------------------------------------------------------
test-unit:
	mix test
