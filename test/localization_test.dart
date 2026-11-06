import 'package:bicho_a_bicho/features/account/presentation/account_message.dart';
import 'package:bicho_a_bicho/features/account/presentation/account_message_text.dart';
import 'package:bicho_a_bicho/features/games/domain/game_definition.dart';
import 'package:bicho_a_bicho/features/games/presentation/game_catalog.dart';
import 'package:bicho_a_bicho/features/games/presentation/game_media_message.dart';
import 'package:bicho_a_bicho/features/games/presentation/game_media_message_text.dart';
import 'package:bicho_a_bicho/features/progress/domain/profile_catalog.dart';
import 'package:bicho_a_bicho/features/progress/presentation/profile_labels.dart';
import 'package:bicho_a_bicho/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/localization.dart';

void main() {
  test('Portuguese quantities distinguish zero, singular and plural', () {
    expect(testStrings.countingCorrect(1), 'Isso! Temos 1 bichinho.');
    expect(testStrings.countingCorrect(2), 'Isso! Temos 2 bichinhos.');
    expect(testStrings.memoryScore(0, 3, 0), '0 de 3 pares • 0 tentativas');
    expect(testStrings.memoryScore(1, 3, 1), '1 de 3 pares • 1 tentativa');
    expect(testStrings.memoryScore(2, 3, 4), '2 de 3 pares • 4 tentativas');
    expect(testStrings.choiceCount(2), '2 opções');
    expect(testStrings.sessionRoundCount(4), '4 descobertas');
  });

  test('profile display formatting leaves persisted values unchanged', () {
    const unnamed = LearnerProfile(0, 'cat', '');
    const named = LearnerProfile(1, 'cat', 'Lia');
    expect(unnamed.displayName(testStrings), 'Meu Gato');
    expect(unnamed.name, isEmpty);
    expect(named.displayName(testStrings), 'Lia');
    expect(named.displayCardNumber(testStrings), 'Cartão 2');
  });

  test('localized catalog covers every game and protects its collection', () {
    final catalog = gameCatalog(testStrings);
    expect(catalog.map((game) => game.kind).toSet(), GameKind.values.toSet());
    for (final game in catalog) {
      expect(game.title.trim(), isNotEmpty);
      expect(game.instruction.trim(), isNotEmpty);
      expect(game.skill.trim(), isNotEmpty);
    }
    expect(() => catalog.clear(), throwsUnsupportedError);
  });

  testWidgets('typed account and media states resolve using UI localization', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: Column(
              children: [
                Text(AccountMessage.connection.resolve(context)),
                Text(GameMediaMessage.soundDisabled.resolve(context)),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(testStrings.accountConnection), findsOneWidget);
    expect(find.text(testStrings.soundDisabled), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
