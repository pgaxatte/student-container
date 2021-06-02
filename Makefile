.PHONY: all ssh theia
.DEFAULT: all

all: ssh theia

ssh:
	@cd ssh; docker build -t student:ssh .

theia:
	@cd theia; docker build -t student:theia .
