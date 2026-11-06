import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Optional test captures are disposable build output, not repository assets.
Future<void> capturePreview(
  WidgetTester tester,
  GlobalKey boundaryKey,
  String name,
) async {
  final pictures = tester.widgetList<Image>(find.byType(Image)).toList();
  await tester.runAsync(() async {
    for (final picture in pictures) {
      await precacheImage(picture.image, boundaryKey.currentContext!);
    }
  });
  await tester.pump();
  await tester.runAsync(() async {
    final boundary =
        boundaryKey.currentContext!.findRenderObject()!
            as RenderRepaintBoundary;
    final image = await boundary.toImage();
    try {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File('build/previews/$name.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes!.buffer.asUint8List());
    } finally {
      image.dispose();
    }
  });
}
