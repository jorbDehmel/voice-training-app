cwd := $(shell pwd)

# Enter into the docker container
.PHONY: run
run:	| build Makefile
	docker run --mount type=bind,source="${cwd}/app",target="/home/user/app" -i -t flutter:latest /bin/bash

.PHONY:	build
build:	| Makefile
	docker build --tag 'flutter' .
