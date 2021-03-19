export NAME_CONTAINER=hyperpigeon/vc_base
export PWD=`pwd`
export HOSTNAME=pigeon
# ====================
# Host
# ====================
br: ## [docker] build & run
	@make b
	@make r
b:
	make build
r:
	make run

# ---
build: ## [docker] build container
	docker build -f ./Dockerfile \
		--build-arg EXPOSED_PORT=3000 \
		-t $(NAME_CONTAINER) .

export MEM_LIMIT=1300m
define run
	docker run -it --rm \
		-v $(PWD):/work/ \
		-v ~/.config/pulse:/root/.config/pulse \
		-e PULSE_SERVER=docker.for.mac.localhost \
		-p 127.0.0.1:3000:3000 \
		--hostname=$(HOSTNAME) \
		--shm-size=$(MEM_LIMIT) \
		$(NAME_CONTAINER) \
		$(1)
endef

run: ## [docker] alias
	$(call run, /bin/bash)
ring: ## [docker] run sound
	$(call run, make aplay)
app: ## [docker] run script
	#$(call run, python scripts/check_audio_io.py)
	$(call run, python scripts/vc_to_f.py)
# --------------------------------------------------------
# Container
# --------------------------------------------------------
init:
	@pulseaudio -D --exit-idle-time=-1 
	@pacmd load-module module-pipe-sink file=/dev/audio format=s16 rate=44100 channels=2
	@tmux
runner: ## [tmux]
	@tmux split-window -v
	@tmux select-pane -t 0
	@tmux send-keys "socat file:/dev/audio tcp-listen:3000" Enter
	@tmux select-pane -t 1
	@tmux send-keys "python3 scripts/vc_to_f.py" Enter
# --------------------------------------------------------
# TEST
# --------------------------------------------------------
# make a, b, c
# make d

# container
a:
	make build
	make run
b:
	@pulseaudio -D --exit-idle-time=-1
	@pacmd load-module module-pipe-source file=/dev/audio format=s16 rate=44100 channels=2
	@socat tcp-listen:3000 file:/dev/audio &
c1:
	arecord /work/test.wav
c2:
	python3 scripts/vc_to_f.py
d:
	rec --encoding signed-integer -traw --bits 16 --channels 2 --rate 44100 - | nc 127.0.0.1 3000 > /dev/null
#@arecord ./test.wav
# ====================
# Audio commands
# ====================
export SOUNDFILE=./src/pc.wav
# ↑ mp3は鳴らない(というかバグる)

# for Ubuntu
audio-env: ## [sound] check Audio card
	aplay -l

aplay: ## [sound] ringing sound, framerate(44.1kHz), channels(2)
	aplay $(SOUNDFILE) -r 44100 -c 2
# ---
# for mac
play-on-mac: ## [sound] ringing for mac
	afplay $(SOUNDFILE)
setup-mac:
	brew install sox
	brew install pulseaudio
	brew services start pulseaudio
run-host: ## [sound] connect container->mac
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
help: ## this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'