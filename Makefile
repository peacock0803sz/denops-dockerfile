DENOPS_VERSION := main
DOCKER_REGISTRY := ghcr.io/peacock0803sz
DOCKER_TAG := latest

.DEFAULT_GOAL := help

help:
	@cat $(MAKEFILE_LIST) | \
	    perl -ne 'print if /^\w+.*##/;' | \
	    perl -pe 's/(.*):.*##\s*/sprintf("%-20s",$$1)/eg;'

build: build-vim build-neovim	## Build

build-vim: FORCE	## Build (Vim)
	docker buildx build ${BUILD_ARGS} \
		--build-arg DENOPS_VERSION=${DENOPS_VERSION} \
		-t ${DOCKER_REGISTRY}/vim \
		-f Dockerfile.vim \
		.

build-neovim: FORCE	## Build (Neovim)
	docker buildx build ${BUILD_ARGS} \
		--build-arg DENOPS_VERSION=${DENOPS_VERSION} \
		-t ${DOCKER_REGISTRY}/neovim \
		-f Dockerfile.neovim \
		.

push: push-vim push-neovim	## Push

push-vim: FORCE	## Push (Vim)
	docker tag ${DOCKER_REGISTRY}/vim ${DOCKER_REGISTRY}/vim:${DOCKER_TAG}
	docker push ${DOCKER_REGISTRY}/vim:${DOCKER_TAG}

push-neovim: FORCE	## Push (Neovim)
	docker tag ${DOCKER_REGISTRY}/neovim ${DOCKER_REGISTRY}/neovim:${DOCKER_TAG}
	docker push ${DOCKER_REGISTRY}/neovim:${DOCKER_TAG}

FORCE:
