import 'package:flutter/material.dart';
import 'package:markdown/builder.dart';
import 'package:markdown/style.dart';

class Markdown extends StatelessWidget {
  const Markdown({super.key, required this.data, this.style, this.builder});

  final String data;
  final MarkdownStyle? style;
  final MarkdownBuilder? builder;

  @override
  Widget build(BuildContext context) {
    final defaultStyle = Theme.of(context).textTheme;
    final mdStyle =
        style ??
        MarkdownStyle(
          h1: defaultStyle.headlineMedium,
          h2: defaultStyle.headlineSmall,
          h3: defaultStyle.titleLarge,
          h4: defaultStyle.titleMedium,
          h5: defaultStyle.titleSmall,
          h6: defaultStyle.bodyLarge,
          bold: const TextStyle(fontWeight: FontWeight.bold),
          italic: const TextStyle(fontStyle: FontStyle.italic),
        );

    final parser = _MarkdownParser(
      data: data,
      style: mdStyle,
      builder: builder ?? MarkdownBuilder(),
    );
    final widgets = parser.parse();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}

class _MarkdownParser {
  _MarkdownParser({
    required this.data,
    required this.style,
    required this.builder,
  });

  final String data;
  final MarkdownStyle style;
  final MarkdownBuilder builder;

  List<Widget> parse() {
    final lines = data.split('\n');
    final widgets = <Widget>[];
    for (final line in lines) {
      if (line.startsWith('# ')) {
        final text = line.substring(2);
        final widget = builder.h1?.call(text) ?? Text(text, style: style.h1);
        widgets.add(widget);
      } else if (line.startsWith('## ')) {
        final text = line.substring(3);
        final widget = builder.h2?.call(text) ?? Text(text, style: style.h2);
        widgets.add(widget);
      } else if (line.startsWith('### ')) {
        final text = line.substring(4);
        final widget = builder.h3?.call(text) ?? Text(text, style: style.h3);
        widgets.add(widget);
      } else if (line.startsWith('#### ')) {
        final text = line.substring(5);
        final widget = builder.h4?.call(text) ?? Text(text, style: style.h4,);
        widgets.add(widget);
      } else if (line.startsWith('##### ')) {
        final text = line.substring(6);
        final widget = builder.h5?.call(text) ?? Text(text, style: style.h5);
        widgets.add(widget);
      } else if (line.startsWith('###### ')) {
        final text = line.substring(7);
        final widget = builder.h6?.call(text) ?? Text(text, style: style.h6);
        widgets.add(widget);
      } else {
        widgets.add(_parseLine(line));
      }
    }
    return widgets;
  }

  Widget _parseLine(String line) {
    final spans = <InlineSpan>[];
    final regex = RegExp(r'(\*{1,2})([^\*]+)\1');
    final matches = regex.allMatches(line);

    var lastIndex = 0;
    for (final match in matches) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: line.substring(lastIndex, match.start)));
      }

      final delimiter = match.group(1)!;
      final content = match.group(2)!;

      if (delimiter == '**') {
        final boldBuilder = builder.bold?.call(content);
        if (boldBuilder != null) {
          spans.add(WidgetSpan(child: boldBuilder));
        } else {
          spans.add(TextSpan(text: content, style: style.bold));
        }
      } else {
        final italicBuilder = builder.italic?.call(content);
        if (italicBuilder != null) {
          spans.add(WidgetSpan(child: italicBuilder));
        } else {
          spans.add(TextSpan(text: content, style: style.italic));
        }
      }

      lastIndex = match.end;
    }

    if (lastIndex < line.length) {
      spans.add(TextSpan(text: line.substring(lastIndex)));
    }

    if (spans.isEmpty) {
      spans.add(TextSpan(text: line));
    }

    return RichText(
      text: TextSpan(children: spans, style: const TextStyle()),
    );
  }
}
