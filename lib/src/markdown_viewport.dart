import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:markdown/src/builder.dart';
import 'package:markdown/src/style.dart';
import 'package:markdown/src/markdown.dart';
import 'package:url_launcher/url_launcher.dart';

/// A performance-optimized markdown widget that renders content lazily
/// as the user scrolls, making it suitable for very large markdown documents.
/// 
/// This widget uses [ListView.builder] to render content on-demand, significantly
/// improving performance for large documents by only building widgets that are visible.
/// 
/// Note: This widget requires a bounded height constraint. If placed inside a 
/// column or other unbounded container, wrap it with [Expanded], [SizedBox] with 
/// a fixed height, or ensure the parent provides bounded constraints.
class MarkdownViewport extends StatefulWidget {
  const MarkdownViewport({
    super.key,
    required this.data,
    this.style,
    this.builder,
    this.textAlign,
    this.physics,
    this.controller,
  });

  final String data;
  final MarkdownStyle? style;
  final MarkdownBuilder? builder;
  final TextAlign? textAlign;
  final ScrollPhysics? physics;
  final ScrollController? controller;

  @override
  State<MarkdownViewport> createState() => _MarkdownViewportState();
}

class _MarkdownViewportState extends State<MarkdownViewport> {
  List<_MarkdownElement>? _elements;

  @override
  void initState() {
    super.initState();
    // Don't call _parseMarkdownElements here since Theme.of might not be available yet
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _parseMarkdownElements();
  }

  @override
  void didUpdateWidget(MarkdownViewport oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _parseMarkdownElements();
    }
  }

  void _parseMarkdownElements() {
    final defaultStyle = Theme.of(context).textTheme;
    final mdStyle = MarkdownStyle(
      h1: defaultStyle.headlineMedium?.merge(widget.style?.h1),
      h2: defaultStyle.headlineSmall?.merge(widget.style?.h2),
      h3: defaultStyle.titleLarge?.merge(widget.style?.h3),
      h4: defaultStyle.titleMedium?.merge(widget.style?.h4),
      h5: defaultStyle.titleSmall?.merge(widget.style?.h5),
      h6: defaultStyle.bodyLarge?.merge(widget.style?.h6),
      bold: const TextStyle(fontWeight: FontWeight.bold).merge(widget.style?.bold),
      italic: const TextStyle(fontStyle: FontStyle.italic).merge(widget.style?.italic),
      unorderedList: defaultStyle.bodyMedium?.merge(widget.style?.unorderedList),
      orderedList: defaultStyle.bodyMedium?.merge(widget.style?.orderedList),
      link: const TextStyle(
        color: Colors.blue,
        decoration: TextDecoration.underline,
      ).merge(widget.style?.link),
      tableBorder: widget.style?.tableBorder,
      tableHeader: defaultStyle.bodyMedium?.merge(widget.style?.tableHeader),
      tableCell: defaultStyle.bodyMedium?.merge(widget.style?.tableCell),
    );

    final parser = _MarkdownElementParser(
      data: widget.data,
      style: mdStyle,
      builder: widget.builder ?? const MarkdownBuilder(),
      textAlign: widget.textAlign,
    );
    setState(() {
      _elements = parser.parse();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_elements == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Check if we have bounded height, if not use CustomScrollView
        if (constraints.maxHeight == double.infinity) {
          // If the parent doesn't provide bounded height, use CustomScrollView
          return CustomScrollView(
            controller: widget.controller,
            physics: widget.physics,
            slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  childCount: _elements!.length,
                  (context, index) => _buildElement(_elements![index]),
                ),
              ),
            ],
          );
        } else {
          // If parent provides bounded height, use ListView
          return ListView.builder(
            controller: widget.controller,
            physics: widget.physics,
            itemCount: _elements!.length,
            itemBuilder: (context, index) {
              return _buildElement(_elements![index]);
            },
          );
        }
      },
    );
  }

  Widget _buildElement(_MarkdownElement element) {
    switch (element.type) {
      case _MarkdownElementType.text:
        return (element as _TextElement).widget;
      case _MarkdownElementType.header:
        return (element as _HeaderElement).widget;
      case _MarkdownElementType.unorderedList:
        return (element as _UnorderedListElement).widget;
      case _MarkdownElementType.orderedList:
        return (element as _OrderedListElement).widget;
      case _MarkdownElementType.table:
        return (element as _TableElement).widget;
      default:
        return const SizedBox.shrink();
    }
  }
}

