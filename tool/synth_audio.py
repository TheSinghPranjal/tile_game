"""Synthesizes the game's original music loop and sound effects.

Run from the project root:  python3 tool/synth_audio.py
Writes WAV files to assets/audio/ (the music is then converted to AAC with
macOS `afconvert` to keep the bundle small). Everything is generated from
scratch, so there are no licensing concerns.
"""
import os
import subprocess
import wave

import numpy as np

SR = 44100
OUT = os.path.join("assets", "audio")


def note(n):
    """MIDI note number -> Hz."""
    return 440.0 * 2 ** ((n - 69) / 12)


def env(length, attack=0.005, decay=0.3):
    t = np.arange(length) / SR
    a = np.clip(t / attack, 0, 1)
    return a * np.exp(-t / decay)


def bell(freq, dur, decay=0.5, bright=0.35):
    """Soft music-box / marimba-like tone."""
    n = int(dur * SR)
    t = np.arange(n) / SR
    sig = (np.sin(2 * np.pi * freq * t)
           + bright * np.sin(2 * np.pi * freq * 2.0 * t) * np.exp(-t / (decay * 0.4))
           + 0.12 * np.sin(2 * np.pi * freq * 3.01 * t) * np.exp(-t / (decay * 0.2)))
    return sig * env(n, 0.004, decay)


def pad(freq, dur):
    n = int(dur * SR)
    t = np.arange(n) / SR
    sig = sum(np.sin(2 * np.pi * freq * d * t) for d in (1.0, 1.003, 0.997)) / 3
    sig += 0.25 * np.sin(2 * np.pi * freq * 2 * t)
    fade = np.minimum(1, np.minimum(t / 0.8, (dur - t) / 0.8))
    return sig * np.clip(fade, 0, 1)


def add(buf, sig, start):
    i = int(start * SR)
    end = min(len(buf), i + len(sig))
    buf[i:end] += sig[: end - i]


def write(name, sig, gain=0.8):
    sig = sig / (np.max(np.abs(sig)) + 1e-9) * gain
    data = (sig * 32767).astype(np.int16)
    path = os.path.join(OUT, name)
    with wave.open(path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(data.tobytes())
    return path


def music():
    """32-bar-ish gentle pentatonic loop at 96 bpm, seamless."""
    bpm = 96
    beat = 60 / bpm
    bars = 16
    total = bars * 4 * beat
    buf = np.zeros(int(total * SR) + SR * 3)
    rng = np.random.default_rng(7)

    # C major pentatonic, chord roots: C, A-, F, G (I vi IV V) x4.
    chords = [(48, [60, 64, 67]), (45, [57, 60, 64]), (41, [57, 60, 65]), (43, [55, 59, 62])]
    scale = [72, 74, 76, 79, 81, 84]
    for bar in range(bars):
        root, triad = chords[bar % 4]
        t0 = bar * 4 * beat
        add(buf, 0.10 * pad(note(root), 4 * beat + 0.6), t0)
        for k, n in enumerate(triad):
            add(buf, 0.05 * pad(note(n), 4 * beat + 0.6), t0)
        # Soft arpeggio on 8ths.
        for e in range(8):
            n = triad[[0, 1, 2, 1][e % 4]] + 12
            add(buf, 0.09 * bell(note(n), 1.2, decay=0.35, bright=0.2), t0 + e * beat / 2)
        # Melody: a few notes per bar, chosen from chord-friendly pentatonic tones.
        pos = 0.0
        while pos < 4:
            dur = rng.choice([1.0, 1.0, 0.5, 1.5, 2.0])
            if rng.random() < 0.8:
                n = rng.choice(scale)
                add(buf, 0.22 * bell(note(n), 2.0, decay=0.7), t0 + pos * beat)
            pos += dur

    # Make it loop: fold the reverb-like tail back onto the start.
    n = int(total * SR)
    tail = buf[n:]
    buf = buf[:n]
    buf[: len(tail)] += tail
    path = write("music_garden.wav", buf, gain=0.55)
    m4a = path.replace(".wav", ".m4a")
    subprocess.run(["afconvert", "-f", "m4af", "-d", "aac", "-b", "96000", path, m4a], check=True)
    os.remove(path)


def sfx():
    # Tap: short wooden tick.
    n = int(0.08 * SR)
    t = np.arange(n) / SR
    tap = np.sin(2 * np.pi * 1250 * t) * np.exp(-t / 0.012) + 0.4 * np.sin(2 * np.pi * 2500 * t) * np.exp(-t / 0.006)
    write("tap.wav", tap, 0.5)

    # Match: bright two-note chime (G5 -> C6) with sparkle.
    buf = np.zeros(int(0.7 * SR))
    add(buf, bell(note(79), 0.6, 0.25), 0)
    add(buf, bell(note(84), 0.6, 0.3), 0.07)
    add(buf, 0.3 * bell(note(96), 0.3, 0.12), 0.1)
    write("match.wav", buf, 0.7)

    # Mismatch: soft low double bump.
    buf = np.zeros(int(0.35 * SR))
    for k, f in enumerate((220, 196)):
        n = int(0.15 * SR)
        t = np.arange(n) / SR
        add(buf, np.sin(2 * np.pi * f * t) * env(n, 0.004, 0.05), k * 0.11)
    write("mismatch.wav", buf, 0.55)

    # Shuffle: filtered noise whoosh.
    n = int(0.5 * SR)
    t = np.arange(n) / SR
    noise = np.random.default_rng(3).standard_normal(n)
    kernel = np.ones(30) / 30
    smooth = np.convolve(noise, kernel, mode="same")
    shape = np.sin(np.pi * t / t[-1]) ** 2
    write("shuffle.wav", smooth * shape, 0.5)

    # Hint: rising sparkle.
    buf = np.zeros(int(0.6 * SR))
    for k, m in enumerate((84, 88, 91)):
        add(buf, bell(note(m), 0.4, 0.15, 0.1), k * 0.06)
    write("hint.wav", buf, 0.5)

    # Magic: shimmering glissando.
    buf = np.zeros(int(0.8 * SR))
    for k, m in enumerate((72, 76, 79, 84, 88, 91, 96)):
        add(buf, bell(note(m), 0.4, 0.15, 0.1), k * 0.045)
    write("magic.wav", buf, 0.55)

    # Win: happy arpeggio + chord.
    buf = np.zeros(int(1.8 * SR))
    for k, m in enumerate((72, 76, 79, 84)):
        add(buf, bell(note(m), 1.0, 0.4), k * 0.11)
    for m in (72, 76, 79, 84):
        add(buf, 0.6 * bell(note(m), 1.4, 0.8), 0.5)
    write("win.wav", buf, 0.75)

    # UI button: soft pop.
    n = int(0.06 * SR)
    t = np.arange(n) / SR
    pop = np.sin(2 * np.pi * (600 + 900 * t / t[-1]) * t) * env(n, 0.002, 0.015)
    write("button.wav", pop, 0.45)


if __name__ == "__main__":
    os.makedirs(OUT, exist_ok=True)
    music()
    sfx()
    print("ok")
