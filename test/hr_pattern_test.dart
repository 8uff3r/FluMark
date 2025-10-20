import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown/markdown.dart';

void main() {
  test('Test horizontal rule patterns', () {
    // Test the regex patterns directly
    RegExp hrPattern = RegExp(r'^(\s*)(\*\*\*|\-{3,}|_{3,})(\s*)$');
    
    // Test different horizontal rule patterns
    expect(hrPattern.hasMatch('***'), isTrue);
    expect(hrPattern.hasMatch('---'), isTrue);
    expect(hrPattern.hasMatch('___'), isTrue);
    expect(hrPattern.hasMatch('   ***   '), isTrue);
    expect(hrPattern.hasMatch('------'), isTrue);
    expect(hrPattern.hasMatch('_____'), isTrue);
  });
  
  testWidgets('Test horizontal rules in markdown', (WidgetTester tester) async {
    const markdownText = '''
# Header 1

***

## Header 2

---

### Header 3

___
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
}