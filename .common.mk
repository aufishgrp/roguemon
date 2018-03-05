APP_NAME ?= $(shell basename `pwd`)
APP_VERSION ?= $(shell _deployman/bin/commands.sh app-version)
APP_VERSION_3 ?= $(APP_VERSION)
APP_VERSION_2 ?= $(shell _deployman/bin/commands.sh app-version 2)
DOCKER_DOMAIN ?= aufish
GITHUB_DOMAIN ?= aufishgrp

PLATFORM ?= $(shell _deployman/bin/commands.sh platform)
