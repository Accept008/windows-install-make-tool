# 镜像仓库地址(阿里云上对应的镜像仓库地址)
DOCKER_IMAGE_REPO=registry.cn-hangzhou.aliyuncs.com/bus/spring-boot-service
# 镜像版本 可直接直接修改,也可命令传参(eg: make DOCKER_IMAGE_VERSION=123)
DOCKER_IMAGE_VERSION=debug
# 部署环境(qa、uat、prod);可直接直接修改,也可命令传参(eg: make DOCKER_IMAGE_VERSION=123 DEPLOYMENT_ENV=dev)
DEPLOYMENT_ENV=dev

#获取当前分支名
CURRENT_GIT_BRANCH_VERSION := $(shell git symbolic-ref --short HEAD)

all: mvn docker-build-push k8s-apply

mvn:
	@mvn clean
	@mvn install -DskipTests -Dfindbugs

docker-build-push:
	@docker build -t $(DOCKER_IMAGE_REPO):$(DOCKER_IMAGE_VERSION) .
	@docker push $(DOCKER_IMAGE_REPO):$(DOCKER_IMAGE_VERSION)

k8s-apply:
	@cd k8s/kustomize/overlays/$(DEPLOYMENT_ENV) && kustomize build .
	#| kubectl apply -f-

k8s-delete:
	@cd k8s/kustomize/overlays/$(DEPLOYMENT_ENV) && kustomize build .
	#| kubectl delete -f-