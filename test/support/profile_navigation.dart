import 'package:bicho_a_bicho/core/widgets/soft_card.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Existing game tests use unnamed cards; registration has dedicated coverage.
Future<void> chooseLearner(
  WidgetTester tester,
  String label, {
  bool finishSetup = true,
}) async {
  final card = find.descendant(
    of: find.byType(SoftCard),
    matching: find.text(label),
  );
  if (find.text(label).evaluate().isEmpty &&
      find
          .byKey(const ValueKey('report_profile_selector'))
          .evaluate()
          .isNotEmpty) {
    await tester.ensureVisible(
      find.byKey(const ValueKey('report_profile_selector')),
    );
    await tester.tap(find.byKey(const ValueKey('report_profile_selector')));
    await tester.pumpAndSettle();
  }
  if (card.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      card,
      120,
      scrollable: find.byType(Scrollable).first,
    );
  }
  await tester.ensureVisible(card);
  await tester.pumpAndSettle();
  await tester.tap(card);
  await tester.pumpAndSettle();
  if (finishSetup &&
      find.text('Como vamos chamar você?').evaluate().isNotEmpty) {
    await tester.ensureVisible(find.text('Continuar sem nome'));
    await tester.tap(find.text('Continuar sem nome'));
    await tester.pumpAndSettle();
  }
}
