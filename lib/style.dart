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
  final TextStyle? unorderedList;
  final TextStyle? orderedList;
  final TextStyle? link;
  final TableBorder? tableBorder;
  final TextStyle? tableHeader;
  final TextStyle? tableCell;
}
