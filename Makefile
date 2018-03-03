-include .common.mk

GO_TESTS ?= ./...

build: deps
	go build cmd/${APP_NAME}/${APP_NAME}.go

deps: Gopkg.toml
	dep ensure

Gopkg.toml:
	dep init

publish: docker-prod
	docker push ${DOCKER_DOMAIN}/${APP_NAME}:${APP_VERSION}

deploy:
	## TODO: Add logic here that deploys the application.

tools:
	_deployman/bin/make-tools.sh
	## TODO: Add application specific tool install code here.	

ci:
	_deployman/bin/ci-logic.sh

test:
	go test `go list $(GO_TESTS) | egrep -v "vendor|$(APP_NAME)/cmd/integration"`

test-docker:
	## Uses the localalized deploymen image to run unit tests.
	@echo "Building docker compatible binary."
	APP_NAME=${APP_NAME} \
	docker run \
		--rm=true \
		-v $(shell pwd):/go/src/github.com/${GITHUB_DOMAIN}/${APP_NAME} \
		-w /go/src/github.com/${GITHUB_DOMAIN}/${APP_NAME} \
		${DOCKER_DOMAIN}/deploymen:${APP_NAME} test

lint:
	_deployman/bin/make-lint.sh

dev-env:
	## Creates a dev-env style docker container that can be used for development.
	docker run \
		-ti \
		--entrypoint bash \
		-v `pwd`:/go/src/github.com/${GITHUB_DOMAIN}/${APP_NAME} \
		-w /go/src/github.com/${GITHUB_DOMAIN}/${APP_NAME} \
		--name devenv_${APP_NAME} \
		-d \
		${DOCKER_DOMAIN}/deploymen:${APP_NAME}

docker: docker-prod

docker-prod: docker-binary
	## Creates a trim docker image suitable for pruduction use.
	@echo "Building production image. ${APP_NAME} ${APP_VERSION}"
	docker build \
		--build-arg APP_NAME=${APP_NAME} \
		-t ${DOCKER_DOMAIN}/${APP_NAME}:${APP_VERSION} \
		-f _deployman/src/Dockerfile.deploy \
		.

docker-binary: docker-deploymen
	## Uses the localalized deploymen image to build a docker compatible binary.
	@echo "Building docker compatible binary."
	APP_NAME=${APP_NAME} \
	docker run \
		--rm=true \
		-v $(shell pwd):/go/src/github.com/${GITHUB_DOMAIN}/${APP_NAME} \
		-w /go/src/github.com/${GITHUB_DOMAIN}/${APP_NAME} \
		${DOCKER_DOMAIN}/deploymen:${APP_NAME} build

docker-deploymen:
	## Builds a base deploymen image if one does not already exist on the system.
	@echo "Possibly building deploymen image."
	if [ -z "`docker images -q ${DOCKER_DOMAIN}/deploymen:${APP_NAME}`" ]; then \
		echo "Building deploymen image."; \
		docker build \
			-t ${DOCKER_DOMAIN}/deploymen:${APP_NAME} \
			-f _deployman/src/Dockerfile.devel \
			.; \
	else \
		echo "Base deploymen image exists."; \
	fi

docker-clean:
	## Deletes the
	docker image rm ${DOCKER_DOMAIN}/deploymen:${APP_NAME} ${DOCKER_DOMAIN}/${APP_NAME}:${APP_VERSION}
