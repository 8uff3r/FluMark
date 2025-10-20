import 'package:flutter/material.dart';

class MarkdownBuilder {
  const MarkdownBuilder({
    this.h1,
    this.h2,
    this.h3,
    this.h4,
    this.h5,
    this.h6,
    this.bold,
    this.italic,
    this.boldItalic,
    this.strikethrough,
    this.inlineCode,
    this.codeBlock,
    this.blockquote,
    this.unorderedList,
    this.horizontalRule,
    this.orderedList,
    this.link,
    this.table,
    this.tableRow,
    this.tableCell,
    this.image,
  });

  final Widget? Function(String text)? h1;
  final Widget? Function(String text)? h2;
  final Widget? Function(String text)? h3;
  final Widget? Function(String text)? h4;
  final Widget? Function(String text)? h5;
  final Widget? Function(String text)? h6;
  final Widget? Function()? horizontalRule;
  final Widget? Function(String text)? bold;
  final Widget? Function(String text)? italic;
  final Widget? Function(String text)? boldItalic;
  final Widget? Function(String text)? strikethrough;
  final Widget? Function(String text)? inlineCode;
  final Widget? Function(String text, String language)? codeBlock;
  final Widget? Function(String text)? blockquote;
  final Widget? Function(String text)? unorderedList;
  final Widget? Function(String text, int number)? orderedList;
  final Widget? Function(String text, String url)? link;
  final Widget? Function(List<TableRow> rows)? table;
  final TableRow? Function(List<Widget> cells)? tableRow;
  final Widget? Function(String text)? tableCell;
  final Widget? Function(String alt, String url)? image;
}
