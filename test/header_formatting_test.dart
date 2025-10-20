import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown/markdown.dart';

void main() {
  group('Header formatting tests', () {
    testWidgets('Headers should process bold and italic formatting', (WidgetTester tester) async {
      const markdownText = '''
# Header with **bold** text
## Header with *italic* text
### Header with ***bold and italic*** text
# Header with escaped \\* character
''';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Markdown(data: markdownText),
            ),
          ),
        ),
      );

      // Check that the widget builds without error
      expect(find.byType(Markdown), findsOneWidget);
    });

    testWidgets('Headers with mixed formatting should render', (WidgetTester tester) async {
      const markdownText = '# Header with [link](http://example.com) and **bold**';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Markdown(data: markdownText),
            ),
          ),
        ),
      );

      expect(find.byType(Markdown), findsOneWidget);
    });
  });
}