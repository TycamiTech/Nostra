import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mirello_utbk/features/onboarding/presentation/onboarding_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    tempDir = await Directory.systemTemp.createTemp('nostra_onboarding_test_');
    Hive.init(tempDir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('OnboardingScreen Tests', () {
    testWidgets('Renders exact vertical layout without forbidden text',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OnboardingScreen(),
        ),
      );
      await tester.pump();

      // Brand Title "Nostra" must exist
      expect(find.text('Nostra'), findsOneWidget);

      // Developer credit "Project By TycamiTech" must exist
      expect(find.text('Project By TycamiTech'), findsOneWidget);

      // Primary CTA "Mulai Sekarang" must exist
      expect(find.text('Mulai Sekarang'), findsOneWidget);

      // STRICT NEGATIVE CONSTRAINTS: Must NOT contain unrequested marketing text or login links
      expect(find.textContaining('Tenang, rapi & estetis'), findsNothing);
      expect(find.textContaining('Sudah punya akun'), findsNothing);
      expect(find.textContaining('Masuk'), findsNothing);

      // CustomPainters must be present
      expect(find.byType(CustomPaint), findsWidgets);
    });

    test('Hive persistence: has_seen_onboarding defaults to false and persists true',
        () async {
      final box = await Hive.openBox('app_settings');
      expect(box.get('has_seen_onboarding', defaultValue: false), isFalse);

      await box.put('has_seen_onboarding', true);
      expect(box.get('has_seen_onboarding', defaultValue: false), isTrue);
    });
  });
}