// Enums and data classes for representing parsed markdown elements
enum _MarkdownElementType {
  text,
  header,
  unorderedList,
  orderedList,
  table,
}

abstract class _MarkdownElement {
  const _MarkdownElement(this.type);
  final _MarkdownElementType type;
}

class _TextElement extends _MarkdownElement {
  const _TextElement(this.widget) : super(_MarkdownElementType.text);
  final Widget widget;
}

class _HeaderElement extends _MarkdownElement {
  const _HeaderElement(this.widget) : super(_MarkdownElementType.header);
  final Widget widget;
}

class _UnorderedListElement extends _MarkdownElement {
  const _UnorderedListElement(this.widget) : super(_MarkdownElementType.unorderedList);
  final Widget widget;
}

class _OrderedListElement extends _MarkdownElement {
  const _OrderedListElement(this.widget) : super(_MarkdownElementType.orderedList);
  final Widget widget;
}

class _TableElement extends _MarkdownElement {
  const _TableElement(this.widget) : super(_MarkdownElementType.table);
  final Widget widget;
}

/// Parser that converts markdown string to a list of structured elements
class _MarkdownElementParser {
  _MarkdownElementParser({
    required this.data,
    required this.style,
    required this.builder,
    this.textAlign,
  });

  final String data;
  final MarkdownStyle style;
  final MarkdownBuilder builder;
  final TextAlign? textAlign;
  int _orderedListCounter = 1;
  
  // Pre-compiled regex patterns
  static final RegExp _headerPattern = RegExp(r'^(#{1,6})\s+(.*)');
  static final RegExp _unorderedListPattern = RegExp(r'^[\*\-\+]\s+(.*)');
  static final RegExp _orderedListPattern = RegExp(r'^(\d+)\.\s+(.*)');
  static final RegExp _tableSeparatorPattern = RegExp(r'^\|(\s*:?-+:?\s*\|)+$');
  static final RegExp _boldItalicPattern = RegExp(r'\*\*(.*?)\*\*|__(.*?)__|(?<!\*)\*([^*]+)\*(?!\*)|(?<!_)_([^_]+)_(?!_)');
  static final RegExp _linkPattern = RegExp(r'\[([^\]]+)\]\(([^)]+)\)');

  List<_MarkdownElement> parse() {
    _orderedListCounter = 1;
    final lines = _splitLines(data);
    final elements = <_MarkdownElement>[];
    
    int i = 0;
    while (i < lines.length) {
      final line = lines[i];
      
      // Check for headers
      final headerMatch = _headerPattern.firstMatch(line);
      if (headerMatch != null) {
        final level = headerMatch.group(1)!.length;
        final content = headerMatch.group(2)!;
        elements.add(_HeaderElement(_buildHeader(level, content)));
        i++;
        continue;
      }
      
      // Check for unordered lists
      final unorderedMatch = _unorderedListPattern.firstMatch(line);
      if (unorderedMatch != null) {
        elements.add(_UnorderedListElement(_buildUnorderedList(unorderedMatch.group(1)!)));
        i++;
        continue;
      }
      
      // Check for ordered lists
      final orderedMatch = _orderedListPattern.firstMatch(line);
      if (orderedMatch != null) {
        final content = orderedMatch.group(2)!;
        elements.add(_OrderedListElement(_buildOrderedList(content)));
        _orderedListCounter++;
        i++;
        continue;
      }
      
      // Check for tables
      if (line.contains('|')) {
        final tableResult = _parseTable(lines, i);
        if (tableResult != null) {
          elements.add(_TableElement(tableResult.widget));
          i = tableResult.nextLineIndex;
          continue;
        }
      }
      
      // Regular text line
      if (line.trim().isNotEmpty) {
        elements.add(_TextElement(_parseLine(line)));
      } else {
        elements.add(_TextElement(const SizedBox(height: 4)));
      }
      i++;
    }
    
    return elements;
  }

