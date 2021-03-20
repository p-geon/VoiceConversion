export NAME_CONTAINER=hyperpigeon/vc_base
export PWD=`pwd`
export HOSTNAME=pigeon
# mp3は鳴らない(というかバグる)
export SOUNDFILE=./src/pc.wav
## host/host to container
include ./utils/Makefile
# ========================================
# sound: container -> host
# ========================================
br:
	make b
	make r
b: ## docker/build & run
	docker build -f ./Docker/Dockerfile \
		-t $(NAME_CONTAINER) .
r:
	docker run -it --rm \
		-e PULSE_SERVER=docker.for.mac.localhost \
		-v $(PWD):/work/ \
		-v ~/.config/pulse:/root/.config/pulse \
		-p 3000:3000 \
		$(NAME_CONTAINER)

run:
	docker run -it --rm \
		$(NAME_CONTAINER)

server: ## docker/setup server
	@pulseaudio -D --exit-idle-time=-1 
	@pacmd load-module module-pipe-sink file=/dev/audio format=s16 rate=44100 channels=2
	@make play


play: ## sound/ring sound, framerate(44.1kHz), channels(2)
	aplay $(SOUNDFILE) -r 44100 -c 2
paplay:
	paplay $(SOUNDFILE) -r 44100 -c 2

beep: ## sound/ring beep
	@echo -ne '\007'
	@echo -e "\007"

# ========================================
# pulseaudio
# ========================================
init: ## host/setting host
	brew install pulseaudio
	make check

purge:
	brew uninstall pulseaudio
	make check

daemon:
	pulseaudio --load=module-native-protocol-tcp --exit-idle-time=-1 --daemon
	make check

remove-cache:
	ls ~/.config/pulse
	rm ~/.config/pulse/*
	pulseaudio --cleanup-shm
	make check

start:
	pulseaudio --start
	make check

kill:
	pulseaudio --kill
	make check

check:
	pulseaudio --check -v