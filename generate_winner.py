import wave
import math
import struct
import os

os.makedirs('assets/audio', exist_ok=True)
SAMPLE_RATE = 44100

def synth_note(freq, duration, wave_type='square'):
    n_samples = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(n_samples):
        t = i / SAMPLE_RATE
        env = 1.0 - 0.7 * (i / n_samples)
        if wave_type == 'square':
            s = 0.35 if math.sin(2 * math.pi * freq * t) > 0 else -0.35
        elif wave_type == 'saw':
            s = 0.35 * (2 * (t * freq - math.floor(0.5 + t * freq)))
        elif wave_type == 'chime':
            s1 = 0.25 * math.sin(2 * math.pi * freq * t)
            s2 = 0.15 * math.sin(2 * math.pi * (freq * 2.01) * t)
            s = s1 + s2
        else:
            s = 0.35 * math.sin(2 * math.pi * freq * t)
        samples.append(s * env)
    return samples

# Create a special celebratory winner fanfare sequence
# Trumpet-like flourish + sparkling coin chimes
melody = [
    (523.25, 0.12, 'square'), # C5
    (659.25, 0.12, 'square'), # E5
    (783.99, 0.12, 'square'), # G5
    (1046.50, 0.25, 'square'), # C6
    (880.00, 0.12, 'square'),  # A5
    (1046.50, 0.40, 'square'), # C6 held
    # Sparkling chimes
    (1318.51, 0.08, 'chime'), # E6
    (1567.98, 0.08, 'chime'), # G6
    (2093.00, 0.25, 'chime'), # C7
]

samples = []
for freq, dur, w in melody:
    samples.extend(synth_note(freq, dur, w))

with wave.open('assets/audio/winner_special.wav', 'w') as wav_file:
    wav_file.setnchannels(1)
    wav_file.setsampwidth(2)
    wav_file.setframerate(SAMPLE_RATE)
    for s in samples:
        s = max(-1.0, min(1.0, s))
        val = int(s * 32767.0)
        wav_file.writeframes(struct.pack('<h', val))

print("assets/audio/winner_special.wav generated successfully!")
