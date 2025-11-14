import 'package:flutter/material.dart';

/// Defines the styling for different markdown elements.
///
/// Each style property is a function that receives the text content
/// and returns a TextStyle, allowing for content-aware styling.
///
/// Example:
/// ```dart
/// MarkdownStyle(
///   text: (content) {
///     if (content.startsWith('Answer:')) {
///       return TextStyle(color: Colors.green);
///     }
///     return TextStyle(color: Colors.black);
///   },
/// )
/// ```
class MarkdownStyle {
  const MarkdownStyle({
    this.text,
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
    this.link,
    this.listItem,
    this.tableHeader,
    this.tableCell,
    this.tableBorder,
    this.codeBlockDecoration,
    this.blockquoteDecoration,
    this.highlightStyle,
  });

  /// Style for highlighted search text
  final TextStyle? highlightStyle;

  /// Style for normal text that doesn't belong to any special category.
  /// Receives the text content as parameter for content-aware styling.
  final TextStyle? Function(String)? text;

  // Headers - content-aware styling
  final TextStyle? Function(String)? h1;
  final TextStyle? Function(String)? h2;
  final TextStyle? Function(String)? h3;
  final TextStyle? Function(String)? h4;
  final TextStyle? Function(String)? h5;
  final TextStyle? Function(String)? h6;

  // Inline formatting - content-aware styling
  final TextStyle? Function(String)? bold;
  final TextStyle? Function(String)? italic;
  final TextStyle? Function(String)? boldItalic;
  final TextStyle? Function(String)? strikethrough;
  final TextStyle? Function(String)? inlineCode;

  // Block elements - content-aware styling
  final TextStyle? Function(String)? codeBlock;
  final TextStyle? Function(String)? blockquote;
  final TextStyle? Function(String)? link;
  final TextStyle? Function(String)? listItem;

  // Table - content-aware styling
  final TextStyle? Function(String)? tableHeader;
  final TextStyle? Function(String)? tableCell;
  final TableBorder? tableBorder;

  // Decorations (not content-aware as they're for containers)
  final BoxDecoration? codeBlockDecoration;
  final BoxDecoration? blockquoteDecoration;
}
