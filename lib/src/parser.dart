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
    this.searchQuery,
  });

  final String data;
  final MarkdownStyle style;
  final MarkdownBuilder builder;
  final TextAlign? textAlign;
  final String? searchQuery;
  int _orderedListCounter = 1;
  bool _inOrderedList = false;
  int _widgetKeyCounter = 0;
  bool _lastWasBlockOrEmpty = false;

  // Pre-compiled regex patterns for better performance
  static final RegExp _headerPattern = RegExp(r'^(#{1,6})\s+(.*)');
  static final RegExp _unorderedListPattern = RegExp(r'^(\s*)[\*\-\+]\s+(.*)');
  static final RegExp _orderedListPattern = RegExp(r'^(\s*)(\d+)\.\s+(.*)');

  // Fixed: horizontal rule - allows optional spaces between chars
  static final RegExp _hrPattern = RegExp(
    r'^[ \t]*(?:(?:\*\s*){3,}|(?:-\s*){3,}|(?:_\s*){3,})[ \t]*$',
  );

  // Fixed: table separator pattern (removed \$ typo)
  static final RegExp _tableSeparatorPattern = RegExp(r'^\|(\s*:?-+:?\s*\|)+$');

  // Improved: better bold/italic pattern with bold-italic support
  static final RegExp _boldItalicCombinedPattern = RegExp(
    r'\*\*\*(.+?)\*\*\*|___(.+?)___|' // Bold+Italic
    r'\*\*(.+?)\*\*|__(.+?)__|' // Bold
    r'(?<!\*)\*([^\s*](?:[^*]*[^\s*])?)\*(?!\*)|' // Italic *
    r'(?<!_)_([^\s_](?:[^_]*[^\s_])?)_(?!_)', // Italic _
  );

  static final RegExp _strikethroughPattern = RegExp(r'~~(.+?)~~');
  static final RegExp _inlineCodePattern = RegExp(r'`([^`]+)`');
  static final RegExp _linkPattern = RegExp(r'\[([^\]]+)\]\(([^)]+)\)');
  static final RegExp _imagePattern = RegExp(r'!\[([^\]]*)\]\(([^)]+)\)');

  // Code block patterns
  static final RegExp _fencedCodeBlockStart = RegExp(r'^```(\w*)');
  static final RegExp _fencedCodeBlockEnd = RegExp(r'^```\s*$');
  static final RegExp _indentedCodeBlock = RegExp(r'^(?: {4}|\t)(.*)');

  // Blockquote pattern
  static final RegExp _blockquotePattern = RegExp(r'^>\s?(.*)');

  /// Parses the markdown data and returns a list of widgets.
  List<Widget> parse() {
    _orderedListCounter = 1;
    _inOrderedList = false;
    _widgetKeyCounter = 0;
    _lastWasBlockOrEmpty = false;

    final lines = _splitLines(data);
    final widgets = <Widget>[];

    int i = 0;
    while (i < lines.length) {
      final line = lines[i];

      // Check for fenced code blocks
      final codeBlockMatch = _fencedCodeBlockStart.firstMatch(line);
      if (codeBlockMatch != null) {
        final result = _parseFencedCodeBlock(lines, i);
        if (result != null) {
          widgets.add(
            KeyedSubtree(
              key: ValueKey('md_code_$_widgetKeyCounter'),
              child: result.widget,
            ),
          );
          _widgetKeyCounter++;
          _lastWasBlockOrEmpty = true;
          i = result.nextLineIndex;
          continue;
        }
      }

      // Check for horizontal rules
      if (_hrPattern.hasMatch(line)) {
        widgets.add(
          KeyedSubtree(
            key: ValueKey('md_hr_$_widgetKeyCounter'),
            child: _buildHorizontalRule(),
          ),
        );
        _widgetKeyCounter++;
        _lastWasBlockOrEmpty = true;
        _resetListCounter();
        i++;
        continue;
      }

      // Check for headers
      final headerMatch = _headerPattern.firstMatch(line);
      if (headerMatch != null) {
        final level = headerMatch.group(1)!.length;
        final content = headerMatch.group(2)!;
        widgets.add(
          KeyedSubtree(
            key: ValueKey('md_h${level}_$_widgetKeyCounter'),
            child: _buildHeader(level, content),
          ),
        );
        _widgetKeyCounter++;
        _lastWasBlockOrEmpty = false;
        _resetListCounter();
        i++;
        continue;
      }

      // Check for blockquotes
      final blockquoteMatch = _blockquotePattern.firstMatch(line);
      if (blockquoteMatch != null) {
        final content = blockquoteMatch.group(1)!;
        widgets.add(
          KeyedSubtree(
            key: ValueKey('md_quote_$_widgetKeyCounter'),
            child: _buildBlockquote(content),
          ),
        );
        _widgetKeyCounter++;
        _lastWasBlockOrEmpty = false;
        _resetListCounter();
        i++;
        continue;
      }

      // Check for unordered lists
      final unorderedMatch = _unorderedListPattern.firstMatch(line);
      if (unorderedMatch != null) {
        final indent = unorderedMatch.group(1)!.length;
        final content = unorderedMatch.group(2)!;
        widgets.add(
          KeyedSubtree(
            key: ValueKey('md_ul_$_widgetKeyCounter'),
            child: _buildUnorderedList(content, indent),
          ),
        );
        _widgetKeyCounter++;
        _lastWasBlockOrEmpty = false;
        _resetListCounter();
        i++;
        continue;
      }

      // Check for ordered lists
      final orderedMatch = _orderedListPattern.firstMatch(line);
      if (orderedMatch != null) {
        final indent = orderedMatch.group(1)!.length;
        final content = orderedMatch.group(3)!;

        if (!_inOrderedList || indent == 0) {
          _inOrderedList = true;
        }

        widgets.add(
          KeyedSubtree(
            key: ValueKey('md_ol_$_widgetKeyCounter'),
            child: _buildOrderedList(content, indent),
          ),
        );
        _widgetKeyCounter++;
        _lastWasBlockOrEmpty = false;
        _orderedListCounter++;
        i++;
        continue;
      } else {
        _resetListCounter();
      }

      // Check for tables
      if (line.contains('|')) {
        final tableResult = _parseTable(lines, i);
        if (tableResult != null) {
          widgets.add(
            KeyedSubtree(
              key: ValueKey('md_table_$_widgetKeyCounter'),
              child: tableResult.widget,
            ),
          );
          _widgetKeyCounter++;
          _lastWasBlockOrEmpty = true;
          i = tableResult.nextLineIndex;
          continue;
        }
      }

      // Check for indented code blocks (4 spaces or tab)
      final indentedCodeMatch = _indentedCodeBlock.firstMatch(line);
      if (indentedCodeMatch != null) {
        final result = _parseIndentedCodeBlock(lines, i);
        if (result != null) {
          widgets.add(
            KeyedSubtree(
              key: ValueKey('md_code_$_widgetKeyCounter'),
              child: result.widget,
            ),
          );
          _widgetKeyCounter++;
          _lastWasBlockOrEmpty = true;
          i = result.nextLineIndex;
          continue;
        }
      }

      // Empty lines create paragraph spacing (skip if last was already block/empty)
      if (line.trim().isEmpty) {
        if (!_lastWasBlockOrEmpty) {
          widgets.add(const SizedBox(height: 12));
          _lastWasBlockOrEmpty = true;
        }
        _resetListCounter();
      } else {
        // Regular text line
        widgets.add(
          KeyedSubtree(
            key: ValueKey('md_text_$_widgetKeyCounter'),
            child: _parseLine(line),
          ),
        );
        _widgetKeyCounter++;
        _lastWasBlockOrEmpty = false;
      }
      i++;
    }

    return widgets;
  }

  void _resetListCounter() {
    if (_inOrderedList) {
      _orderedListCounter = 1;
      _inOrderedList = false;
    }
  }

  List<String> _splitLines(String text) {
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
    if (start < text.length) {
      lines.add(text.substring(start));
    }

    return lines;
  }

  ({Widget widget, int nextLineIndex})? _parseFencedCodeBlock(
    List<String> lines,
    int startIndex,
  ) {
    final startMatch = _fencedCodeBlockStart.firstMatch(lines[startIndex]);
    if (startMatch == null) return null;

    final language = startMatch.group(1) ?? '';
    final codeLines = <String>[];
    int currentIndex = startIndex + 1;

    while (currentIndex < lines.length) {
      final line = lines[currentIndex];
      if (_fencedCodeBlockEnd.hasMatch(line)) {
        final codeContent = codeLines.join('\n');
        final widget = _buildCodeBlock(codeContent, language);
        return (widget: widget, nextLineIndex: currentIndex + 1);
      }
      codeLines.add(line);
      currentIndex++;
    }

    // No closing fence found, treat as regular paragraph
    return null;
  }

  ({Widget widget, int nextLineIndex})? _parseIndentedCodeBlock(
    List<String> lines,
    int startIndex,
  ) {
    final codeLines = <String>[];
    int currentIndex = startIndex;

    while (currentIndex < lines.length) {
      final line = lines[currentIndex];
      final match = _indentedCodeBlock.firstMatch(line);

      if (match != null) {
        codeLines.add(match.group(1)!);
        currentIndex++;
      } else if (line.trim().isEmpty) {
        // Empty lines are allowed in code blocks
        codeLines.add('');
        currentIndex++;
      } else {
        break;
      }
    }

    if (codeLines.isNotEmpty) {
      final codeContent = codeLines.join('\n');
      final widget = _buildCodeBlock(codeContent, '');
      return (widget: widget, nextLineIndex: currentIndex);
    }

    return null;
  }

  Widget _buildCodeBlock(String content, String language) {
    final customWidget = builder.codeBlock?.call(content, language);
    if (customWidget != null) {
      return customWidget;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(4),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(
          content,
          style:
              style.codeBlock?.call(content) ??
              const TextStyle(fontFamily: 'monospace', fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildBlockquote(String content) {
    final processedContent = _parseLineAsRichText(content);
    final customWidget = builder.blockquote?.call(content);
    if (customWidget != null) {
      return customWidget;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8, right: 8),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: Colors.grey.shade400, width: 4)),
        color: Colors.grey.shade100,
      ),
      child: Text.rich(
        processedContent,
        style:
            style.blockquote?.call(content) ??
            TextStyle(color: Colors.grey.shade700, fontStyle: FontStyle.italic),
        textAlign: textAlign,
      ),
    );
  }

  Widget _buildHeader(int level, String content) {
    final processedContent = _parseLineAsRichText(content);

    switch (level) {
      case 1:
        final customWidget = builder.h1?.call(content);
        if (customWidget != null) return customWidget;
        return Text.rich(
          processedContent,
          style: style.h1?.call(content),
          textAlign: textAlign,
        );
      case 2:
        final customWidget = builder.h2?.call(content);
        if (customWidget != null) return customWidget;
        return Text.rich(
          processedContent,
          style: style.h2?.call(content),
          textAlign: textAlign,
        );
      case 3:
        final customWidget = builder.h3?.call(content);
        if (customWidget != null) return customWidget;
        return Text.rich(
          processedContent,
          style: style.h3?.call(content),
          textAlign: textAlign,
        );
      case 4:
        final customWidget = builder.h4?.call(content);
        if (customWidget != null) return customWidget;
        return Text.rich(
          processedContent,
          style: style.h4?.call(content),
          textAlign: textAlign,
        );
      case 5:
        final customWidget = builder.h5?.call(content);
        if (customWidget != null) return customWidget;
        return Text.rich(
          processedContent,
          style: style.h5?.call(content),
          textAlign: textAlign,
        );
      case 6:
        final customWidget = builder.h6?.call(content);
        if (customWidget != null) return customWidget;
        return Text.rich(
          processedContent,
          style: style.h6?.call(content),
          textAlign: textAlign,
        );
      default:
        final customWidget = builder.h1?.call(content);
        if (customWidget != null) return customWidget;
        return Text.rich(
          processedContent,
          style: style.h1?.call(content),
          textAlign: textAlign,
        );
    }
  }

  Widget _buildUnorderedList(String content, int indent) {
    final processedContent = _parseLineAsRichText(content);
    final customWidget = builder.unorderedList?.call(content);
    if (customWidget != null) return customWidget;

    return Padding(
      padding: EdgeInsets.only(left: indent * 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text.rich(
              processedContent,
              style: style.listItem?.call(content),
              textAlign: textAlign,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderedList(String content, int indent) {
    final currentCounter = _orderedListCounter;
    final processedContent = _parseLineAsRichText(content);
    final customWidget = builder.orderedList?.call(content, currentCounter);
    if (customWidget != null) return customWidget;

    return Padding(
      padding: EdgeInsets.only(left: indent * 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$currentCounter. ', style: style.listItem?.call(content)),
          Expanded(
            child: Text.rich(
              processedContent,
              style: style.listItem?.call(content),
              textAlign: textAlign,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalRule() {
    final customWidget = builder.horizontalRule?.call();
    if (customWidget != null) return customWidget;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Divider(height: 1, thickness: 1, color: Colors.grey.shade400),
    );
  }

  ({Widget widget, int nextLineIndex})? _parseTable(
    List<String> lines,
    int startIndex,
  ) {
    if (startIndex >= lines.length) return null;

    final headerLine = lines[startIndex];
    if (!headerLine.contains('|')) return null;

    if (startIndex + 1 >= lines.length) return null;
    final separatorLine = lines[startIndex + 1];
    if (!_tableSeparatorPattern.hasMatch(separatorLine)) return null;

    final rows = <TableRow>[];

    // Process header row
    final headerCells = _parseTableCells(headerLine);
    if (headerCells.isEmpty) return null;

    // Track the expected column count from header
    final columnCount = headerCells.length;

    final headerRow = TableRow(
      children: headerCells.map((cell) {
        final cellBuilder = builder.tableCell?.call(cell.trim());
        if (cellBuilder != null) return cellBuilder;
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(cell.trim(), style: style.tableHeader?.call(cell.trim())),
        );
      }).toList(),
    );
    rows.add(headerRow);

    int currentIndex = startIndex + 2;

    while (currentIndex < lines.length) {
      final line = lines[currentIndex];

      if (!line.contains('|') || _tableSeparatorPattern.hasMatch(line)) {
        break;
      }

      final dataCells = _parseTableCells(line);
      if (dataCells.isEmpty) break;

      // Normalize cell count to match column count
      final normalizedCells = _normalizeCells(dataCells, columnCount);

      final dataRow = TableRow(
        children: normalizedCells.map((cell) {
          final cellBuilder = builder.tableCell?.call(cell.trim());
          if (cellBuilder != null) return cellBuilder;
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(cell.trim(), style: style.tableCell?.call(cell.trim())),
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
      widget: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Table(
              border: style.tableBorder,
              children: rows,
              defaultColumnWidth: const IntrinsicColumnWidth(),
            ),
          ),
        ),
      ),
      nextLineIndex: currentIndex,
    );
  }

  /// Normalizes cell count to match expected column count
  /// Pads with empty strings if too few cells, truncates if too many
  List<String> _normalizeCells(List<String> cells, int expectedCount) {
    if (cells.length == expectedCount) {
      return cells;
    } else if (cells.length < expectedCount) {
      // Pad with empty cells
      return List<String>.from(cells)
        ..addAll(List<String>.filled(expectedCount - cells.length, ''));
    } else {
      // Truncate excess cells
      return cells.sublist(0, expectedCount);
    }
  }

  List<String> _parseTableCells(String line) {
    final cells = <String>[];
    final buffer = StringBuffer();
    bool inEscape = false;

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

    if (buffer.isNotEmpty) {
      cells.add(buffer.toString());
    }

    return cells.map((cell) => cell.trim()).toList();
  }

  Widget _parseLine(String line) {
    if (line.isEmpty) {
      return const SizedBox(height: 4);
    }

    final richText = _parseLineAsRichText(line);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text.rich(
        richText,
        style: style.text?.call(line),
        textAlign: textAlign ?? TextAlign.start,
      ),
    );
  }

  TextSpan _parseLineAsRichText(String line) {
    final processedLine = _processEscapedCharacters(line);
    final spans = <InlineSpan>[];
    int lastIndex = 0;

    // If there's a search query, handle highlighting
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      return _parseLineWithHighlight(processedLine, line);
    }

    // Find all inline elements
    final allMatches = <_MatchInfo>[];

    // Images (must be checked before links)
    for (final match in _imagePattern.allMatches(processedLine)) {
      allMatches.add(_MatchInfo(match, _MatchType.image));
    }

    // Links
    for (final match in _linkPattern.allMatches(processedLine)) {
      allMatches.add(_MatchInfo(match, _MatchType.link));
    }

    // Inline code (should be checked before bold/italic)
    for (final match in _inlineCodePattern.allMatches(processedLine)) {
      allMatches.add(_MatchInfo(match, _MatchType.code));
    }

    // Strikethrough
    for (final match in _strikethroughPattern.allMatches(processedLine)) {
      allMatches.add(_MatchInfo(match, _MatchType.strikethrough));
    }

    // Bold/Italic
    for (final match in _boldItalicCombinedPattern.allMatches(processedLine)) {
      allMatches.add(_MatchInfo(match, _MatchType.boldItalic));
    }

    // Sort by position and remove overlapping matches
    allMatches.sort((a, b) => a.match.start.compareTo(b.match.start));
    final nonOverlapping = _removeOverlappingMatches(allMatches);

    for (final matchInfo in nonOverlapping) {
      final match = matchInfo.match;

      if (match.start > lastIndex) {
        final text = processedLine.substring(lastIndex, match.start);
        spans.add(TextSpan(text: text, style: style.text?.call(text)));
      }

      switch (matchInfo.type) {
        case _MatchType.image:
          final alt = match.group(1) ?? '';
          final url = match.group(2) ?? '';
          spans.add(_createImageSpan(alt, url));
          break;
        case _MatchType.link:
          final text = match.group(1) ?? '';
          final url = match.group(2) ?? '';
          spans.add(_createLinkSpan(text, url));
          break;
        case _MatchType.code:
          final code = match.group(1) ?? '';
          spans.add(_createInlineCodeSpan(code));
          break;
        case _MatchType.strikethrough:
          final text = match.group(1) ?? '';
          spans.add(_createStrikethroughSpan(text));
          break;
        case _MatchType.boldItalic:
          spans.add(_processBoldItalicMatch(match));
          break;
      }

      lastIndex = match.end;
    }

    if (lastIndex < processedLine.length) {
      final text = processedLine.substring(lastIndex);
      spans.add(TextSpan(text: text, style: style.text?.call(text)));
    }

    if (spans.isEmpty) {
      spans.add(
        TextSpan(text: processedLine, style: style.text?.call(processedLine)),
      );
    }

    return TextSpan(children: spans);
  }

  TextSpan _parseLineWithHighlight(String processedLine, String originalLine) {
    final spans = <InlineSpan>[];
    int lastIndex = 0;

    // Find all inline elements first
    final allMatches = <_MatchInfo>[];

    for (final match in _imagePattern.allMatches(processedLine)) {
      allMatches.add(_MatchInfo(match, _MatchType.image));
    }
    for (final match in _linkPattern.allMatches(processedLine)) {
      allMatches.add(_MatchInfo(match, _MatchType.link));
    }
    for (final match in _inlineCodePattern.allMatches(processedLine)) {
      allMatches.add(_MatchInfo(match, _MatchType.code));
    }
    for (final match in _strikethroughPattern.allMatches(processedLine)) {
      allMatches.add(_MatchInfo(match, _MatchType.strikethrough));
    }
    for (final match in _boldItalicCombinedPattern.allMatches(processedLine)) {
      allMatches.add(_MatchInfo(match, _MatchType.boldItalic));
    }

    allMatches.sort((a, b) => a.match.start.compareTo(b.match.start));
    final nonOverlapping = _removeOverlappingMatches(allMatches);

    for (final matchInfo in nonOverlapping) {
      final match = matchInfo.match;

      if (match.start > lastIndex) {
        final text = processedLine.substring(lastIndex, match.start);
        spans.addAll(_highlightText(text, originalLine));
      }

      switch (matchInfo.type) {
        case _MatchType.image:
          final alt = match.group(1) ?? '';
          final url = match.group(2) ?? '';
          spans.add(_createImageSpan(alt, url));
        case _MatchType.link:
          final text = match.group(1) ?? '';
          final url = match.group(2) ?? '';
          spans.add(_createLinkSpan(text, url));
        case _MatchType.code:
          final code = match.group(1) ?? '';
          spans.add(_createInlineCodeSpan(code));
        case _MatchType.strikethrough:
          final text = match.group(1) ?? '';
          spans.add(_createStrikethroughSpan(text));
        case _MatchType.boldItalic:
          spans.add(_processBoldItalicMatch(match));
      }

      lastIndex = match.end;
    }

    if (lastIndex < processedLine.length) {
      final text = processedLine.substring(lastIndex);
      spans.addAll(_highlightText(text, originalLine));
    }

    if (spans.isEmpty) {
      spans.add(
        TextSpan(text: processedLine, style: style.text?.call(processedLine)),
      );
    }

    return TextSpan(children: spans);
  }

  List<InlineSpan> _highlightText(String text, String originalLine) {
    if (text.isEmpty) return [];

    final query = searchQuery!;
    final spans = <InlineSpan>[];
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();

    int lastIndex = 0;
    int index = lowerText.indexOf(lowerQuery);

    while (index != -1) {
      // Add text before highlight
      if (index > lastIndex) {
        final beforeText = text.substring(lastIndex, index);
        spans.add(
          TextSpan(text: beforeText, style: style.text?.call(originalLine)),
        );
      }

      // Add highlighted text
      final highlightedText = text.substring(index, index + query.length);
      spans.add(
        TextSpan(
          text: highlightedText,
          style: style.text
              ?.call(originalLine)
              ?.merge(
                TextStyle(
                  backgroundColor: Color(0xFFFFEB3B),
                  fontWeight: FontWeight.bold,
                ).merge(style.highlightStyle),
              ),
          // (style.highlightStyle ??
          //         const )
          //     .merge(style.text?.call(originalLine)),
        ),
      );

      lastIndex = index + query.length;
      index = lowerText.indexOf(lowerQuery, lastIndex);
    }

    // Add remaining text
    if (lastIndex < text.length) {
      final remainingText = text.substring(lastIndex);
      spans.add(
        TextSpan(text: remainingText, style: style.text?.call(originalLine)),
      );
    }

    return spans;
  }

  List<_MatchInfo> _removeOverlappingMatches(List<_MatchInfo> matches) {
    if (matches.isEmpty) return matches;

    final result = <_MatchInfo>[matches[0]];
    for (int i = 1; i < matches.length; i++) {
      final current = matches[i];
      final last = result.last;

      if (current.match.start >= last.match.end) {
        result.add(current);
      }
    }

    return result;
  }

  InlineSpan _processBoldItalicMatch(Match match) {
    // Check which group matched
    if (match.group(1) != null || match.group(2) != null) {
      // Bold+Italic (*** or ___)
      final content = match.group(1) ?? match.group(2)!;
      return _createBoldItalicSpan(content);
    } else if (match.group(3) != null || match.group(4) != null) {
      // Bold (** or __)
      final content = match.group(3) ?? match.group(4)!;
      return _createBoldSpan(content);
    } else {
      // Italic (* or _)
      final content = match.group(5) ?? match.group(6)!;
      return _createItalicSpan(content);
    }
  }

  String _processEscapedCharacters(String line) {
    final escapedPattern = RegExp(r'\\([*_\[\]()#\-+.!|`~<>\\])');
    return line.replaceAllMapped(escapedPattern, (match) => match.group(1)!);
  }

  InlineSpan _createBoldItalicSpan(String content) {
    final customWidget = builder.boldItalic?.call(content);
    if (customWidget != null) return WidgetSpan(child: customWidget);

    return TextSpan(
      text: content,
      style:
          style.boldItalic?.call(content) ??
          const TextStyle(
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
    );
  }

  InlineSpan _createBoldSpan(String content) {
    final boldBuilder = builder.bold?.call(content);
    if (boldBuilder != null) return WidgetSpan(child: boldBuilder);
    return TextSpan(text: content, style: style.bold?.call(content));
  }

  InlineSpan _createItalicSpan(String content) {
    final italicBuilder = builder.italic?.call(content);
    if (italicBuilder != null) return WidgetSpan(child: italicBuilder);
    return TextSpan(text: content, style: style.italic?.call(content));
  }

  InlineSpan _createStrikethroughSpan(String content) {
    final customWidget = builder.strikethrough?.call(content);
    if (customWidget != null) return WidgetSpan(child: customWidget);

    return TextSpan(
      text: content,
      style:
          style.strikethrough?.call(content) ??
          const TextStyle(decoration: TextDecoration.lineThrough),
    );
  }

  InlineSpan _createInlineCodeSpan(String code) {
    final customWidget = builder.inlineCode?.call(code);
    if (customWidget != null) return WidgetSpan(child: customWidget);

    return TextSpan(
      text: code,
      style:
          style.inlineCode?.call(code) ??
          TextStyle(
            fontFamily: 'monospace',
            backgroundColor: Colors.grey.shade200,
            fontSize: 14,
          ),
    );
  }

  InlineSpan _createLinkSpan(String text, String url) {
    final linkBuilder = builder.link?.call(text, url);
    if (linkBuilder != null) return WidgetSpan(child: linkBuilder);

    return TextSpan(
      text: text,
      style: style.link?.call(text),
      recognizer: TapGestureRecognizer()..onTap = () => _launchUrlSafely(url),
    );
  }

  InlineSpan _createImageSpan(String alt, String url) {
    final imageBuilder = builder.image?.call(alt, url);
    if (imageBuilder != null) return WidgetSpan(child: imageBuilder);

    return WidgetSpan(child: Text(alt));
    // return WidgetSpan(
    //   child: Image.network(
    //     url,
    //     errorBuilder: (context, error, stackTrace) => Text('[$alt]'),
    //     loadingBuilder: (context, child, loadingProgress) {
    //       if (loadingProgress == null) return child;
    //       return const SizedBox(
    //         width: 20,
    //         height: 20,
    //         child: CircularProgressIndicator(strokeWidth: 2),
    //       );
    //     },
    //   ),
    // );
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

enum _MatchType { image, link, code, strikethrough, boldItalic }

class _MatchInfo {
  final Match match;
  final _MatchType type;

  _MatchInfo(this.match, this.type);
}
