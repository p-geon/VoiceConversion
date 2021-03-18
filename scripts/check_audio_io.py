# from: https://algorithm.joho.info/programming/python/pyaudio-device-index/
import pyaudio
import wave

def audio_input():
	print("[input]")

def audio_output():
	print("[output]")
	"""
	audio = pyaudio.PyAudio()
	for x in range(0, audio.get_device_count()):
		print(audio.get_device_info_by_index(x))
	"""
	print("\007") # Beep Sound

def main():
	audio_input()
	audio_output()

if __name__ == '__main__':
	main()