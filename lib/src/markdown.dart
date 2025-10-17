import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:markdown/src/builder.dart';
import 'package:markdown/src/style.dart';
import 'package:url_launcher/url_launcher.dart';

class Markdown extends StatelessWidget {
  const Markdown({
    super.key,
    required this.data,
    this.style,
    this.builder,
    this.textAlign,
    this.shrinkWrap = false,
    this.physics,
  });

  final String data;
  final MarkdownStyle? style;
  final MarkdownBuilder? builder;
  final TextAlign? textAlign;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

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
      bold: TextStyle(fontWeight: FontWeight.bold).merge(style?.bold),
      italic: const TextStyle(fontStyle: FontStyle.italic).merge(style?.italic),
      unorderedList: defaultStyle.bodyMedium?.merge(style?.unorderedList),
      orderedList: defaultStyle.bodyMedium?.merge(style?.orderedList),
      link: const TextStyle(
        color: Colors.blue,
        decoration: TextDecoration.underline,
      ).merge(style?.link),
      tableBorder: style?.tableBorder,
      tableHeader: defaultStyle.bodyMedium?.merge(style?.tableHeader),
      tableCell: defaultStyle.bodyMedium?.merge(style?.tableCell),
    );

    final parser = _MarkdownParser(
      data: data,
      style: mdStyle,
      builder: builder ?? const MarkdownBuilder(),
      textAlign: textAlign,
    );
    final widgets = parser.parse();
    
    if (shrinkWrap) {
      return SingleChildScrollView(
        physics: physics,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widgets,
        ),
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets,
      );
    }
  }
}

class _MarkdownParser {
  _MarkdownParser({
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
  
  // Pre-compiled regex patterns for better performance
  static final RegExp _headerPattern = RegExp(r'^(#{1,6})\s+(.*)');
  static final RegExp _unorderedListPattern = RegExp(r'^[\*\-\+]\s+(.*)');
  static final RegExp _orderedListPattern = RegExp(r'^(\d+)\.\s+(.*)');
  static final RegExp _tableSeparatorPattern = RegExp(r'^\|(\s*:?-+:?\s*\|)+$');
  static final RegExp _boldItalicPattern = RegExp(r'\*\*(.*?)\*\*|__(.*?)__|(?<!\*)\*([^*]+)\*(?!\*)|(?<!_)_([^_]+)_(?!_)');
  static final RegExp _linkPattern = RegExp(r'\[([^\]]+)\]\(([^)]+)\)');

  List<Widget> parse() {
    _orderedListCounter = 1;
    
    // Use more efficient line splitting
    final lines = _splitLines(data);
    final widgets = <Widget>[];
    
    int i = 0;
    while (i < lines.length) {
      final line = lines[i];
      
      // Check for headers
      final headerMatch = _headerPattern.firstMatch(line);
      if (headerMatch != null) {
        final level = headerMatch.group(1)!.length;
        final content = headerMatch.group(2)!;
        widgets.add(_buildHeader(level, content));
        i++;
        continue;
      }
      
      // Check for unordered lists
      final unorderedMatch = _unorderedListPattern.firstMatch(line);
      if (unorderedMatch != null) {
        widgets.add(_buildUnorderedList(unorderedMatch.group(1)!));
        i++;
        continue;
      }
      
      // Check for ordered lists
      final orderedMatch = _orderedListPattern.firstMatch(line);
      if (orderedMatch != null) {
        final content = orderedMatch.group(2)!;
        widgets.add(_buildOrderedList(content));
        _orderedListCounter++;
        i++;
        continue;
      }
      
      // Check for tables
      if (line.contains('|')) {
        final tableResult = _parseTable(lines, i);
        if (tableResult != null) {
          widgets.add(tableResult.widget);
          i = tableResult.nextLineIndex;
          continue;
        }
      }
      
      // Regular text line
      if (line.trim().isNotEmpty) {
        widgets.add(_parseLine(line));
      } else {
        widgets.add(const SizedBox(height: 4));
      }
      i++;
    }
    
    return widgets;
  }

  List<String> _splitLines(String text) {
    // More efficient line splitting
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
    // Look for a complete table - find the header, separator, and subsequent data rows
    if (startIndex >= lines.length) return null;
    
    // Check if this line is a valid table header
    final headerLine = lines[startIndex];
    if (!headerLine.contains('|')) return null;
    
    int currentIndex = startIndex;
    
    // Look ahead to find the table separator and determine if this is a valid table
    if (currentIndex + 1 >= lines.length) return null;
    final separatorLine = lines[currentIndex + 1];
    if (!_tableSeparatorPattern.hasMatch(separatorLine)) return null;
    
    // Start collecting table rows
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
    currentIndex += 2;
    
    // Process data rows until we find a line that doesn't belong to the table
    while (currentIndex < lines.length) {
      final line = lines[currentIndex];
      
      // Stop if we encounter a line that's not part of the table
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
    // More robust table cell parsing
    final cells = <String>[];
    final buffer = StringBuffer();
    bool inEscape = false;
    
    // Skip the first and last character if they are '|'
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
    
    // Add the last cell
    if (buffer.isNotEmpty) {
      cells.add(buffer.toString());
    }
    
    // Remove empty cells that might be at the beginning or end due to | characters
    return cells.map((cell) => cell.trim()).toList();
  }

  Widget _parseLine(String line) {
    if (line.isEmpty) {
      return const SizedBox(height: 4); // Small space for empty lines
    }

    final spans = <InlineSpan>[];
    
    // Process the line for all markdown elements in the correct order
    int lastIndex = 0;
    
    // Find all matches for bold/italic and links
    final boldMatches = _boldItalicPattern.allMatches(line).toList();
    final linkMatches = _linkPattern.allMatches(line).toList();
    
    // Create a combined list of all matches and sort by position
    final allMatches = <Match>[];
    allMatches.addAll(boldMatches);
    allMatches.addAll(linkMatches);
    allMatches.sort((a, b) => a.start.compareTo(b.start));
    
    // Process matches in order
    for (final match in allMatches) {
      // Add text before the match
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: line.substring(lastIndex, match.start)));
      }
      
      // Process the matched element
      final matchedText = match[0];
      if (matchedText != null) {
        // Check if it's bold/italic
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
          // Handle links
          final linkText = match.group(1);
          final linkUrl = match.group(2);
          if (linkText != null && linkUrl != null) {
            spans.add(_createLinkSpan(linkText, linkUrl));
          }
        }
      }
      
      lastIndex = match.end;
    }
    
    // Add remaining text after the last match
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