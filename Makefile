.PHONY: all ssh theia
.DEFAULT: all

all: ssh theia theia-focal

ssh:
	@cd ssh; docker build -t student:ssh .

theia:
	@cd ssh; docker build -t student:theia .

theia-focal:
	@cd ssh; docker build -t student:theia-focal -f Dockerfile.focal .
