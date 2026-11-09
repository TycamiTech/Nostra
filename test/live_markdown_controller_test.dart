import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nostra/core/services/app_settings_service.dart';
import 'package:nostra/features/notes/presentation/live_markdown_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('LiveMarkdownEditingController Tests', () {
    late Directory tempDir;
    late Box box;

    setUpAll(() async {
      tempDir = Directory.systemTemp.createTempSync('live_md_test_');
      Hive.init(tempDir.path);
      box = await Hive.openBox(AppSettingsService.boxName);
      await AppSettingsService.instance.init(overrideBox: box);
    });

    tearDownAll(() async {
      await box.close();
      await Hive.close();
      try {
        tempDir.deleteSync(recursive: true);
      } catch (_) {}
    });

    testWidgets('Preserves total character count matching text.length in spans', (tester) async {
      final controller = LiveMarkdownEditingController(
        text: '# Judul Utama\nIni teks **teks tebal** dan *miring* biasa.',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final span = controller.buildTextSpan(context: context, withComposing: false);
                // Recursively gather all text
                String allText = '';
                void collect(InlineSpan s) {
                  if (s is TextSpan) {
                    if (s.text != null) allText += s.text!;
                    if (s.children != null) {
                      for (final child in s.children!) {
                        collect(child);
                      }
                    }
                  }
                }

                collect(span);
                expect(allText, controller.text);
                return const SizedBox();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('Normal mode conceals markdown symbols with transparent hidden style', (tester) async {
      await tester.runAsync(() async {
        await AppSettingsService.instance.setAppMode(AppMode.normal);
      });
      final controller = LiveMarkdownEditingController(
        text: '**Kata Tebal**',
      );

      TextSpan? span;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                span = controller.buildTextSpan(context: context, withComposing: false);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(span, isNotNull);
      final children = span!.children!;
      expect(children.length, 3); // '**', 'Kata Tebal', '**'

      final firstMarker = children[0] as TextSpan;
      final innerText = children[1] as TextSpan;
      final secondMarker = children[2] as TextSpan;

      expect(firstMarker.text, '**');
      expect(firstMarker.style?.color, Colors.transparent);
      expect(firstMarker.style?.fontSize, 0.001);

      expect(innerText.text, 'Kata Tebal');
      expect(innerText.style?.fontWeight, FontWeight.bold);

      expect(secondMarker.text, '**');
      expect(secondMarker.style?.color, Colors.transparent);
    });

    testWidgets('Expert mode keeps markdown symbols visible with syntax styling', (tester) async {
      await tester.runAsync(() async {
        await AppSettingsService.instance.setAppMode(AppMode.expert);
      });
      final controller = LiveMarkdownEditingController(
        text: '**Kata Tebal**',
      );

      TextSpan? span;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                span = controller.buildTextSpan(context: context, withComposing: false);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(span, isNotNull);
      final children = span!.children!;
      expect(children.length, 3);

      final firstMarker = children[0] as TextSpan;
      final innerText = children[1] as TextSpan;

      expect(firstMarker.text, '**');
      expect(firstMarker.style?.color, isNot(Colors.transparent));

      expect(innerText.text, 'Kata Tebal');
      expect(innerText.style?.fontWeight, FontWeight.bold);
    });
  });
}

