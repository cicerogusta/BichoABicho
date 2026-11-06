import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('domain remains independent of Flutter, data and presentation layers', () {
    final files = Directory('lib/features')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.replaceAll('\\', '/').contains('/domain/'))
        .where((file) => file.path.endsWith('.dart'));
    final forbidden = RegExp(
      r'''^import\s+['"][^'"]*(?:package:flutter|/presentation/|/data/|firebase_|shared_preferences|audioplayers|speech_to_text)[^'"]*['"]''',
      multiLine: true,
    );
    for (final file in files) {
      expect(
        forbidden.hasMatch(file.readAsStringSync()),
        isFalse,
        reason: file.path,
      );
    }
  });

  test('feature widgets do not select platform adapter implementations', () {
    final forbidden = RegExp(
      r'''^import\s+['"][^'"]*(?:asset_animal_audio|device_animal_speech|firebase_account_repository|package:firebase_|package:audioplayers|package:speech_to_text|package:shared_preferences)[^'"]*['"]''',
      multiLine: true,
    );
    for (final file in Directory(
      'lib/features',
    ).listSync(recursive: true).whereType<File>()) {
      if (!file.path.replaceAll('\\', '/').contains('/presentation/') ||
          !file.path.endsWith('.dart')) {
        continue;
      }
      expect(
        forbidden.hasMatch(file.readAsStringSync()),
        isFalse,
        reason: file.path,
      );
    }
  });
}