  List<String> _splitLines(String text) {
    // Efficient line splitting
    final lines = <String>[];
    int start = 0;
    int index = 0;
    
    while (index < text.length) {
      if (text[index] == '\n') {
        lines.add(text.substring(start, index));
        start = index + 1;
      }
      index++;
    }
    // Add the last line if it doesn't end with newline
    if (start < text.length) {
      lines.add(text.substring(start));
    }
    
    return lines;
  }

  Widget _buildHeader(int level, String content) {
    switch (level) {
      case 1:
        return builder.h1?.call(content) ?? Text(content, style: style.h1, textAlign: textAlign);
      case 2:
        return builder.h2?.call(content) ?? Text(content, style: style.h2, textAlign: textAlign);
      case 3:
        return builder.h3?.call(content) ?? Text(content, style: style.h3, textAlign: textAlign);
      case 4:
        return builder.h4?.call(content) ?? Text(content, style: style.h4, textAlign: textAlign);
      case 5:
        return builder.h5?.call(content) ?? Text(content, style: style.h5, textAlign: textAlign);
      case 6:
        return builder.h6?.call(content) ?? Text(content, style: style.h6, textAlign: textAlign);
      default:
        return builder.h1?.call(content) ?? Text(content, style: style.h1, textAlign: textAlign);
    }
  }

  Widget _buildUnorderedList(String content) {
    return builder.unorderedList?.call(content) ??
        Row(
          children: [
            const Text('• ', style: TextStyle(fontSize: 16)),
            Expanded(
              child: Text(
                content,
                style: style.unorderedList,
                textAlign: textAlign,
              ),
            ),
          ],
        );
  }

