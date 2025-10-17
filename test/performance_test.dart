import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown/src/markdown.dart';
import 'package:markdown/src/markdown_viewport.dart';

void main() {
  testWidgets('Performance test with large markdown content', (WidgetTester tester) async {
    // Create a large markdown string for testing
    final largeMarkdown = _generateLargeMarkdownString();
    
    // Test the regular Markdown widget with shrinkWrap to prevent overflow
    final stopwatch = Stopwatch()..start();
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Markdown(data: largeMarkdown, shrinkWrap: true),
        ),
      ),
    );
    
    stopwatch.stop();
    print('Time to render large markdown: ${stopwatch.elapsedMilliseconds}ms');
    
    // Verify that the widget builds without errors
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    
    // Test the performance of the viewport widget with the same content
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MarkdownViewport(data: largeMarkdown),
        ),
      ),
    );
    
    expect(find.byType(ListView), findsOneWidget);
  });
}

String _generateLargeMarkdownString() {
  final buffer = StringBuffer();
  
  // Add headers
  buffer.writeln('# Large Document Header');
  buffer.writeln('This is a large document with many elements to test performance.');
  buffer.writeln();
  
  for (int i = 0; i < 100; i++) {
    buffer.writeln('## Section $i');
    buffer.writeln('This is section $i with some content.');
    buffer.writeln();
    
    // Add some lists
    buffer.writeln('* Item ${i * 3 + 1}');
    buffer.writeln('* Item ${i * 3 + 2}');
    buffer.writeln('* Item ${i * 3 + 3}');
    buffer.writeln();
    
    // Add some bold and italic text
    buffer.writeln('This text has **bold** and *italic* formatting.');
    buffer.writeln();
    
    // Add some links occasionally
    if (i % 10 == 0) {
      buffer.writeln('[Link to example $i](https://example.com/$i)');
      buffer.writeln();
    }
  }
  
  // Add a table
  buffer.writeln('| Header 1 | Header 2 | Header 3 |');
  buffer.writeln('|----------|----------|----------|');
  for (int i = 0; i < 20; i++) {
    buffer.writeln('| Cell $i.1 | Cell $i.2 | Cell $i.3 |');
  }
  buffer.writeln();
  
  return buffer.toString();
}