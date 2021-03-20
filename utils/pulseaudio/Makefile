
# ========================================
# pulseaudio
# ========================================
p-init: ## pulseaudio/install
	brew install pulseaudio
	make check

p-purge: ## pulseaudio/uninstall
	brew uninstall pulseaudio
	make check

p-daemon: ## pulseaudio/launch daemon
	pulseaudio --load=module-native-protocol-tcp --exit-idle-time=-1 --daemon
	make check

p-remove-cache: ## pulseaudio/remove cache
	ls ~/.config/pulse
	rm ~/.config/pulse/*
	pulseaudio --cleanup-shm
	make check

p-start: ## pulseaudio/start
	pulseaudio --start
	make check

p-kill: ## pulseaudio/kill
	pulseaudio --kill
	make check

p-check: ## pulseaudio/check state
	pulseaudio --check -v