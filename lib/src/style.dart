import 'package:flutter/material.dart';

class MarkdownStyle {
  const MarkdownStyle({
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
    this.orderedList,
    this.link,
    this.tableBorder,
    this.tableHeader,
    this.tableCell,
  });

  final TextStyle? h1;
  final TextStyle? h2;
  final TextStyle? h3;
  final TextStyle? h4;
  final TextStyle? h5;
  final TextStyle? h6;
  final TextStyle? bold;
  final TextStyle? italic;
  final TextStyle? boldItalic;
  final TextStyle? strikethrough;
  final TextStyle? inlineCode;
  final TextStyle? codeBlock;
  final TextStyle? blockquote;
  final TextStyle? unorderedList;
  final TextStyle? orderedList;
  final TextStyle? link;
  final TableBorder? tableBorder;
  final TextStyle? tableHeader;
  final TextStyle? tableCell;
}
