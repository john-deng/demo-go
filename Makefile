
APP_VERSION ?= $(shell ./scripts/git-version)
HUB ?= registry.cn-shenzhen.aliyuncs.com
IMG ?= ${HUB}/titanide/titan-proxy:${APP_VERSION}

all: docker-build docker-push

help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)


docker-build: # test ## Build docker image with the manager.
	docker build --build-arg APP_VERSION=${APP_VERSION} -t ${IMG} .

docker-push:
	docker push ${IMG}