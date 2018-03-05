APP_NAME ?= $(shell basename `pwd`)
APP_VERSION ?= $(shell _deployman/bin/app-version.sh)
APP_VERSION2 ?= $(shell _deployman/bin/app-version.sh 2)
DOCKER_DOMAIN ?= aufish
GITHUB_DOMAIN ?= aufishgrp
