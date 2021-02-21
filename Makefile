export NAME_CONTAINER=hyperpigeon/vc_base
export PWD=`pwd`
# ====================
# docker
br:
	@make b
	@make r
b: ## build notebook & lab 
	docker build -f ./Dockerfile -t $(NAME_CONTAINER) .
r: ## run jupyter notebook
	docker run -it --rm -v $(PWD):/work/ $(NAME_CONTAINER)
# ====================
# docker commands
export NONE_DOCKER_IMAGES=`docker images -f dangling=true -q`
export STOPPED_DOCKER_CONTAINERS=`docker ps -a -q`
clean: ## clean images&containers
	-@make clean-images
	-@make clean-containers
clean-images:
	docker rmi $(NONE_DOCKER_IMAGES) -f
clean-containers:
	docker rm -f $(STOPPED_DOCKER_CONTAINERS)
# ====================
# help
.PHONY: help
help: ## this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'