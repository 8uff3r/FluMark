import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:markdown/src/builder.dart';
import 'package:markdown/src/style.dart';
import 'package:url_launcher/url_launcher.dart';

class MarkdownParser {
  MarkdownParser({
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
  static final RegExp _hrPattern = RegExp(r'^[ \t]*(?:(?:\*[ \t]*){3,}|(?:-[ \t]*){3,}|(?:_[ \t]*){3,})[ \t]*$');
  // static final RegExp _hrPattern = RegExp(r'^ {0,3}([*_-])(?:\s*\1){2,}\s*$');
  static final RegExp _tableSeparatorPattern = RegExp(
    r'^\|(\s*:?-+:?\s*\|)+\$',
  );
  static final RegExp _boldItalicPattern = RegExp(
    r'\*\*(.*?)\*\*|__(.*?)__|(?<!\*)\*([^*]+)\*(?!\*)|(?<!_)\_([^_]+)\_(?!_)',
  );
  static final RegExp _linkPattern = RegExp(r'\[([^\]]+)\]\(([^)]+)\)');

  List<Widget> parse() {
    _orderedListCounter = 1;

    // Use more efficient line splitting
    final lines = _splitLines(data);
    final widgets = <Widget>[];

    int i = 0;
    while (i < lines.length) {
      final line = lines[i];

      // Check for horizontal rules first
      final hrMatch = _hrPattern.firstMatch(line);
      print(line == '* * *');
      if (hrMatch != null) {
        print('Horizontal rule found: ${line}');
        widgets.add(_buildHorizontalRule());
        i++;
        continue;
      }

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
    // Process the header content with markdown formatting (bold, italic, links, etc.)
    final processedContent = _parseLineAsRichText(content);

    switch (level) {
      case 1:
        final customWidget = builder.h1?.call(content);
        if (customWidget != null) {
          return customWidget;
        }
        return Text.rich(
          processedContent,
          style: style.h1,
          textAlign: textAlign,
        );
      case 2:
        final customWidget = builder.h2?.call(content);
        if (customWidget != null) {
          return customWidget;
        }
        return Text.rich(
          processedContent,
          style: style.h2,
          textAlign: textAlign,
        );
      case 3:
        final customWidget = builder.h3?.call(content);
        if (customWidget != null) {
          return customWidget;
        }
        return Text.rich(
          processedContent,
          style: style.h3,
          textAlign: textAlign,
        );
      case 4:
        final customWidget = builder.h4?.call(content);
        if (customWidget != null) {
          return customWidget;
        }
        return Text.rich(
          processedContent,
          style: style.h4,
          textAlign: textAlign,
        );
      case 5:
        final customWidget = builder.h5?.call(content);
        if (customWidget != null) {
          return customWidget;
        }
        return Text.rich(
          processedContent,
          style: style.h5,
          textAlign: textAlign,
        );
      case 6:
        final customWidget = builder.h6?.call(content);
        if (customWidget != null) {
          return customWidget;
        }
        return Text.rich(
          processedContent,
          style: style.h6,
          textAlign: textAlign,
        );
      default:
        final customWidget = builder.h1?.call(content);
        if (customWidget != null) {
          return customWidget;
        }
        return Text.rich(
          processedContent,
          style: style.h1,
          textAlign: textAlign,
        );
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

  Widget _buildHorizontalRule() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Divider(height: 16, thickness: 1, color: Colors.grey.shade400),
    );
  }

  ({Widget widget, int nextLineIndex})? _parseTable(
    List<String> lines,
    int startIndex,
  ) {
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
        return Text(cell.trim(), style: style.tableHeader);
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
          return Text(cell.trim(), style: style.tableCell);
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
      nextLineIndex: currentIndex,
    );
  }

  List<String> _parseTableCells(String line) {
    // More robust table cell parsing
    final cells = <String>[];
    final buffer = StringBuffer();
    bool inEscape = false;

    // Skip the first and last character if they are '|'
    final content = line.startsWith('|')
        ? (line.endsWith('|')
              ? line.substring(1, line.length - 1)
              : line.substring(1))
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

    final richText = _parseLineAsRichText(line);
    return Text.rich(richText, textAlign: textAlign ?? TextAlign.start);
  }

  TextSpan _parseLineAsRichText(String line) {
    // Process escaped characters first
    final processedLine = _processEscapedCharacters(line);

    final spans = <InlineSpan>[];

    // Process the line for all markdown elements
    int lastIndex = 0;

    // To properly handle nested markdown elements, we need to be more careful
    // Find all matches for bold/italic and links
    final allMatches = <Match>[];

    // Add bold/italic matches
    for (final match in _boldItalicPattern.allMatches(processedLine)) {
      allMatches.add(match);
    }

    // Add link matches
    for (final match in _linkPattern.allMatches(processedLine)) {
      allMatches.add(match);
    }

    // Sort all matches by position
    allMatches.sort((a, b) => a.start.compareTo(b.start));

    // Process matches in order, being careful not to process overlapping matches incorrectly
    for (final match in allMatches) {
      // Add text before the match if there's any
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(text: processedLine.substring(lastIndex, match.start)),
        );
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
        } else if (match.groupCount >= 2) {
          // Handle links (need at least 2 groups: text and URL)
          final linkText = match.group(1);
          final linkUrl = match.group(2);
          if (linkText != null && linkUrl != null) {
            spans.add(_createLinkSpan(linkText, linkUrl));
          }
        }
      }

      // Update the last processed index
      lastIndex = match.end;
    }

    // Add any remaining text after the last match
    if (lastIndex < processedLine.length) {
      spans.add(TextSpan(text: processedLine.substring(lastIndex)));
    }

    // If no markdown elements were found, just return the whole line
    if (spans.isEmpty) {
      spans.add(TextSpan(text: processedLine));
    }

    return TextSpan(children: spans, style: const TextStyle());
  }

  String _processEscapedCharacters(String line) {
    // Process backslash escapes: \*, \_, \\, \[, \], \(, \), \#, \+, \-, \., \!, \|
    // This regex finds a backslash followed by any special markdown character
    final escapedPattern = RegExp(r'\\([*_\[\]()#\-+.!|`~<>])');
    return line.replaceAllMapped(escapedPattern, (match) {
      // Return just the character without the backslash
      return match.group(1)!;
    });
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
      recognizer: TapGestureRecognizer()..onTap = () => _launchUrlSafely(url),
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
