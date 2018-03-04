APP_NAME ?= $(shell basename `pwd`)
APP_VERSION ?= $(shell _deployman/bin/app-version.sh)
DOCKER_DOMAIN ?= aufish
GITHUB_DOMAIN ?= aufishgrp
