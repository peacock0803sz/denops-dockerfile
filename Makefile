DENOPS_VERSION := main
DOCKER_REGISTRY := ghcr.io/peacock0803sz
DOCKER_TAG := latest

# amd64 or arm64
ARCH_NAME := amd64

.DEFAULT_GOAL := help

help:
	@cat $(MAKEFILE_LIST) | \
	    perl -ne 'print if /^\w+.*##/;' | \
	    perl -pe 's/(.*):.*##\s*/sprintf("%-20s",$$1)/eg;'

build: build-vim build-neovim	## Build

build-vim: FORCE	## Build (Vim)
	docker buildx build ${BUILD_ARGS} \
		--load \
			--cache-from=${DOCKER_REGISTRY}/denops-cache/base-vim \
			--cache-to=type=registry,ref=${DOCKER_REGISTRY}/denops-cache/base-vim,mode=max \
		-t base-vim \
		-f Dockerfile.base-vim \
		.
	docker buildx build ${BUILD_ARGS} \
		--load \
			--cache-from=${DOCKER_REGISTRY}/denops-cache/base-denops \
			--cache-to=type=registry,ref=${DOCKER_REGISTRY}/denops-cache/base-denops,mode=max \
		--build-arg DENOPS_VERSION=${DENOPS_VERSION} \
		-t base-denops \
		-f Dockerfile.denops \
		.
	docker buildx build ${BUILD_ARGS} \
		--load \
			--cache-from=${DOCKER_REGISTRY}/denops-cache/base-vim \
			--cache-from=${DOCKER_REGISTRY}/denops-cache/base-denops \
			--cache-to=type=registry,ref=${DOCKER_REGISTRY}/denops-cache/vim,mode=max \
		-t denops-dockerfile/vim \
		-f Dockerfile.${ARCH_NAME}-vim \
		.

build-neovim: FORCE	## Build (Neovim)
	docker buildx build ${BUILD_ARGS} \
		--load \
			--cache-from=${DOCKER_REGISTRY}/denops-cache/base-neovim \
			--cache-to=type=registry,ref=${DOCKER_REGISTRY}/denops-cache/base-neovim,mode=max \
		-t base-neovim \
		-f Dockerfile.base-neovim \
		.
	docker buildx build ${BUILD_ARGS} \
		--load \
			--cache-from=${DOCKER_REGISTRY}/denops-cache/base-denops \
			--cache-to=type=registry,ref=${DOCKER_REGISTRY}/denops-cache/base-denops,mode=max \
		--build-arg DENOPS_VERSION=${DENOPS_VERSION} \
		-t base-denops \
		-f Dockerfile.denops \
		.
	docker buildx build ${BUILD_ARGS} \
		--load \
			--cache-from=${DOCKER_REGISTRY}/denops-cache/base-neovim \
			--cache-from=${DOCKER_REGISTRY}/denops-cache/base-denops \
			--cache-to=type=registry,ref=${DOCKER_REGISTRY}/denops-cache/neovim,mode=max \
		-t denops-dockerfile/neovim \
		-f Dockerfile.${ARCH_NAME}-neovim \
		.

push: push-vim push-neovim	## Push

push-vim: FORCE	## Push (Vim)
	docker tag denops-dockerfile/vim ${DOCKER_REGISTRY}/vim:${DOCKER_TAG}
	docker push ${DOCKER_REGISTRY}/vim:${DOCKER_TAG}

push-neovim: FORCE	## Push (Neovim)
	docker tag denops-dockerfile/neovim ${DOCKER_REGISTRY}/neovim:${DOCKER_TAG}
	docker push ${DOCKER_REGISTRY}/neovim:${DOCKER_TAG}

FORCE:
