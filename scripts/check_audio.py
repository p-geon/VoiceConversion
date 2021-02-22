# from: https://algorithm.joho.info/programming/python/pyaudio-device-index/
import pyaudio
import wave 

def main():
    audio = pyaudio.PyAudio()
    for x in range(0, audio.get_device_count()): 
        print(audio.get_device_info_by_index(x))

if __name__ == '__main__':
    main()