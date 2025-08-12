.DEFAULT_GOAL := help

.PHONY: help
help: ## Print Makefile help
	@grep -hE '^[a-zA-Z_-]+:.*?## .*$$' ${MAKEFILE_LIST} | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[1;36m%-22s\033[0m %s\n", $$1, $$2}'

IMAGE_NAME     ?= quay.io/danielhoherd/lw
NO_CACHE       ?= false
ORG_PREFIX     ?= danielhoherd
GIT_ORIGIN      = $(shell git config --get remote.origin.url)
GIT_BRANCH      = $(shell git rev-parse --abbrev-ref HEAD)
GIT_SHA_SHORT   = $(shell if [ ! -z "`git status --porcelain`" ] ; then echo "DIRTY" ; else git rev-parse --short HEAD ; fi)
GIT_SHA_LONG    = $(shell if [ ! -z "`git status --porcelain`" ] ; then echo "DIRTY" ; else git rev-parse HEAD ; fi)
BUILD_TIME      = $(shell date '+%s')
BUILD_DATE_F    = $(shell date '+%F')
BUILD_DATE_Y_M  = $(shell date '+%Y-%m')
DISTRO         ?= debian

.PHONY: all
all: docker-build

.PHONY: build-and-push
build-and-push: docker-build-and-push
.PHONY: docker-build-and-push
docker-build-and-push: ## Build the Dockerfile found in PWD for multiple architectures and push it to the registry
	# In order to build for multiple architectures and not use buildx, we need to push in the same step.
	for platform in amd64 arm64 ; do \
		docker build \
			--push \
			--platform linux/$${platform} \
			--no-cache=${NO_CACHE} \
			--file "Dockerfile.${DISTRO}" \
			--tag "${IMAGE_NAME}:${DISTRO}-$${platform}" \
			--label quay.expires-after=8w \
			--label "${ORG_PREFIX}.repo.origin=${GIT_ORIGIN}" \
			--label "${ORG_PREFIX}.repo.branch=${GIT_BRANCH}" \
			--label "${ORG_PREFIX}.repo.commit=${GIT_SHA_LONG}" \
			--label "${ORG_PREFIX}.build_time=${BUILD_TIME}" \
			. ; \
	done

	docker manifest annotate "${IMAGE_NAME}:${DISTRO}" \
			"${IMAGE_NAME}:${DISTRO}-arm64" \
			--os linux \
			--arch arm64

	docker manifest annotate "${IMAGE_NAME}:${DISTRO}" \
			"${IMAGE_NAME}:${DISTRO}-amd64" \
			--os linux \
			--arch amd64

	docker tag "${IMAGE_NAME}:${DISTRO}" "${IMAGE_NAME}:${DISTRO}-latest"
	docker tag "${IMAGE_NAME}:${DISTRO}" "${IMAGE_NAME}:${DISTRO}-${BUILD_DATE_Y_M}"
	docker tag "${IMAGE_NAME}:${DISTRO}" "${IMAGE_NAME}:${DISTRO}-${BUILD_DATE_F}"
	docker tag "${IMAGE_NAME}:${DISTRO}" "${IMAGE_NAME}:${DISTRO}-${GIT_SHA_SHORT}"

	docker manifest push "${IMAGE_NAME}:${DISTRO}"
	docker images | awk '$2 ~ /-DIRTY/ {printf "%s:%s\n", $1, $2}' | xargs -n1 docker rmi
	docker push --all-tags "${IMAGE_NAME}"

.PHONY: clean
clean:
	docker images | awk '$$1 == "${IMAGE_NAME}" {print $$3}' | sort -u | xargs -r -n1 docker rmi -f

.PHONY: clean-dirty
clean-dirty: ## Delete DIRTY tags
	docker images | awk '$$1 == "quay.io/danielhoherd/lw" && $$2 ~ /-DIRTY-/ {printf "%s:%s\n", $$1, $$2}' | xargs -r docker rmi
