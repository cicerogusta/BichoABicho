"""Prepare the four licensed recordings; see docs/ANIMAL_ASSETS.md.

Requires numpy and soundfile. Originals live in build/animal_audio_sources.
"""
from pathlib import Path

import numpy as np
import soundfile as sf

ROOT = Path(__file__).resolve().parents[1]
SAMPLE_RATE = 22050

for animal, extension in [('cow', 'ogg'), ('horse', 'ogg'),
                          ('sheep', 'ogg'), ('duck', 'wav')]:
    source = ROOT / 'build' / 'animal_audio_sources' / f'{animal}.{extension}'
    samples, rate = sf.read(source, always_2d=True)
    mono = samples.mean(axis=1)
    # Preserve timing, remove DC offset, cap gain and avoid abrupt edges.
    mono -= mono.mean()
    mono = np.interp(
        np.arange(round(len(mono) * SAMPLE_RATE / rate)) / SAMPLE_RATE,
        np.arange(len(mono)) / rate,
        mono,
    )
    peak = np.max(np.abs(mono))
    if not np.isfinite(peak) or peak == 0:
        raise ValueError(f'Invalid recording: {animal}')
    mono *= min(8.0, 0.65 / peak)
    fade = min(round(SAMPLE_RATE * 0.012), len(mono) // 2)
    mono[:fade] *= np.linspace(0, 1, fade)
    mono[-fade:] *= np.linspace(1, 0, fade)
    mono = np.pad(mono, round(SAMPLE_RATE * 0.08))
    target = ROOT / 'assets' / f'{animal}.wav'
    sf.write(target, mono, SAMPLE_RATE, subtype='PCM_16')
    print(f'{animal}: {len(mono) / SAMPLE_RATE:.2f}s, peak {max(abs(mono)):.3f}')
