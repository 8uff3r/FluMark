import 'package:flutter/material.dart';
import 'package:markdown/src/builder.dart';
import 'package:markdown/src/parser.dart';
import 'package:markdown/src/style.dart';

/// A performance-optimized markdown widget that renders content lazily
/// as the user scrolls, making it suitable for very large markdown documents.
///
/// This widget uses [CustomScrollView] with [SliverList] to render content on-demand,
/// significantly improving performance for large documents by only building widgets that are visible.
///
/// This widget works both in bounded and unbounded contexts, making it suitable for use
/// inside [Flexible], [Expanded], or with fixed dimensions.
class MarkdownViewport extends StatefulWidget {
  const MarkdownViewport({
    super.key,
    required this.data,
    this.style,
    this.globalStyle,
    this.builder,
    this.textAlign,
    this.physics,
    this.controller,
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

  /// Scroll physics for the viewport
  final ScrollPhysics? physics;

  /// Scroll controller for programmatic scrolling
  final ScrollController? controller;

  /// Padding around the markdown content
  final EdgeInsets? padding;

  /// Search query to highlight in the markdown content
  final String? searchQuery;

  @override
  State<MarkdownViewport> createState() => _MarkdownViewportState();
}

class _MarkdownViewportState extends State<MarkdownViewport> {
  List<Widget>? _widgets;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_widgets == null) {
      _parseMarkdownElements();
    }
  }

  @override
  void didUpdateWidget(MarkdownViewport oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data ||
        oldWidget.style != widget.style ||
        oldWidget.globalStyle != widget.globalStyle ||
        oldWidget.builder != widget.builder ||
        oldWidget.searchQuery != widget.searchQuery) {
      _parseMarkdownElements();
    }
  }

  void _parseMarkdownElements() {
    if (!mounted) return;

    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    // Build default style with content-aware functions
    final defaultStyle = MarkdownStyle(
      text: (content) => textTheme.bodyMedium?.merge(widget.globalStyle),
      h1: (content) => textTheme.headlineMedium
          ?.copyWith(fontWeight: FontWeight.bold)
          .merge(widget.globalStyle)
          .merge(widget.style?.h1?.call(content)),
      h2: (content) => textTheme.headlineSmall
          ?.copyWith(fontWeight: FontWeight.bold)
          .merge(widget.globalStyle)
          .merge(widget.style?.h2?.call(content)),
      h3: (content) => textTheme.titleLarge
          ?.copyWith(fontWeight: FontWeight.bold)
          .merge(widget.globalStyle)
          .merge(widget.style?.h3?.call(content)),
      h4: (content) => textTheme.titleMedium
          ?.copyWith(fontWeight: FontWeight.w600)
          .merge(widget.globalStyle)
          .merge(widget.style?.h4?.call(content)),
      h5: (content) => textTheme.titleSmall
          ?.copyWith(fontWeight: FontWeight.w600)
          .merge(widget.globalStyle)
          .merge(widget.style?.h5?.call(content)),
      h6: (content) => textTheme.bodyLarge
          ?.copyWith(fontWeight: FontWeight.w600)
          .merge(widget.globalStyle)
          .merge(widget.style?.h6?.call(content)),
      bold: (content) => const TextStyle(
        fontWeight: FontWeight.bold,
      ).merge(widget.globalStyle).merge(widget.style?.bold?.call(content)),
      italic: (content) => const TextStyle(
        fontStyle: FontStyle.italic,
      ).merge(widget.globalStyle).merge(widget.style?.italic?.call(content)),
      boldItalic: (content) =>
          const TextStyle(
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              )
              .merge(widget.globalStyle)
              .merge(widget.style?.boldItalic?.call(content)),
      strikethrough: (content) =>
          const TextStyle(decoration: TextDecoration.lineThrough)
              .merge(widget.globalStyle)
              .merge(widget.style?.strikethrough?.call(content)),
      inlineCode: (content) =>
          TextStyle(
                fontFamily: 'monospace',
                fontSize: (widget.globalStyle?.fontSize ?? 14) * 0.9,
                backgroundColor: colorScheme.surfaceContainerHighest
                    .withOpacity(0.3),
              )
              .merge(widget.globalStyle)
              .merge(widget.style?.inlineCode?.call(content)),
      codeBlock: (content) => TextStyle(
        fontFamily: 'monospace',
        fontSize: (widget.globalStyle?.fontSize ?? 14) * 0.9,
      ).merge(widget.globalStyle).merge(widget.style?.codeBlock?.call(content)),
      blockquote: (content) =>
          TextStyle(
                color: colorScheme.onSurface.withOpacity(0.7),
                fontStyle: FontStyle.italic,
              )
              .merge(widget.globalStyle)
              .merge(widget.style?.blockquote?.call(content)),
      link: (content) => TextStyle(
        color: colorScheme.primary,
        decoration: TextDecoration.underline,
      ).merge(widget.globalStyle).merge(widget.style?.link?.call(content)),
      listItem: (content) => textTheme.bodyMedium
          ?.merge(widget.globalStyle)
          .merge(widget.style?.listItem?.call(content)),
      tableHeader: (content) => textTheme.bodyMedium
          ?.copyWith(fontWeight: FontWeight.bold)
          .merge(widget.globalStyle)
          .merge(widget.style?.tableHeader?.call(content)),
      tableCell: (content) => textTheme.bodyMedium
          ?.merge(widget.globalStyle)
          .merge(widget.style?.tableCell?.call(content)),
      tableBorder:
          widget.style?.tableBorder ??
          TableBorder.all(color: colorScheme.outlineVariant, width: 1),
      codeBlockDecoration:
          widget.style?.codeBlockDecoration ??
          BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: colorScheme.outlineVariant.withOpacity(0.5),
            ),
          ),
      blockquoteDecoration:
          widget.style?.blockquoteDecoration ??
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
          widget.style?.highlightStyle ??
          const TextStyle(
            backgroundColor: Color(0xFFFFEB3B),
            fontWeight: FontWeight.bold,
          ),
    );

    final parser = MarkdownParser(
      data: widget.data,
      style: defaultStyle,
      builder: widget.builder ?? const MarkdownBuilder(),
      textAlign: widget.textAlign,
      searchQuery: widget.searchQuery,
    );

    final newWidgets = parser.parse();

    if (mounted) {
      setState(() {
        _widgets = newWidgets;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_widgets == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final content = SliverPadding(
      padding: widget.padding ?? EdgeInsets.zero,
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _widgets![index],
          childCount: _widgets!.length,
        ),
      ),
    );

    return CustomScrollView(
      controller: widget.controller,
      physics: widget.physics,
      slivers: [content],
    );
  }
}
