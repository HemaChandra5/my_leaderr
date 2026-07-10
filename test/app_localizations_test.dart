import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_leaderr/core/localization/app_language.dart';
import 'package:my_leaderr/core/localization/app_localizations.dart';
import 'package:my_leaderr/features/home/presentation/pages/home_page.dart';

void main() {
  group('AppLocalizations', () {
    test('returns Telugu translation for a supported key', () {
      expect(
        AppLocalizations.translate('our_leader', language: 'Telugu'),
        'మా నాయకుడు.',
      );
    });

    test('falls back to English for unsupported languages', () {
      expect(
        AppLocalizations.translate('get_started', language: 'French'),
        'Get Started',
      );
    });

    testWidgets('home page updates labels when language changes', (tester) async {
      await AppLanguage.instance.setLanguage('Telugu');
      await tester.pumpWidget(const MaterialApp(home: HomePage()));
      await tester.pump();

      expect(find.text('హోమ్'), findsOneWidget);
      expect(find.text('సమస్యలు'), findsOneWidget);

      await AppLanguage.instance.setLanguage('English');
      await tester.pump();
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Issues'), findsOneWidget);
    });
  });
}
