export NAME_CONTAINER=hyperpigeon/vc_base
export PWD=`pwd`
export EXPOSED_PORT=3000
# ====================
# Core
# ====================
br:
	@make b
	@make r

b: ## build notebook & lab 
	docker build -f ./Dockerfile \
		-t $(NAME_CONTAINER) . \
		--build-arg EXPOSED_PORT=$(EXPOSED_PORT)

r: ## run jupyter notebook
	docker run -it --rm \
		-v $(PWD):/work/ \
		-v ~/.config/pulse:/root/.config/pulse \
		-e PULSE_SERVER=docker.for.mac.localhost \
		$(NAME_CONTAINER) \
		/bin/bash

app: ## run jupyter notebook
	docker run -it --rm \
		-v $(PWD):/work/ \
		-p $(EXPOSED_PORT):$(EXPOSED_PORT) \
		$(NAME_CONTAINER) \
		python scripts/check_audio_io.py
# ====================
# Audio commands
# ====================
export SOUNDFILE=./src/pc.wav
# ↑ mp3は鳴らない

# for Ubuntu
audio-env: ## check Audio card
	aplay -l
aplay: ## for Ubuntu
	aplay $(SOUNDFILE) -r 44100 -c 2
# ---
# for mac
play-on-mac: ## for mac
	afplay $(SOUNDFILE)
setup-mac:
	brew install sox
	brew install pulseaudio
	brew services start pulseaudio
run-host: ## receive container sound
	pulseaudio --load=module-native-protocol-tcp \
		--exit-idle-time=-1 --daemon
	pulseaudio --check -v
# ====================
# docker commands
# ====================
export NONE_DOCKER_IMAGES=`docker images -f dangling=true -q`
export STOPPED_DOCKER_CONTAINERS=`docker ps -a -q`
clean: ## [docker] clean images&containers
	-@make clean-images
	-@make clean-containers
clean-images:
	docker rmi $(NONE_DOCKER_IMAGES) -f
clean-containers:
	docker rm -f $(STOPPED_DOCKER_CONTAINERS)

# ====================
# General Purpose
# ====================
.PHONY: help
help: ## this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'