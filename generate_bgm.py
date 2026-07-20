import wave
import math
import struct
import os

os.makedirs('assets/audio', exist_ok=True)
SAMPLE_RATE = 22050

def generate_bgm(filename):
    # Let's create a cheerful Casio bossa/arcade loop at 125 BPM
    # 4 bars in C Major / F Major / G Major / C Major
    # Each bar has 8 sixteenth notes (0.12s each)
    notes = [
        # Bar 1: C Major (C4, E4, G4, C5)
        261.63, 329.63, 392.00, 523.25, 392.00, 329.63, 261.63, 392.00,
        # Bar 2: F Major (F4, A4, C5, F5)
        349.23, 440.00, 523.25, 698.46, 523.25, 440.00, 349.23, 440.00,
        # Bar 3: G Major (G4, B4, D5, G5)
        392.00, 493.88, 587.33, 783.99, 587.33, 493.88, 392.00, 493.88,
        # Bar 4: C Major resolving
        261.63, 392.00, 523.25, 659.25, 523.25, 392.00, 329.63, 261.63,
    ]
    
    bass_notes = [
        130.81, 130.81, 130.81, 130.81, 130.81, 130.81, 130.81, 130.81,
        174.61, 174.61, 174.61, 174.61, 174.61, 174.61, 174.61, 174.61,
        196.00, 196.00, 196.00, 196.00, 196.00, 196.00, 196.00, 196.00,
        130.81, 130.81, 130.81, 130.81, 130.81, 130.81, 130.81, 130.81,
    ]

    note_dur = 0.12
    samples_per_note = int(SAMPLE_RATE * note_dur)
    
    samples = []
    for idx, f in enumerate(notes):
        bf = bass_notes[idx]
        for i in range(samples_per_note):
            t = i / SAMPLE_RATE
            env = 1.0 - 0.5 * (i / samples_per_note)
            # Synth lead (square/pulse Casio tone)
            lead = 0.22 if math.sin(2 * math.pi * f * t) > 0 else -0.22
            # Casio bass (triangle/sine)
            bass = 0.25 * math.sin(2 * math.pi * bf * t)
            samples.append((lead + bass) * env)

    with wave.open(filename, 'w') as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(SAMPLE_RATE)
        for s in samples:
            s = max(-1.0, min(1.0, s))
            val = int(s * 32767.0)
            wav_file.writeframes(struct.pack('<h', val))

generate_bgm('assets/audio/bgm.wav')
print("assets/audio/bgm.wav generated successfully!")
