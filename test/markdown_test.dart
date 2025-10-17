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

    final text = tester.widget<Text>(find.byType(Text));
    final textSpan = text.textSpan as TextSpan;
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

    final text = tester.widget<Text>(find.byType(Text));
    final textSpan = text.textSpan as TextSpan;
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

    final text = tester.widget<Text>(find.byType(Text));
    final textSpan = text.textSpan as TextSpan;
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

  testWidgets('Markdown widget renders unordered list', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Markdown(data: '* Item 1\n* Item 2'),
        ),
      ),
    );

    final rows = tester.widgetList<Row>(find.byType(Row));
    expect(rows.length, 2);
    final item1 = (rows.first.children[1] as Expanded).child as Text;
    expect(item1.data, 'Item 1');
    final item2 = (rows.last.children[1] as Expanded).child as Text;
    expect(item2.data, 'Item 2');
  });

  testWidgets('Markdown widget renders ordered list', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Markdown(data: '1. Item 1\n2. Item 2'),
        ),
      ),
    );

    final rows = tester.widgetList<Row>(find.byType(Row));
    expect(rows.length, 2);
    final item1 = (rows.first.children[1] as Expanded).child as Text;
    expect(item1.data, 'Item 1');
    final item2 = (rows.last.children[1] as Expanded).child as Text;
    expect(item2.data, 'Item 2');
  });

  testWidgets('Markdown widget renders links', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Markdown(data: '[Google](https://google.com)'),
        ),
      ),
    );

    final text = tester.widget<Text>(find.byType(Text));
    final textSpan = text.textSpan as TextSpan;
    expect(textSpan.children, isNotNull);
    expect(textSpan.children!.length, 1);
    final linkSpan = textSpan.children![0] as TextSpan;
    expect(linkSpan.text, 'Google');
    expect(linkSpan.style!.color, Colors.blue);
    expect(linkSpan.style!.decoration, TextDecoration.underline);
  });

  testWidgets('Markdown widget renders tables', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Markdown(data: '| Header 1 | Header 2 |\n| --- | --- |\n| Cell 1 | Cell 2 |'),
        ),
      ),
    );

    final table = tester.widget<Table>(find.byType(Table));
    expect(table.children.length, 2);
    final headerRow = table.children[0];
    final headerCell1 = headerRow.children[0] as Text;
    expect(headerCell1.data, 'Header 1');
    final headerCell2 = headerRow.children[1] as Text;
    expect(headerCell2.data, 'Header 2');
    final bodyRow = table.children[1];
    final bodyCell1 = bodyRow.children[0] as Text;
    expect(bodyCell1.data, 'Cell 1');
    final bodyCell2 = bodyRow.children[1] as Text;
    expect(bodyCell2.data, 'Cell 2');
  });

  testWidgets('Markdown widget applies textAlign', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Markdown(data: 'Hello', textAlign: TextAlign.center),
        ),
      ),
    );

    final richText = tester.widget<RichText>(find.byType(RichText));
    expect(richText.textAlign, TextAlign.center);
  });
}