  Widget _buildOrderedList(String content) {
    final currentCounter = _orderedListCounter;
    return builder.orderedList?.call(content, currentCounter) ??
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$currentCounter. ', style: style.orderedList),
            Expanded(
              child: Text(
                content,
                style: style.orderedList,
                textAlign: textAlign,
              ),
            ),
          ],
        );
  }

  ({Widget widget, int nextLineIndex})? _parseTable(List<String> lines, int startIndex) {
    if (startIndex >= lines.length) return null;
    
    final headerLine = lines[startIndex];
    if (!headerLine.contains('|')) return null;
    
    if (startIndex + 1 >= lines.length) return null;
    final separatorLine = lines[startIndex + 1];
    if (!_tableSeparatorPattern.hasMatch(separatorLine)) return null;
    
    final rows = <TableRow>[];
    var isHeader = true;
    
    // Process header row
    final headerCells = _parseTableCells(headerLine);
    if (headerCells.isEmpty) return null;
    
    final headerRow = TableRow(
      children: headerCells.map((cell) {
        final cellBuilder = builder.tableCell?.call(cell.trim());
        if (cellBuilder != null) {
          return cellBuilder;
        }
        return Text(
          cell.trim(),
          style: style.tableHeader,
        );
      }).toList(),
    );
    rows.add(headerRow);
    isHeader = false;
    
    // Move to data rows
    int currentIndex = startIndex + 2;
    
    // Process data rows
    while (currentIndex < lines.length) {
      final line = lines[currentIndex];
      
      if (!line.contains('|') || _tableSeparatorPattern.hasMatch(line)) {
        break;
      }
      
      final dataCells = _parseTableCells(line);
      if (dataCells.isEmpty) break;
      
      final dataRow = TableRow(
        children: dataCells.map((cell) {
          final cellBuilder = builder.tableCell?.call(cell.trim());
          if (cellBuilder != null) {
            return cellBuilder;
          }
          return Text(
            cell.trim(),
            style: style.tableCell,
          );
        }).toList(),
      );
      rows.add(dataRow);
      
      currentIndex++;
    }
    
    final tableBuilder = builder.table?.call(rows);
    if (tableBuilder != null) {
      return (widget: tableBuilder, nextLineIndex: currentIndex);
    }
    
    return (
      widget: Table(border: style.tableBorder, children: rows),
      nextLineIndex: currentIndex
    );
  }

  List<String> _parseTableCells(String line) {
    final cells = <String>[];
    final buffer = StringBuffer();
    bool inEscape = false;
    
    final content = line.startsWith('|') 
        ? (line.endsWith('|') ? line.substring(1, line.length - 1) : line.substring(1))
        : (line.endsWith('|') ? line.substring(0, line.length - 1) : line);
    
    for (int i = 0; i < content.length; i++) {
      final char = content[i];
      
      if (inEscape) {
        buffer.write(char);
        inEscape = false;
        continue;
      }
      
      if (char == '\\') {
        inEscape = true;
        continue;
      }
      
      if (char == '|') {
        cells.add(buffer.toString());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }
    
    if (buffer.isNotEmpty) {
      cells.add(buffer.toString());
    }
    
    return cells.map((cell) => cell.trim()).toList();
  }

  Widget _parseLine(String line) {
    if (line.isEmpty) {
      return const SizedBox(height: 4);
    }

    final spans = <InlineSpan>[];
    int lastIndex = 0;
    
    final boldMatches = _boldItalicPattern.allMatches(line).toList();
    final linkMatches = _linkPattern.allMatches(line).toList();
    
    final allMatches = <Match>[];
    allMatches.addAll(boldMatches);
    allMatches.addAll(linkMatches);
    allMatches.sort((a, b) => a.start.compareTo(b.start));
    
    for (final match in allMatches) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: line.substring(lastIndex, match.start)));
      }
      
      final matchedText = match[0];
      if (matchedText != null) {
        if (matchedText.startsWith('**') && matchedText.endsWith('**')) {
          final content = matchedText.substring(2, matchedText.length - 2);
          spans.add(_createBoldSpan(content));
        } else if (matchedText.startsWith('__') && matchedText.endsWith('__')) {
          final content = matchedText.substring(2, matchedText.length - 2);
          spans.add(_createBoldSpan(content));
        } else if (matchedText.startsWith('*') && matchedText.endsWith('*')) {
          final content = matchedText.substring(1, matchedText.length - 1);
          spans.add(_createItalicSpan(content));
        } else if (matchedText.startsWith('_') && matchedText.endsWith('_')) {
          final content = matchedText.substring(1, matchedText.length - 1);
          spans.add(_createItalicSpan(content));
        } else if (match.groupCount >= 1) {
          final linkText = match.group(1);
          final linkUrl = match.group(2);
          if (linkText != null && linkUrl != null) {
            spans.add(_createLinkSpan(linkText, linkUrl));
          }
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
    
    return Text.rich(
      TextSpan(children: spans, style: const TextStyle()),
      textAlign: textAlign ?? TextAlign.start,
    );
  }
  
  InlineSpan _createBoldSpan(String content) {
    final boldBuilder = builder.bold?.call(content);
    if (boldBuilder != null) {
      return WidgetSpan(child: boldBuilder);
    }
    return TextSpan(text: content, style: style.bold);
  }
  
  InlineSpan _createItalicSpan(String content) {
    final italicBuilder = builder.italic?.call(content);
    if (italicBuilder != null) {
      return WidgetSpan(child: italicBuilder);
    }
    return TextSpan(text: content, style: style.italic);
  }
  
  InlineSpan _createLinkSpan(String text, String url) {
    final linkBuilder = builder.link?.call(text, url);
    if (linkBuilder != null) {
      return WidgetSpan(child: linkBuilder);
    }
    return TextSpan(
      text: text,
      style: style.link,
      recognizer: TapGestureRecognizer()
        ..onTap = () => _launchUrlSafely(url),
    );
  }
  
  void _launchUrlSafely(String url) async {
    try {
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      // Handle error silently or log as needed
    }
  }
}