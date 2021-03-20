"""
どこかのGitHubで公開されていたけど探せなくなってしまった
"""

import numpy as np
import pyaudio
import pyworld as pw

sample_rate = 16000
input_buffer_size = 1024 * 8   # バッファサイズ（入力）
output_buffer_size = 1024 * 2  # バッファサイズ（出力）

f0_rate = 1.0#1.9  # 声の高さの調整 : 2倍にすれば1オクターブ上に、0.5倍にすれば1オクターブ下に
sp_rate = 1.0#0.75  # 声色の調整 (> 0.0) : 女性の声にする場合は1.0より小さく、男性はその逆で大きく

def analysis_resynthesis(signal):

	# 音響特徴量の抽出
	f0, t = pw.dio(signal, sample_rate)  # 基本周波数の抽出
	f0 = pw.stonemask(signal, f0, t, sample_rate)  # refinement
	sp = pw.cheaptrick(signal, f0, t, sample_rate)  # スペクトル包絡の抽出
	ap = pw.d4c(signal, f0, t, sample_rate)  # 非周期性指標の抽出

	print(f0)

	# ピッチシフト
	modified_f0 = f0_rate * f0

	# フォルマントシフト（周波数軸の一様な伸縮）
	modified_sp = np.zeros_like(sp)
	sp_range = int(modified_sp.shape[1] * sp_rate)
	for f in range(modified_sp.shape[1]):
		if (f < sp_range):
			if sp_rate >= 1.0:
				modified_sp[:, f] = sp[:, int(f / sp_rate)]
			else:
				modified_sp[:, f] = sp[:, int(sp_rate * f)]
		else:
			modified_sp[:, f] = sp[:, f]

	# 再合成
	synth = pw.synthesize(modified_f0, modified_sp, ap, sample_rate)

	return synth


if __name__ == "__main__":
	audio = pyaudio.PyAudio()
	print(audio.get_device_count())

	stream_in = audio.open(format=pyaudio.paInt16,
						channels=1,
						rate=sample_rate,
						frames_per_buffer=input_buffer_size,
						input=True)

	stream_out = audio.open(format=pyaudio.paInt16,
							channels=1,
							rate=sample_rate,
							frames_per_buffer=output_buffer_size,
							output=True)

	try:
		print("分析合成を開始します。話しかけてください。")
		while stream_in.is_active():
			input = stream_in.read(input_buffer_size,
								exception_on_overflow=False)
			signal = np.frombuffer(input, dtype='int16').astype(np.float64)
			output = analysis_resynthesis(signal)
			stream_out.write(output.astype(np.int16).tobytes())

	except KeyboardInterrupt:
		print("\nInterrupt.")

	finally:
		stream_in.stop_stream()
		stream_in.close()
		stream_out.stop_stream()
		stream_out.close()
		audio.terminate()
		print("Stop Streaming.")
