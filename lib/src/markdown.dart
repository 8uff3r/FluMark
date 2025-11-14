import 'package:flutter/material.dart';
import 'package:markdown/src/builder.dart';
import 'package:markdown/src/parser.dart';
import 'package:markdown/src/style.dart';

/// A widget that renders markdown text.
///
/// This widget is suitable for small to medium markdown documents.
/// For large documents with thousands of lines, consider using [MarkdownViewport]
/// which provides lazy loading for better performance.
class Markdown extends StatelessWidget {
  const Markdown({
    super.key,
    required this.data,
    this.style,
    this.globalStyle,
    this.builder,
    this.textAlign,
    this.shrinkWrap = false,
    this.physics,
    this.padding,
    this.searchQuery,
  });

  /// The markdown string to render
  final String data;

  /// Custom styles for markdown elements (function-based for content-aware styling)
  final MarkdownStyle? style;

  /// Global base style applied to all text elements (useful for setting base font size, etc.)
  final TextStyle? globalStyle;

  /// Custom widget builders for markdown elements
  final MarkdownBuilder? builder;

  /// Text alignment for all text elements
  final TextAlign? textAlign;

  /// Whether to wrap content in a [SingleChildScrollView]
  final bool shrinkWrap;

  /// Scroll physics when [shrinkWrap] is true
  final ScrollPhysics? physics;

  /// Padding around the markdown content
  final EdgeInsets? padding;

  /// Search query to highlight in the markdown content
  final String? searchQuery;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    // Build default style with content-aware functions
    final defaultStyle = MarkdownStyle(
      text: (content) => textTheme.bodyMedium
          ?.merge(globalStyle)
          .merge(style?.text?.call(content)),
      h1: (content) => textTheme.headlineMedium
          ?.copyWith(fontWeight: FontWeight.bold)
          .merge(globalStyle)
          .merge(style?.h1?.call(content)),
      h2: (content) => textTheme.headlineSmall
          ?.copyWith(fontWeight: FontWeight.bold)
          .merge(globalStyle)
          .merge(style?.h2?.call(content)),
      h3: (content) => textTheme.titleLarge
          ?.copyWith(fontWeight: FontWeight.bold)
          .merge(globalStyle)
          .merge(style?.h3?.call(content)),
      h4: (content) => textTheme.titleMedium
          ?.copyWith(fontWeight: FontWeight.w600)
          .merge(globalStyle)
          .merge(style?.h4?.call(content)),
      h5: (content) => textTheme.titleSmall
          ?.copyWith(fontWeight: FontWeight.w600)
          .merge(globalStyle)
          .merge(style?.h5?.call(content)),
      h6: (content) => textTheme.bodyLarge
          ?.copyWith(fontWeight: FontWeight.w600)
          .merge(globalStyle)
          .merge(style?.h6?.call(content)),
      bold: (content) => const TextStyle(
        fontWeight: FontWeight.bold,
      ).merge(globalStyle).merge(style?.bold?.call(content)),
      italic: (content) => const TextStyle(
        fontStyle: FontStyle.italic,
      ).merge(globalStyle).merge(style?.italic?.call(content)),
      boldItalic: (content) => const TextStyle(
        fontWeight: FontWeight.bold,
        fontStyle: FontStyle.italic,
      ).merge(globalStyle).merge(style?.boldItalic?.call(content)),
      strikethrough: (content) => const TextStyle(
        decoration: TextDecoration.lineThrough,
      ).merge(globalStyle).merge(style?.strikethrough?.call(content)),
      inlineCode: (content) => TextStyle(
        fontFamily: 'monospace',
        fontSize: (globalStyle?.fontSize ?? 14) * 0.9,
        backgroundColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
      ).merge(globalStyle).merge(style?.inlineCode?.call(content)),
      codeBlock: (content) => TextStyle(
        fontFamily: 'monospace',
        fontSize: (globalStyle?.fontSize ?? 14) * 0.9,
      ).merge(globalStyle).merge(style?.codeBlock?.call(content)),
      blockquote: (content) => TextStyle(
        color: colorScheme.onSurface.withOpacity(0.7),
        fontStyle: FontStyle.italic,
      ).merge(globalStyle).merge(style?.blockquote?.call(content)),
      link: (content) => TextStyle(
        color: colorScheme.primary,
        decoration: TextDecoration.underline,
      ).merge(globalStyle).merge(style?.link?.call(content)),
      listItem: (content) => textTheme.bodyMedium
          ?.merge(globalStyle)
          .merge(style?.listItem?.call(content)),
      tableHeader: (content) => textTheme.bodyMedium
          ?.copyWith(fontWeight: FontWeight.bold)
          .merge(globalStyle)
          .merge(style?.tableHeader?.call(content)),
      tableCell: (content) => textTheme.bodyMedium
          ?.merge(globalStyle)
          .merge(style?.tableCell?.call(content)),
      tableBorder:
          style?.tableBorder ??
          TableBorder.all(color: colorScheme.outlineVariant, width: 1),
      codeBlockDecoration:
          style?.codeBlockDecoration ??
          BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
      blockquoteDecoration:
          style?.blockquoteDecoration ??
          BoxDecoration(
            border: Border(
              left: BorderSide(
                color: colorScheme.primary.withOpacity(0.5),
                width: 4,
              ),
            ),
            color: colorScheme.surfaceContainerHighest.withOpacity(0.2),
          ),
      highlightStyle:
          style?.highlightStyle ??
          const TextStyle(
            backgroundColor: Color(0xFFFFEB3B),
            fontWeight: FontWeight.bold,
          ),
    );

    final parser = MarkdownParser(
      data: data,
      style: defaultStyle,
      builder: builder ?? const MarkdownBuilder(),
      textAlign: textAlign,
      searchQuery: searchQuery,
    );

    final widgets = parser.parse();

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: widgets,
    );

    final paddedContent = padding != null
        ? Padding(padding: padding!, child: content)
        : content;

    if (shrinkWrap) {
      return SingleChildScrollView(physics: physics, child: paddedContent);
    }

    return paddedContent;
  }
}
