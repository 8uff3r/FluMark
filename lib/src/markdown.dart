import 'package:flutter/material.dart';
import 'package:markdown/src/builder.dart';
import 'package:markdown/src/parser.dart';
import 'package:markdown/src/style.dart';

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
  });

  final String data;
  final MarkdownStyle? style;
  final TextStyle? globalStyle;
  final MarkdownBuilder? builder;
  final TextAlign? textAlign;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    final defaultStyle = Theme.of(context).textTheme;
    final mdStyle = MarkdownStyle(
      h1: defaultStyle.headlineMedium?.merge(globalStyle).merge(style?.h1),
      h2: defaultStyle.headlineSmall?.merge(globalStyle).merge(style?.h2),
      h3: defaultStyle.titleLarge?.merge(globalStyle).merge(style?.h3),
      h4: defaultStyle.titleMedium?.merge(globalStyle).merge(style?.h4),
      h5: defaultStyle.titleSmall?.merge(globalStyle).merge(style?.h5),
      h6: defaultStyle.bodyLarge?.merge(globalStyle).merge(style?.h6),
      bold: TextStyle(
        fontWeight: FontWeight.bold,
      ).merge(globalStyle).merge(style?.bold),
      italic: const TextStyle(
        fontStyle: FontStyle.italic,
      ).merge(globalStyle).merge(style?.italic),
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

    final parser = MarkdownParser(
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
