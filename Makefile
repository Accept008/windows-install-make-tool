# 镜像仓库地址(阿里云上对应的镜像仓库地址)
DOCKER_IMAGE_REPO=registry.cn-hangzhou.aliyuncs.com/bus/spring-boot-service
# 镜像版本 可直接直接修改,也可命令传参(eg: make DOCKER_IMAGE_VERSION=123)
DOCKER_IMAGE_VERSION=2.2.2
# 部署环境(qa、uat、prod);可直接直接修改,也可命令传参(eg: make DOCKER_IMAGE_VERSION=123 DEPLOYMENT_ENV=dev)
DEPLOYMENT_ENV=dev
# 本地镜像ID(windows系统需要安装grep和awk支持,且print处需使用双引号;linux系统print处使用单引号)
DOCKER_IMAGE_RMI_ID:=$(shell docker images | grep $(DOCKER_IMAGE_REPO) | awk '{print $$3}')
#DOCKER_IMAGE_RMI_ID:=$(shell docker images | grep  $(DOCKER_IMAGE_REPO) | awk "{print $$3}")

#获取当前分支名(可用于设定版本号)
CURRENT_GIT_BRANCH_VERSION:=$(shell git symbolic-ref --short HEAD)

all: mvn docker-image-build-push k8s-apply

#打包服务
mvn:
	@mvn clean
	@mvn install -DskipTests -Dfindbugs

docker-image-build-push:
	@docker build -t $(DOCKER_IMAGE_REPO):$(DOCKER_IMAGE_VERSION) .
	@docker push $(DOCKER_IMAGE_REPO):$(DOCKER_IMAGE_VERSION)

#查看镜像ID信息
docker-image-id:
	$(warning  $(DOCKER_IMAGE_RMI_ID))

#不能和构建镜像同时执行,需单独执行(删除本地镜像的所有版本)
docker-image-delete:
	@docker rmi -f $(DOCKER_IMAGE_RMI_ID)

#部署Kubernetes(k8s)集群
k8s-apply:
	@cd k8s/kustomize/overlays/$(DEPLOYMENT_ENV) && kustomize build .
	#| kubectl apply -f-

#从Kubernetes(k8s)集群移除
k8s-delete:
	@cd k8s/kustomize/overlays/$(DEPLOYMENT_ENV) && kustomize build .
	#| kubectl delete -f-