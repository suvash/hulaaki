.PHONY: test init

init:
	mix do deps.get, deps.compile

test:
	mix test
