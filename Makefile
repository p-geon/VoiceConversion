export NAME_C2H=hyperpigeon/container2host
export NAME_H2C=hyperpigeon/host2container
export PWD=`pwd`
export HOSTNAME=pigeon
# mp3は鳴らない(というかバグる)
export SOUNDFILE=./src/pc.wav
## host/host to container
include ./utils/Makefile
include ./utils/pulseaudio/Makefile

# ========================================
# # sound: container -> host
# make build-c2h
# make run-c2h
# (container) make init-c2h
# ---
# (mac) make host-c2h
# ========================================

build-c2h: ## docker/build container->host
	docker build -f ./Docker/Dockerfile.c2h -t $(NAME_C2H) .

run-c2h: ## docker/run container->host
	docker run -it --rm \
		-v $(PWD):/work/ \
		-v ~/.config/pulse:/root/.config/pulse \
		-e PULSE_SERVER=docker.for.mac.localhost \
		$(NAME_C2H) \
		/bin/bash

init-c2h: ## docker/setup container->host
	@pulseaudio -D --exit-idle-time=-1 
	@pacmd load-module module-pipe-sink file=/dev/audio format=s16 rate=44100 channels=2
	@make play

beep: ## sound/echo beep
	@echo -e "\007"

play: ## docker/ring sound
	$(call container_to_host, aplay $(SOUNDFILE) -r 44100 -c 2)
beep-py: ## docker/ring beep
	$(call container_to_host, python -c "print('\007')")

host-c2h: ## host/init sound
	@pulseaudio -D --exit-idle-time=-1
	@pulseaudio --check -v

# ========================================
# # sound: host->container->host
# make build
# make run
# (contianer) make init
# ---
# (mac) make host
# ========================================

build: ## docker/build host->container
	docker build -f ./Docker/Dockerfile.h2c -t $(NAME_H2C) .

run: ## docker/run host->container
	docker run -it --rm \
		-v $(PWD):/work/ \
		-p 127.0.0.1:3000:3000 \
		-v ~/.config/pulse:/root/.config/pulse \
		-e PULSE_SERVER=docker.for.mac.localhost \
		$(NAME_H2C) \
		/bin/bash

init: ## docker/run host->container
	@pulseaudio -D --exit-idle-time=-1 --system
	@pacmd load-module module-pipe-source file=/dev/audio format=s16 rate=44100 channels=2
	@socat tcp-listen:3000 file:/dev/audio &
	@get-record

get-record:
	@python3 scripts/echo.py

host: ## host/init record
	@pulseaudio -D --exit-idle-time=-1
	@rec --encoding signed-integer -traw --bits 16 --channels 2 --rate 44100 - | nc 127.0.0.1 3000 > /dev/null