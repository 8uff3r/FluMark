import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:markdown/builder.dart';
import 'package:markdown/style.dart';
import 'package:url_launcher/url_launcher.dart';

class Markdown extends StatelessWidget {
  const Markdown({super.key, required this.data, this.style, this.builder});

  final String data;
  final MarkdownStyle? style;
  final MarkdownBuilder? builder;

  @override
  Widget build(BuildContext context) {
    final defaultStyle = Theme.of(context).textTheme;
    final mdStyle = MarkdownStyle(
      h1: defaultStyle.headlineMedium?.merge(style?.h1),
      h2: defaultStyle.headlineSmall?.merge(style?.h2),
      h3: defaultStyle.titleLarge?.merge(style?.h3),
      h4: defaultStyle.titleMedium?.merge(style?.h4),
      h5: defaultStyle.titleSmall?.merge(style?.h5),
      h6: defaultStyle.bodyLarge?.merge(style?.h6),
      bold: const TextStyle(fontWeight: FontWeight.bold).merge(style?.bold),
      italic: const TextStyle(fontStyle: FontStyle.italic).merge(style?.italic),
      unorderedList: defaultStyle.bodyMedium?.merge(style?.unorderedList),
      orderedList: defaultStyle.bodyMedium?.merge(style?.orderedList),
      link: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline).merge(style?.link),
      tableBorder: style?.tableBorder,
      tableHeader: defaultStyle.bodyMedium?.merge(style?.tableHeader),
      tableCell: defaultStyle.bodyMedium?.merge(style?.tableCell),
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
  int _orderedListCounter = 1;
  bool _isParsingTable = false;

  List<Widget> parse() {
    _orderedListCounter = 1;
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
      } else if (line.startsWith('* ') || line.startsWith('- ') || line.startsWith('+ ')) {
        final text = line.substring(2);
        final widget = builder.unorderedList?.call(text) ??
            Row(
              children: [
                const Text('• '),
                Expanded(child: Text(text, style: style.unorderedList)),
              ],
            );
        widgets.add(widget);
      } else if (line.startsWith(RegExp(r'^[0-9]+\. '))) {
        final text = line.substring(line.indexOf('. ') + 2);
        final widget = builder.orderedList?.call(text, _orderedListCounter) ??
            Row(
              children: [
                Text('$_orderedListCounter. '),
                Expanded(child: Text(text, style: style.orderedList)),
              ],
            );
        widgets.add(widget);
        _orderedListCounter++;
      } else if (line.contains('|')) {
        if (!_isParsingTable) {
          _isParsingTable = true;
          final table = _parseTable(lines.sublist(lines.indexOf(line)));
          widgets.add(table);
        }
      } else {
        _isParsingTable = false;
        widgets.add(_parseLine(line));
      }
    }
    return widgets;
  }

  Widget _parseLine(String line) {
    final spans = <InlineSpan>[];
    final regex = RegExp(r'(\*\*|\*)(.*?)\1|\!\[(.*?)\]\((.*?)\)|\[(.*?)\]\((.*?)\)');
    final matches = regex.allMatches(line);

    var lastIndex = 0;
    for (final match in matches) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: line.substring(lastIndex, match.start)));
      }

      final boldOrItalic = match.group(1);
      final boldOrItalicContent = match.group(2);
      final linkText = match.group(5);
      final linkUrl = match.group(6);

      if (boldOrItalic != null && boldOrItalicContent != null) {
        if (boldOrItalic == '**') {
          final boldBuilder = builder.bold?.call(boldOrItalicContent);
          if (boldBuilder != null) {
            spans.add(WidgetSpan(child: boldBuilder));
          } else {
            spans.add(TextSpan(text: boldOrItalicContent, style: style.bold));
          }
        } else {
          final italicBuilder = builder.italic?.call(boldOrItalicContent);
          if (italicBuilder != null) {
            spans.add(WidgetSpan(child: italicBuilder));
          } else {
            spans.add(TextSpan(text: boldOrItalicContent, style: style.italic));
          }
        }
      } else if (linkText != null && linkUrl != null) {
        final linkBuilder = builder.link?.call(linkText, linkUrl);
        if (linkBuilder != null) {
          spans.add(WidgetSpan(child: linkBuilder));
        } else {
          spans.add(
            TextSpan(
              text: linkText,
              style: style.link,
              recognizer: TapGestureRecognizer()..onTap = () => launchUrl(Uri.parse(linkUrl)),
            ),
          );
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

  Widget _parseTable(List<String> lines) {
    final rows = <TableRow>[];
    var isHeader = true;
    for (final line in lines) {
      if (!line.contains('|') || line.contains(RegExp(r'^\|(\s*:?-+:?\s*\|)+$'))) {
        continue;
      }
      final cells = line.split('|').where((cell) => cell.isNotEmpty).map((cell) {
        final cellBuilder = builder.tableCell?.call(cell.trim());
        if (cellBuilder != null) {
          return cellBuilder;
        }
        return Text(cell.trim(), style: isHeader ? style.tableHeader : style.tableCell);
      }).toList();

      final rowBuilder = builder.tableRow?.call(cells);
      if (rowBuilder != null) {
        rows.add(rowBuilder);
      } else {
        rows.add(TableRow(children: cells));
      }
      isHeader = false;
    }

    final tableBuilder = builder.table?.call(rows);
    if (tableBuilder != null) {
      return tableBuilder;
    }

    return Table(
      border: style.tableBorder,
      children: rows,
    );
  }
}
