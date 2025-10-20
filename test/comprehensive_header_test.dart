import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown/markdown.dart';

void main() {
  group('Advanced header formatting tests', () {
    testWidgets('Test headers with complex formatting', (WidgetTester tester) async {
      const markdownText = '''
# Header with **bold** and *italic* text
## Header with ***bold and italic*** text
### Header with [link](http://example.com) and **bold**
#### Header with escaped characters \\* \\_ \\[ \\] \\( \\)
##### Header with `code` and **bold**
###### Mixed **bold** and *italic* with [link](http://example.com)
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

    testWidgets('Test headers with just text (no formatting)', (WidgetTester tester) async {
      const markdownText = '''
# Simple Header
## Another Header
### Third Header
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

    testWidgets('Test mixed content with headers and paragraphs', (WidgetTester tester) async {
      const markdownText = '''
# Header with **bold**

This is a paragraph with *italic* text.

## Header with *italic*

This paragraph has **bold** text.

### Simple Header

Plain text paragraph.
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
  });
}