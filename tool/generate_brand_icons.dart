// Run with: flutter test tool/generate_brand_icons.dart
// Uses Flutter's renderer to export the same Material paw mark used in the app.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:bicho_a_bicho/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Export platform brand icons', (tester) async {
    tester.view.physicalSize = const Size(1024, 1024);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final font = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await font.load();
    final outputs = <String, int>{
      'web/favicon.png': 32,
      'web/icons/Icon-192.png': 192,
      'web/icons/Icon-512.png': 512,
      'web/icons/Icon-maskable-192.png': 192,
      'web/icons/Icon-maskable-512.png': 512,
      'docs/previews/brand_icon.png': 512,
      for (final density in {
        'mdpi': 48,
        'hdpi': 72,
        'xhdpi': 96,
        'xxhdpi': 144,
        'xxxhdpi': 192,
      }.entries)
        'android/app/src/main/res/mipmap-${density.key}/ic_launcher.png':
            density.value,
    };
    for (final directory in [
      'ios/Runner/Assets.xcassets/AppIcon.appiconset',
      'macos/Runner/Assets.xcassets/AppIcon.appiconset',
    ]) {
      final text = await tester.runAsync(
        () => File('$directory/Contents.json').readAsString(),
      );
      final manifest = jsonDecode(text!) as Map<String, Object?>;
      for (final item in manifest['images']! as List<Object?>) {
        final entry = item! as Map<String, Object?>;
        final filename = entry['filename'] as String?;
        if (filename == null) continue;
        final side = double.parse((entry['size']! as String).split('x').first);
        final scale = double.parse(
          (entry['scale']! as String).replaceAll('x', ''),
        );
        outputs['$directory/$filename'] = (side * scale).round();
      }
    }
    final rendered = <int, Uint8List>{};
    for (final size in {...outputs.values, 16, 32, 48, 256}) {
      final key = GlobalKey();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: RepaintBoundary(
              key: key,
              child: SizedBox.square(
                dimension: size.toDouble(),
                child: ColoredBox(
                  color: AppColors.primary,
                  child: Center(
                    child: Icon(
                      Icons.pets_rounded,
                      color: Colors.white,
                      size: size * 0.58,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      rendered[size] = (await tester.runAsync(() async {
        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final picture = await boundary.toImage();
        final data = await picture.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        );
        picture.dispose();
        return _opaquePng(size, data!);
      }))!;
    }
    await tester.runAsync(() async {
      for (final output in outputs.entries) {
        final file = File(output.key);
        await file.parent.create(recursive: true);
        await file.writeAsBytes(rendered[output.value]!);
      }
      final windowsSizes = [16, 32, 48, 256];
      final header = ByteData(6 + windowsSizes.length * 16);
      header.setUint16(2, 1, Endian.little);
      header.setUint16(4, windowsSizes.length, Endian.little);
      var offset = header.lengthInBytes;
      for (var i = 0; i < windowsSizes.length; i++) {
        final size = windowsSizes[i];
        final entry = 6 + i * 16;
        header.setUint8(entry, size == 256 ? 0 : size);
        header.setUint8(entry + 1, size == 256 ? 0 : size);
        header.setUint16(entry + 4, 1, Endian.little);
        header.setUint16(entry + 6, 32, Endian.little);
        header.setUint32(entry + 8, rendered[size]!.length, Endian.little);
        header.setUint32(entry + 12, offset, Endian.little);
        offset += rendered[size]!.length;
      }
      final ico = BytesBuilder()..add(header.buffer.asUint8List());
      for (final size in windowsSizes) {
        ico.add(rendered[size]!);
      }
      await File(
        'windows/runner/resources/app_icon.ico',
      ).writeAsBytes(ico.takeBytes());
    });
  });
}

// Apple installation icons must have no alpha channel, even when fully opaque.
Uint8List _opaquePng(int size, ByteData rgba) {
  final scanlines = BytesBuilder(copy: false);
  for (var y = 0; y < size; y++) {
    final row = Uint8List(1 + size * 3);
    for (var x = 0; x < size; x++) {
      final pixel = (y * size + x) * 4;
      for (var channel = 0; channel < 3; channel++) {
        row[1 + x * 3 + channel] = rgba.getUint8(pixel + channel);
      }
    }
    scanlines.add(row);
  }
  final header = ByteData(13)
    ..setUint32(0, size)
    ..setUint32(4, size)
    ..setUint8(8, 8)
    ..setUint8(9, 2);
  final png = BytesBuilder()..add([137, 80, 78, 71, 13, 10, 26, 10]);
  void chunk(String type, List<int> data) {
    final body = [...type.codeUnits, ...data];
    var crc = 0xffffffff;
    for (final byte in body) {
      crc ^= byte;
      for (var bit = 0; bit < 8; bit++) {
        crc = (crc >>> 1) ^ ((crc & 1) == 1 ? 0xedb88320 : 0);
      }
    }
    final length = ByteData(4)..setUint32(0, data.length);
    final checksum = ByteData(4)..setUint32(0, crc ^ 0xffffffff);
    png
      ..add(length.buffer.asUint8List())
      ..add(body)
      ..add(checksum.buffer.asUint8List());
  }

  chunk('IHDR', header.buffer.asUint8List());
  chunk('IDAT', ZLibEncoder().convert(scanlines.takeBytes()));
  chunk('IEND', []);
  return png.takeBytes();
}
