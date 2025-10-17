import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown/builder.dart';
import 'package:markdown/markdown.dart';
import 'package:markdown/style.dart';

void main() {
  testWidgets('Markdown widget renders simple text', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Markdown(data: 'Hello, world!'),
        ),
      ),
    );

    final richText = tester.widget<RichText>(find.byType(RichText));
    final textSpan = richText.text as TextSpan;
    expect(textSpan.toPlainText(), 'Hello, world!');
  });

  testWidgets('Markdown widget renders bold text', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Markdown(data: '**Hello**'),
        ),
      ),
    );

    final richText = tester.widget<RichText>(find.byType(RichText));
    final textSpan = richText.text as TextSpan;
    expect(textSpan.children, isNotNull);
    expect(textSpan.children!.length, 1);
    final boldSpan = textSpan.children![0] as TextSpan;
    expect(boldSpan.style!.fontWeight, FontWeight.bold);
    expect(boldSpan.text, 'Hello');
  });

  testWidgets('Markdown widget renders italic text', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Markdown(data: '*Hello*'),
        ),
      ),
    );

    final richText = tester.widget<RichText>(find.byType(RichText));
    final textSpan = richText.text as TextSpan;
    expect(textSpan.children, isNotNull);
    expect(textSpan.children!.length, 1);
    final italicSpan = textSpan.children![0] as TextSpan;
    expect(italicSpan.style!.fontStyle, FontStyle.italic);
    expect(italicSpan.text, 'Hello');
  });

  testWidgets('Markdown widget renders bold and italic text', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Markdown(data: '**Hello** *world*'),
        ),
      ),
    );

    final richText = tester.widget<RichText>(find.byType(RichText));
    final textSpan = richText.text as TextSpan;
    expect(textSpan.children, isNotNull);
    expect(textSpan.children!.length, 3);
    final boldSpan = textSpan.children![0] as TextSpan;
    expect(boldSpan.style!.fontWeight, FontWeight.bold);
    expect(boldSpan.text, 'Hello');
    final spaceSpan = textSpan.children![1] as TextSpan;
    expect(spaceSpan.text, ' ');
    final italicSpan = textSpan.children![2] as TextSpan;
    expect(italicSpan.style!.fontStyle, FontStyle.italic);
    expect(italicSpan.text, 'world');
  });

  testWidgets('Markdown widget uses custom style', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Markdown(
            data: '# Hello',
            style: MarkdownStyle(
              h1: TextStyle(color: Colors.red),
            ),
          ),
        ),
      ),
    );

    final text = tester.widget<Text>(find.byType(Text));
    expect(text.style!.color, Colors.red);
  });

  testWidgets('Markdown widget uses custom builder', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Markdown(
            data: '# Hello',
            builder: MarkdownBuilder(
              h1: (text) => Text(text, style: const TextStyle(color: Colors.blue)),
            ),
          ),
        ),
      ),
    );

    final text = tester.widget<Text>(find.byType(Text));
    expect(text.style!.color, Colors.blue);
  });
}