import 'package:flutter_test/flutter_test.dart';
import 'package:nostra/features/reader/services/nostra_markdown_parser.dart';

void main() {
  group('NostraMarkdownParser tests', () {
    test('Pre-parse sanitizer strips AI grounding and citation tags', () {
      const input = 'Materi ini [span_1](start_span)sangat penting[cite: 1, 2] dan 【1:2†source】relevan.';
      final sanitized = NostraMarkdownParser.sanitizeText(input);
      expect(sanitized, 'Materi ini sangat penting dan relevan.');
    });

    test('Parser splits pages using --- delimiter', () {
      const doc = '''
[MODUL 01 | LBI-03]
# Halaman Pertama
Teks halaman 1
---
# Halaman Kedua
Teks halaman 2
''';
      final pages = NostraMarkdownParser.splitPages(doc);
      expect(pages.length, 2);
      expect(NostraMarkdownParser.extractPageTitle(pages[0]), 'Halaman Pertama');
      expect(NostraMarkdownParser.extractPageTitle(pages[1]), 'Halaman Kedua');
    });

    test('Parser identifies multi-level headings and block math', () {
      const page = '''
# Judul Bab
## Sub-Topik

Paragraf teks dengan ==highlight rapi== dan inline math \$E = mc^2\$.

\$\$
\\begin{bmatrix} a & b \\\\ c & d \\end{bmatrix}
\$\$
''';
      final elements = NostraMarkdownParser.parsePage(page);
      expect(elements.any((e) => e is HeadingElement && e.level == 1 && e.title == 'Judul Bab'), isTrue);
      expect(elements.any((e) => e is HeadingElement && e.level == 2 && e.title == 'Sub-Topik'), isTrue);
      expect(elements.any((e) => e is ParagraphElement), isTrue);
      expect(elements.any((e) => e is BlockMathElement), isTrue);
    });

    test('Parser correctly parses :::metode and :::soal blocks with steps', () {
      const page = '''
:::metode METODE ELIMINASI
1. Langkah satu
\$\$
x + y = 10
\$\$
2. Langkah dua
:::

:::soal HOT 2026
Berapa nilai x?
Pembahasan: Nilai x adalah 5.
:::
''';
      final elements = NostraMarkdownParser.parsePage(page);
      final method = elements.firstWhere((e) => e is MethodBlockElement) as MethodBlockElement;
      expect(method.title, 'METODE ELIMINASI');
      expect(method.steps.length, 3);
      expect(method.steps[0] is NumberedStepItem, isTrue);
      expect(method.steps[1] is MathStepItem, isTrue);
      expect(method.steps[2] is NumberedStepItem, isTrue);

      final soal = elements.firstWhere((e) => e is QuestionBlockElement) as QuestionBlockElement;
      expect(soal.badge, 'HOT 2026');
      expect(soal.contentSteps.isNotEmpty, isTrue);
      expect(soal.solutionSteps?.isNotEmpty, isTrue);
    });

    test('Parser flexibly handles tables, quotes, and callouts in any order', () {
      const page = '''
> Kutipan penting dari wacana editorial

| Header A | Header B |
| --- | --- |
| Data 1 | Data 2 |

:::tips TRIK CEPAT
- Periksa tanda hubung
> Jangan terkecoh pola kalimat
| Opsi | Status |
| --- | --- |
| A | Salah |
:::
''';
      final elements = NostraMarkdownParser.parsePage(page);
      expect(elements.any((e) => e is BlockquoteElement), isTrue);
      expect(elements.any((e) => e is TableElement), isTrue);
      final tipBlock = elements.firstWhere((e) => e is CalloutBlockElement) as CalloutBlockElement;
      expect(tipBlock.type, CalloutType.tip);
      expect(tipBlock.steps.any((s) => s is BulletStepItem), isTrue);
      expect(tipBlock.steps.any((s) => s is QuoteStepItem), isTrue);
      expect(tipBlock.steps.any((s) => s is TableStepItem), isTrue);
    });
  });
}
