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
b: ## docker/build & run
	docker build -f ./Docker/Dockerfile \
		-t $(NAME_CONTAINER) .
r:
	docker run -it --rm \
		-v $(PWD):/work/ \
		-v ~/.config/pulse:/root/.config/pulse \
		$(NAME_CONTAINER)

server: ## docker/setup server
	@pulseaudio -D --exit-idle-time=-1 
	@pacmd load-module module-pipe-sink file=/dev/audio format=s16 rate=44100 channels=2
	@make aplay

host: ## host/setting host
	brew install pulseaudio
	pulseaudio --load=module-native-protocol-tcp --exit-idle-time=-1 --daemon
	pulseaudio --check -v

play: ## sound/ring sound, framerate(44.1kHz), channels(2)
	aplay $(SOUNDFILE) -r 44100 -c 2

beep: ## sound/ring beep
	echo -ne '\007'

# ========================================
# pulseaudio
# ========================================

p:
	pulseaudio --start
	pulseaudio --check -v
	ps | grep pulse	

pc:
	ls ~/.config/pulse

reset:
	rm ~/.config/pulse/*