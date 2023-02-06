### Defensive settings for make:
#     https://tech.davis-hansson.com/p/make/
SHELL:=bash
.ONESHELL:
.SHELLFLAGS:=-xeu -o pipefail -O inherit_errexit -c
.SILENT:
.DELETE_ON_ERROR:
MAKEFLAGS+=--warn-undefined-variables
MAKEFLAGS+=--no-builtin-rules

IMAGE_NAME=ghcr.io/ericof/frontend
VOLTO_VERSION=$$(cat version.txt)
IMAGE_TAG=${VOLTO_VERSION}

# We like colors
# From: https://coderwall.com/p/izxssa/colored-makefile-for-golang-projects
RED=`tput setaf 1`
GREEN=`tput setaf 2`
RESET=`tput sgr0`
YELLOW=`tput setaf 3`

.PHONY: all
all: build-images

# Add the following 'help' target to your Makefile
# And add help text after each target name starting with '\#\#'
.PHONY: help
help: ## This help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: image_name
image_name: ## Print Version
	@echo "$(IMAGE_NAME)-(builder|dev|prod):$(IMAGE_TAG)"

.PHONY: build-image-builder
build-image-builder:  ## Build Base Image
	@echo "Building $(IMAGE_NAME)-builder:$(IMAGE_TAG)"
	@docker buildx build . --build-arg VOLTO_VERSION=${VOLTO_VERSION} -t $(IMAGE_NAME)-builder:$(IMAGE_TAG) -f Dockerfile.builder --load

.PHONY: build-image-dev
build-image-dev:  ## Build Dev Image
	@echo "Building $(IMAGE_NAME)-dev:$(IMAGE_TAG)"
	@docker buildx build . --build-arg VOLTO_VERSION=${VOLTO_VERSION} -t $(IMAGE_NAME)-dev:$(IMAGE_TAG) -f Dockerfile.dev --load

.PHONY: build-image-prod
build-image-prod:  ## Build Prod Image
	@echo "Building $(IMAGE_NAME)-prod:$(IMAGE_TAG)"
	@docker buildx build . --build-arg VOLTO_VERSION=${VOLTO_VERSION} -t $(IMAGE_NAME)-prod:$(IMAGE_TAG) -f Dockerfile.prod --load

.PHONY: build-images
build-images:  ## Build Images
	@echo "Building $(IMAGE_NAME)-(builder|dev|prod):$(IMAGE_TAG) images"
	$(MAKE) build-image-builder
	$(MAKE) build-image-dev
	$(MAKE) build-image-prod
