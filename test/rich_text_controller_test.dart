import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirello_utbk/features/notes/presentation/rich_text_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GoogleKeepRichTextController Tests', () {
    test('fromMarkdown parses formatting without markdown tags in text', () {
      const markdown = '# Judul Catatan\n'
          'Teks ini **tebal** dan *miring* serta <u>bergaris</u>.\n'
          'Ada juga kata ~~coret~~ dan ==stabilo==!\n'
          '## Sub Judul\n'
          '- [ ] Tugas pertama\n'
          '- [x] Tugas selesai\n'
          '- Poin catatan';

      final controller = GoogleKeepRichTextController.fromMarkdown(markdown);

      // Verify no markdown symbols exist in plain text
      expect(controller.text, isNot(contains('**')));
      expect(controller.text, isNot(contains('<u>')));
      expect(controller.text, isNot(contains('~~')));
      expect(controller.text, isNot(contains('==')));
      expect(controller.text, isNot(contains('# ')));
      expect(controller.text, isNot(contains('## ')));
      expect(controller.text, isNot(contains('- [ ] ')));
      expect(controller.text, isNot(contains('- [x] ')));

      // Verify text contains clean words
      expect(controller.text, contains('Judul Catatan'));
      expect(controller.text, contains('tebal'));
      expect(controller.text, contains('miring'));
      expect(controller.text, contains('bergaris'));
      expect(controller.text, contains('coret'));
      expect(controller.text, contains('stabilo'));
      expect(controller.text, contains('☐ Tugas pertama'));
      expect(controller.text, contains('☑ Tugas selesai'));
      expect(controller.text, contains('• Poin catatan'));

      // Verify line styles
      expect(controller.lineStyles[0], equals(LineType.h1));
      expect(controller.lineStyles[1], equals(LineType.normal));
      expect(controller.lineStyles[3], equals(LineType.h2));

      // Verify character format for "tebal"
      final tebalIndex = controller.text.indexOf('tebal');
      for (int i = tebalIndex; i < tebalIndex + 'tebal'.length; i++) {
        expect(controller.charFormats[i].bold, isTrue);
        expect(controller.charFormats[i].italic, isFalse);
      }

      // Verify character format for "miring"
      final miringIndex = controller.text.indexOf('miring');
      for (int i = miringIndex; i < miringIndex + 'miring'.length; i++) {
        expect(controller.charFormats[i].italic, isTrue);
      }

      // Verify character format for "bergaris"
      final bergarisIndex = controller.text.indexOf('bergaris');
      for (int i = bergarisIndex; i < bergarisIndex + 'bergaris'.length; i++) {
        expect(controller.charFormats[i].underline, isTrue);
      }

      // Verify character format for "coret"
      final coretIndex = controller.text.indexOf('coret');
      for (int i = coretIndex; i < coretIndex + 'coret'.length; i++) {
        expect(controller.charFormats[i].strikethrough, isTrue);
      }

      // Verify character format for "stabilo"
      final stabiloIndex = controller.text.indexOf('stabilo');
      for (int i = stabiloIndex; i < stabiloIndex + 'stabilo'.length; i++) {
        expect(controller.charFormats[i].highlight, isTrue);
      }
    });

    test('toMarkdown serializes clean markdown faithfully', () {
      const originalMarkdown = '# Judul Catatan\n'
          'Teks **tebal** dan *miring* serta <u>garis</u>.\n'
          '## Sub Judul\n'
          '- [ ] Tugas 1\n'
          '- [x] Tugas 2\n'
          '- Poin penting';

      final controller = GoogleKeepRichTextController.fromMarkdown(originalMarkdown);
      final generatedMarkdown = controller.toMarkdown();

      expect(generatedMarkdown, contains('# Judul Catatan'));
      expect(generatedMarkdown, contains('**tebal**'));
      expect(generatedMarkdown, contains('*miring*'));
      expect(generatedMarkdown, contains('<u>garis</u>'));
      expect(generatedMarkdown, contains('## Sub Judul'));
      expect(generatedMarkdown, contains('- [ ] Tugas 1'));
      expect(generatedMarkdown, contains('- [x] Tugas 2'));
      expect(generatedMarkdown, contains('- Poin penting'));
    });

    test('Sticky typing: Typing characters while Bold is active creates bold characters', () {
      final controller = GoogleKeepRichTextController(text: 'Halo ');
      controller.selection = const TextSelection.collapsed(offset: 5);

      // User taps B to activate bold typing
      controller.toggleBold();
      expect(controller.isBoldActive, isTrue);

      // User types "Kocak"
      controller.value = const TextEditingValue(
        text: 'Halo Kocak',
        selection: TextSelection.collapsed(offset: 10),
      );

      // Verify "Kocak" characters are bold
      for (int i = 5; i < 10; i++) {
        expect(controller.charFormats[i].bold, isTrue);
      }

      // User taps B to deactivate bold typing
      controller.toggleBold();
      expect(controller.isBoldActive, isFalse);

      // User types " biasa"
      controller.value = const TextEditingValue(
        text: 'Halo Kocak biasa',
        selection: TextSelection.collapsed(offset: 16),
      );

      // Verify " biasa" characters are not bold
      for (int i = 10; i < 16; i++) {
        expect(controller.charFormats[i].bold, isFalse);
      }

      // Verify serialization to markdown
      final md = controller.toMarkdown();
      expect(md, equals('Halo **Kocak** biasa'));
    });

    test('Selection formatting: Toggling bold on selected text toggles only selection', () {
      final controller = GoogleKeepRichTextController(text: 'Halo dunia');
      controller.selection = const TextSelection(baseOffset: 5, extentOffset: 10);

      // Format "dunia" as bold
      controller.toggleBold();
      for (int i = 5; i < 10; i++) {
        expect(controller.charFormats[i].bold, isTrue);
      }
      for (int i = 0; i < 5; i++) {
        expect(controller.charFormats[i].bold, isFalse);
      }

      // Toggle off
      controller.toggleBold();
      for (int i = 5; i < 10; i++) {
        expect(controller.charFormats[i].bold, isFalse);
      }
    });

    test('Headings H1 and H2 toggle line style without inserting markdown hash', () {
      final controller = GoogleKeepRichTextController(text: 'Judul Saya\nBaris kedua');
      controller.selection = const TextSelection.collapsed(offset: 3); // on first line

      // Toggle H1
      controller.toggleH1();
      expect(controller.isH1Active, isTrue);
      expect(controller.text, equals('Judul Saya\nBaris kedua')); // No '#' in text!
      expect(controller.toMarkdown(), startsWith('# Judul Saya\n'));

      // Toggle H2
      controller.toggleH2();
      expect(controller.isH2Active, isTrue);
      expect(controller.isH1Active, isFalse);
      expect(controller.toMarkdown(), startsWith('## Judul Saya\n'));

      // Toggle off
      controller.toggleH2();
      expect(controller.isH2Active, isFalse);
      expect(controller.toMarkdown(), startsWith('Judul Saya\n'));
    });

    test('Bullet list and Checklist toggle cleanly', () {
      final controller = GoogleKeepRichTextController(text: 'Belanja');
      controller.selection = const TextSelection.collapsed(offset: 3);

      // Toggle Bullet
      controller.toggleBulletList();
      expect(controller.text, equals('• Belanja'));
      expect(controller.toMarkdown(), equals('- Belanja'));

      // Toggle Checklist
      controller.toggleChecklist();
      expect(controller.text, equals('☐ Belanja'));
      expect(controller.toMarkdown(), equals('- [ ] Belanja'));

      // Toggle Checklist to Checked
      controller.toggleChecklist();
      expect(controller.text, equals('☑ Belanja'));
      expect(controller.toMarkdown(), equals('- [x] Belanja'));

      // Toggle Checklist off
      controller.toggleChecklist();
      expect(controller.text, equals('Belanja'));
      expect(controller.toMarkdown(), equals('Belanja'));
    });

    testWidgets('buildTextSpan produces matching characters without layout errors', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final controller = GoogleKeepRichTextController.fromMarkdown(
                  '# Catatan Harian\n'
                  'Teks **tebal** dan *miring* serta <u>garis</u>.\n'
                  '☐ Item satu\n'
                  '☑ Item selesai',
                );

                final span = controller.buildTextSpan(
                  context: context,
                  withComposing: false,
                );

                // Reconstruct full text from span
                final spanText = span.toPlainText();
                expect(spanText, equals(controller.text));
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
    });
    test('buildRichPreviewSpan renders combined strikethrough, bold and highlight without syntax markers', () {
      const input = '~~**APA YANG AKAN TERJADI JIKA MANUSIA MATI SEMUA**~~\n==GGG==';
      final span = GoogleKeepRichTextController.buildRichPreviewSpan(input);

      final plain = span.toPlainText();
      expect(plain, isNot(contains('~~')));
      expect(plain, isNot(contains('**')));
      expect(plain, isNot(contains('==')));
      expect(plain, contains('APA YANG AKAN TERJADI JIKA MANUSIA MATI SEMUA'));
      expect(plain, contains('GGG'));
    });

    test('toggleCheckboxAtOffset toggles between unchecked and checked', () {
      final controller = GoogleKeepRichTextController.fromMarkdown('- [ ] Beli susu\n- [x] Beli kopi');
      expect(controller.text, equals('☐ Beli susu\n☑ Beli kopi'));

      // Tap on line 1 checkbox
      final toggled1 = controller.toggleCheckboxAtOffset(0);
      expect(toggled1, isTrue);
      expect(controller.text.startsWith('☑ Beli susu'), isTrue);

      // Tap on line 2 checkbox
      final line2Offset = controller.text.indexOf('☑ Beli kopi');
      final toggled2 = controller.toggleCheckboxAtOffset(line2Offset);
      expect(toggled2, isTrue);
      expect(controller.text.contains('☐ Beli kopi'), isTrue);
    });
  });
}

