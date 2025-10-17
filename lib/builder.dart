import 'package:flutter/material.dart';

class MarkdownBuilder {
  MarkdownBuilder({
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
    this.table,
    this.tableRow,
    this.tableCell,
  });

  final Widget? Function(String text)? h1;
  final Widget? Function(String text)? h2;
  final Widget? Function(String text)? h3;
  final Widget? Function(String text)? h4;
  final Widget? Function(String text)? h5;
  final Widget? Function(String text)? h6;
  final Widget? Function(String text)? bold;
  final Widget? Function(String text)? italic;
  final Widget? Function(String text)? unorderedList;
  final Widget? Function(String text, int number)? orderedList;
  final Widget? Function(String text, String url)? link;
  final Widget? Function(List<TableRow> rows)? table;
  final TableRow? Function(List<Widget> cells)? tableRow;
  final Widget? Function(String text)? tableCell;
}
