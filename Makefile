export NAME_CONTAINER=hyperpigeon/vc_base
export PWD=`pwd`
export HOSTNAME=pigeon
# mp3は鳴らない(というかバグる)
export SOUNDFILE=./src/pc.wav
# ========================================
# container -> host
# ========================================

## host: host to container
export UNAME=root
bs: ## [docker] Build-Server
	docker build -f ./Docker/Dockerfile.test -t mictest .
	docker run -it --rm \
		-v $(PWD):/work/ \
		-v ~/.config/pulse:/$(UNAME)/.config/pulse \
		mictest
server: ## [docker]  
	@pulseaudio -D --exit-idle-time=-1 
	@pacmd load-module module-pipe-sink file=/dev/audio format=s16 rate=44100 channels=2

## host: host settings



aplay: ## [sound] ringing sound, framerate(44.1kHz), channels(2)
	aplay $(SOUNDFILE) -r 44100 -c 2

# ====================
# host -> container
# ====================
play-on-mac: ## [sound] ringing for mac
	afplay $(SOUNDFILE)
setup-mac:
	brew install sox
	brew install pulseaudio
	brew services start pulseaudio
	brew service restart pulseaudio

run-host: ## [sound] connect container->mac
	ps -ax | grep pulse
	pacmd load-module module-native-protocol-unix socket=/tmp/pulseaudio.socket
	pulseaudio --load=module-native-protocol-tcp --exit-idle-time=-1 --daemon --system
	pulseaudio --check -v
	pulseaudio --start
# ====================
# Check Env
# ====================
audio-env: ## [sound] check Audio card
	aplay -l

	
# ====================
# General Purpose
# ====================
export NONE_DOCKER_IMAGES=`docker images -f dangling=true -q`
export STOPPED_DOCKER_CONTAINERS=`docker ps -a -q`

# ---
clean: ## [docker] clean images&containers
	-@make clean-images
	-@make clean-containers
clean-images:
	docker rmi $(NONE_DOCKER_IMAGES) -f
clean-containers:
	docker rm -f $(STOPPED_DOCKER_CONTAINERS)
# ---
help: ## this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
