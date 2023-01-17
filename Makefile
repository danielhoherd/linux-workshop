.DEFAULT_GOAL := help

.PHONY: help
help: ## Print Makefile help
	@grep -hE '^[a-zA-Z_-]+:.*?## .*$$' ${MAKEFILE_LIST} | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

SUDO            = $(shell which sudo)
IMAGE_NAME     ?= quay.io/danielhoherd/uw
CONTAINER_NAME ?= ${IMAGE_NAME}
NO_CACHE       ?= false
ORG_PREFIX     ?= danielhoherd
GIT_ORIGIN      = $(shell git config --get remote.origin.url)
GIT_BRANCH      = $(shell git rev-parse --abbrev-ref HEAD)
GIT_SHA_SHORT   = $(shell if [ ! -z "`git status --porcelain`" ] ; then echo "DIRTY" ; else git rev-parse --short HEAD ; fi)
GIT_SHA_LONG    = $(shell if [ ! -z "`git status --porcelain`" ] ; then echo "DIRTY" ; else git rev-parse HEAD ; fi)
BUILD_TIME      = $(shell date '+%s')
BUILD_DATE_F    = $(shell date '+%F')
BUILD_DATE_Y_M  = $(shell date '+%Y-%m')
RESTART        ?= always

.PHONY: all
all: docker-build

.PHONY: clean-dirty
clean-dirty: ## Delete DIRTY tags
	docker images | awk '$$1 == "quay.io/danielhoherd/uw" && $$2 ~ /-DIRTY-/ {printf "%s:%s\n", $$1, $$2}' | xargs -r docker rmi

.PHONY: docker-push
docker-push: clean-dirty ## Push built container to docker hub
	docker push -a ${IMAGE_NAME}

.PHONY: build
build: docker-build
.PHONY: docker-build
docker-build: ## Build the Dockerfile found in PWD
	docker build --no-cache=${NO_CACHE} \
		-t "${IMAGE_NAME}:latest" \
		-t "${IMAGE_NAME}:${GIT_BRANCH}-${BUILD_DATE_F}" \
		-t "${IMAGE_NAME}:${GIT_BRANCH}-${GIT_SHA_SHORT}-${BUILD_DATE_F}" \
		-t "${IMAGE_NAME}:${BUILD_DATE_Y_M}" \
		--label quay.expires-after=8w \
		--label "${ORG_PREFIX}.repo.origin=${GIT_ORIGIN}" \
		--label "${ORG_PREFIX}.repo.branch=${GIT_BRANCH}" \
		--label "${ORG_PREFIX}.repo.commit=${GIT_SHA_LONG}" \
		--label "${ORG_PREFIX}.build_time=${BUILD_TIME}" \
		.

.PHONY: install-hooks
install-hooks: ## Install git hooks
	pip3 install --user --upgrade pre-commit || \
	pip install --user --upgrade pre-commit
	pre-commit install -f --install-hooks

.PHONY: docker-run
docker-run: build ## Build and run the Dockerfile in pwd
	docker run \
		-d \
		--restart=${RESTART} \
		--name=${CONTAINER_NAME} \
		--net=host \
		--mount type=bind,src="/etc/localtime",dst="/etc/localtime",readonly \
		--mount type=bind,src="${PWD}",dst="/data" \
		${IMAGE_NAME}

.PHONY: docker-debug
docker-debug: build ## Build and debug the Dockerfile in pwd
	docker run \
		--interactive \
		--tty \
		--rm \
		--name=${NAME}-debug \
		--net=host \
		--mount type=bind,src="/etc/localtime",dst="/etc/localtime",readonly \
		--mount type=bind,src="${PWD}",dst="/data" \
		${IMAGE_NAME} bash

.PHONY: docker-test
docker-test: ## Test that the container functions
	docker run --rm -it ${IMAGE_NAME} fping localhost

.PHONY: docker-stop
docker-stop: ## Delete deployed container
	-docker stop ${CONTAINER_NAME}

.PHONY: docker-delete
docker-delete: rm
.PHONY: docker-rm
docker-rm: stop ## Delete deployed container
	-docker rm --force ${CONTAINER_NAME}
	-docker rm --force ${CONTAINER_NAME}-debug

.PHONY: docker-pull
docker-pull: ## Pull the latest container
	docker pull $$(awk '/^FROM/ {print $$2 ; exit ;}' Dockerfile)
	docker pull "${IMAGE_NAME}"

.PHONY: docker-logs
docker-logs: ## View the last 30 minutes of log entries
	docker logs --since 30m ${CONTAINER_NAME}

.PHONY: docker-info
docker-info: ## Show info about docker
	docker info
	docker version

.PHONY: docker-inspect
docker-inspect: ## Inspect the built docker image
	docker inspect "${IMAGE_NAME}:${GIT_BRANCH}-${GIT_SHA_SHORT}-${BUILD_DATE_F}"

.PHONY: show-packages
show-packages: ## Show list of packages installed in the built image
	docker run -t --rm "${IMAGE_NAME}:${GIT_BRANCH}-${GIT_SHA_SHORT}-${BUILD_DATE_F}" /bin/bash -x -c "dpkg -l --no-pager ; pip freeze ;"

.PHONY: docker-bounce
docker-bounce: build rm run ## Rebuild, rm and run the Dockerfile

.PHONY: clean
clean:
	docker images | awk '$$1 == "${IMAGE_NAME}" {print $$3}' | sort -u | xargs -r -n1 docker rmi -f
