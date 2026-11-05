// Original four-note major arpeggio, synthesized locally without external media.
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

void main() {
  const sampleRate = 44100;
  const seconds = 1.7;
  final samples = (sampleRate * seconds).round();
  final wav = ByteData(44 + samples * 2);
  void tag(int offset, String value) {
    for (var i = 0; i < value.length; i++) {
      wav.setUint8(offset + i, value.codeUnitAt(i));
    }
  }

  tag(0, 'RIFF');
  wav.setUint32(4, wav.lengthInBytes - 8, Endian.little);
  tag(8, 'WAVE');
  tag(12, 'fmt ');
  wav.setUint32(16, 16, Endian.little);
  wav.setUint16(20, 1, Endian.little);
  wav.setUint16(22, 1, Endian.little);
  wav.setUint32(24, sampleRate, Endian.little);
  wav.setUint32(28, sampleRate * 2, Endian.little);
  wav.setUint16(32, 2, Endian.little);
  wav.setUint16(34, 16, Endian.little);
  tag(36, 'data');
  wav.setUint32(40, samples * 2, Endian.little);
  const notes = [523.251, 659.255, 783.991, 1046.502];
  for (var sample = 0; sample < samples; sample++) {
    final time = sample / sampleRate;
    var value = 0.0;
    for (var note = 0; note < notes.length; note++) {
      final local = time - 0.025 - note * 0.22;
      if (local < 0) continue;
      final envelope =
          (1 - math.exp(-local / 0.012)) *
          math.exp(-local / (note == 3 ? 0.3 : 0.19));
      final phase = 2 * math.pi * notes[note] * local;
      value +=
          0.26 *
          envelope *
          (math.sin(phase) +
              0.18 * math.sin(phase * 2) +
              0.06 * math.sin(phase * 3));
    }
    final fadeOut = ((seconds - time) / 0.12).clamp(0.0, 1.0);
    wav.setInt16(
      44 + sample * 2,
      (value * fadeOut * 32767).round().clamp(-32767, 32767),
      Endian.little,
    );
  }
  File('assets/celebration.wav').writeAsBytesSync(wav.buffer.asUint8List());
}
