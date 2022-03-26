import wave, struct, math, random

# sampleRate = 44100.0
# duration =1.0
# frequency = 440.0
#
# obj = wave.open('test.wav', 'w')
# obj.setnchannels(1)
# obj.setsampwidth(2)
# obj.setframerate(sampleRate)
# for i in range(99999):
#     value = random.randint(-32767, 32767)
#     data = struct.pack('<h', value)
#     obj.writeframesraw(data)
# obj.close()

cb = wave.open('/home/mikowitz/Code/music/surfex/priv/samples/7dot1.wav')
# cb = wave.open('/home/mikowitz/Downloads/7dot1.wav')

print(cb.getnchannels())
print(cb.getsampwidth())
print(cb.getframerate())
print(cb.getnframes())
print(cb.getcomptype())
print(cb.getcompname())
print(cb.getparams())
