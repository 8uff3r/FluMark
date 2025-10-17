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
  });

  final Widget? Function(String text)? h1;
  final Widget? Function(String text)? h2;
  final Widget? Function(String text)? h3;
  final Widget? Function(String text)? h4;
  final Widget? Function(String text)? h5;
  final Widget? Function(String text)? h6;
  final Widget? Function(String text)? bold;
  final Widget? Function(String text)? italic;
}
