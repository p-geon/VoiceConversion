# ====================
# Check Env
# ====================
audio-env: ## sound/check Audio card
	aplay -l

# ====================
# General Purpose
# ====================
export NONE_DOCKER_IMAGES=`docker images -f dangling=true -q`
export STOPPED_DOCKER_CONTAINERS=`docker ps -a -q`

# ---
clean: ## docker/clean images&containers
	-@make clean-images
	-@make clean-containers
clean-images:
	docker rmi $(NONE_DOCKER_IMAGES) -f
clean-containers:
	docker rm -f $(STOPPED_DOCKER_CONTAINERS)

# ====================
# sound: host -> container
# ====================
help: ## utils/this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN \
			{FS = ":"}; \
			{sub("Makefile", "");}; \
			{split(substr($$3, 5), arr, "/")}; \
			{printf "\033[31m %-s\033[36m%-10s \033[0m[\033[33m %-7s\033[0m] %-7s \n" \
				, $$1 \
				, $$2 \
				, arr[1] \
				, arr[2] \
			}'
