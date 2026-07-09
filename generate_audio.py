import wave
import math
import struct
import os

os.makedirs('assets/audio', exist_ok=True)

SAMPLE_RATE = 44100

def generate_wave(filename, samples):
    with wave.open(filename, 'w') as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(SAMPLE_RATE)
        for s in samples:
            s = max(-1.0, min(1.0, s))
            val = int(s * 32767.0)
            wav_file.writeframes(struct.pack('<h', val))

def synth_note(freq, duration, wave_type='square', decay=True):
    n_samples = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(n_samples):
        t = i / SAMPLE_RATE
        env = (1.0 - (i / n_samples)) if decay else 1.0
        if wave_type == 'square':
            s = 0.4 if math.sin(2 * math.pi * freq * t) > 0 else -0.4
        elif wave_type == 'sine':
            s = 0.5 * math.sin(2 * math.pi * freq * t)
        elif wave_type == 'saw':
            s = 0.4 * (2 * (t * freq - math.floor(0.5 + t * freq)))
        else:
            s = 0.4 * math.sin(2 * math.pi * freq * t)
        samples.append(s * env)
    return samples

# 1. button_press.wav - crisp Casio blip
samples_button = synth_note(880, 0.05, 'square') + synth_note(1320, 0.08, 'square')
generate_wave('assets/audio/button_press.wav', samples_button)

# 2. spin_start.wav - rising Casio arpeggio
freqs_spin = [261.63, 329.63, 392.00, 523.25, 659.25, 783.99]
samples_spin = []
for f in freqs_spin:
    samples_spin.extend(synth_note(f, 0.06, 'square'))
generate_wave('assets/audio/spin_start.wav', samples_spin)

# 3. reel_stop.wav - mechanical Casio click/thud
samples_stop = []
for i in range(int(SAMPLE_RATE * 0.05)):
    t = i / SAMPLE_RATE
    env = 1.0 - (i / (SAMPLE_RATE * 0.05))
    s = 0.6 * math.sin(2 * math.pi * 110 * t) + 0.3 * math.sin(2 * math.pi * 55 * t)
    samples_stop.append(s * env)
generate_wave('assets/audio/reel_stop.wav', samples_stop)

# 4. coin_burst.wav - sparkling chime
freqs_coin = [987.77, 1318.51, 1567.98, 1975.53]
samples_coin = []
for f in freqs_coin:
    samples_coin.extend(synth_note(f, 0.05, 'sine'))
generate_wave('assets/audio/coin_burst.wav', samples_coin)

# 5. win_small.wav - cheerful 3-note melody
freqs_small = [523.25, 659.25, 783.99, 1046.50]
samples_small = []
for f in freqs_small:
    samples_small.extend(synth_note(f, 0.12, 'square'))
generate_wave('assets/audio/win_small.wav', samples_small)

# 6. win_big.wav - festive Casio fanfare
freqs_big = [523.25, 659.25, 783.99, 1046.50, 783.99, 1046.50, 1318.51]
samples_big = []
for f in freqs_big:
    samples_big.extend(synth_note(f, 0.14, 'square'))
generate_wave('assets/audio/win_big.wav', samples_big)

# 7. jackpot.wav - celebratory jackpot fanfare
freqs_jackpot = [523.25, 587.33, 659.25, 698.46, 783.99, 880.0, 987.77, 1046.50, 1318.51, 1567.98]
samples_jackpot = []
for f in freqs_jackpot:
    samples_jackpot.extend(synth_note(f, 0.12, 'square'))
generate_wave('assets/audio/jackpot.wav', samples_jackpot)

# 8. level_up.wav - upbeat flourish
freqs_level = [440.0, 554.37, 659.25, 880.0]
samples_level = []
for f in freqs_level:
    samples_level.extend(synth_note(f, 0.1, 'saw'))
generate_wave('assets/audio/level_up.wav', samples_level)

print("Audio files generated successfully in assets/audio/")
