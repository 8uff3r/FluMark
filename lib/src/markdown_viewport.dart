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
    if (oldWidget.data != widget.data) {
      _parseMarkdownElements();
    }
  }

  void _parseMarkdownElements() {
    if (!mounted) return;

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

    final parser = MarkdownParser(
      data: widget.data,
      style: mdStyle,
      builder: widget.builder ?? const MarkdownBuilder(),
      textAlign: widget.textAlign,
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

    return CustomScrollView(
      controller: widget.controller,
      physics: widget.physics,
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _widgets![index],
            childCount: _widgets!.length,
          ),
        ),
      ],
    );
  }
}
