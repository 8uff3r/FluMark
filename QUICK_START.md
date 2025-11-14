# Quick Start Guide

Get started with the Flutter Markdown package in under 5 minutes!

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  markdown: ^0.0.1
```

Run:
```bash
flutter pub get
```

## Basic Usage

### 1. Import the package

```dart
import 'package:markdown/markdown.dart';
```

### 2. Use the Markdown widget

```dart
Markdown(
  data: '''
# Hello World
This is **bold** and this is *italic*.

## Features
- Easy to use
- Fast rendering
- Highly customizable
  ''',
)
```

That's it! You now have markdown rendering in your Flutter app.

## Style Normal Text (New Feature!)

One of the biggest improvements is the ability to style normal text:

```dart
Markdown(
  data: 'Regular text with **bold** words',
  style: MarkdownStyle(
    text: TextStyle(
      fontSize: 16,
      height: 1.6,
      color: Colors.grey.shade800,
    ),
  ),
)
```

## Common Use Cases

### Custom Header Colors

```dart
Markdown(
  data: '# Title\n## Subtitle',
  style: MarkdownStyle(
    h1: TextStyle(fontSize: 32, color: Colors.blue),
    h2: TextStyle(fontSize: 24, color: Colors.green),
  ),
)
```

### Styled Links

```dart
Markdown(
  data: 'Visit [Flutter](https://flutter.dev)',
  style: MarkdownStyle(
    link: TextStyle(
      color: Colors.purple,
      decoration: TextDecoration.underline,
    ),
  ),
)
```

### Custom Code Blocks

```dart
Markdown(
  data: '```dart\nvoid main() {}\n```',
  style: MarkdownStyle(
    codeBlock: TextStyle(
      fontFamily: 'monospace',
      color: Colors.green,
    ),
    codeBlockDecoration: BoxDecoration(
      color: Colors.black87,
      borderRadius: BorderRadius.circular(8),
    ),
  ),
)
```

## Large Documents

For documents with hundreds of sections, use `MarkdownViewport` for better performance:

```dart
MarkdownViewport(
  data: veryLargeMarkdownString,
  style: MarkdownStyle(
    text: TextStyle(fontSize: 16),
  ),
  padding: EdgeInsets.all(16),
)
```

## Custom Widgets

Replace any element with your own widget:

```dart
Markdown(
  data: '# Custom Header',
  builder: MarkdownBuilder(
    h1: (text) => Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.purple],
        ),
      ),
      child: Text(text, style: TextStyle(color: Colors.white)),
    ),
  ),
)
```

## All Styling Options

```dart
MarkdownStyle(
  // NEW: Style normal text!
  text: TextStyle(...),
  
  // Headers
  h1: TextStyle(...),
  h2: TextStyle(...),
  h3: TextStyle(...),
  
  // Inline formatting
  bold: TextStyle(...),
  italic: TextStyle(...),
  strikethrough: TextStyle(...),
  
  // Code
  inlineCode: TextStyle(...),
  codeBlock: TextStyle(...),
  codeBlockDecoration: BoxDecoration(...),
  
  // Quotes
  blockquote: TextStyle(...),
  blockquoteDecoration: BoxDecoration(...),
  
  // Links & Lists
  link: TextStyle(...),
  listItem: TextStyle(...),
  
  // Tables
  tableHeader: TextStyle(...),
  tableCell: TextStyle(...),
  tableBorder: TableBorder(...),
)
```

## Tips

1. **Theme Integration**: Default styles automatically adapt to your app's theme
2. **Scrolling**: Use `shrinkWrap: true` for Markdown inside ScrollViews
3. **Performance**: Use `MarkdownViewport` for documents over 1000 lines
4. **Padding**: Add padding with the `padding` parameter
5. **Alignment**: Set text alignment with `textAlign` parameter

## Next Steps

- Check out the [full example app](example/) for comprehensive demos
- Read the [complete API documentation](README.md)
- See [CHANGELOG.md](CHANGELOG.md) for migration guide

## Common Patterns

### Scrollable Content

```dart
SingleChildScrollView(
  child: Markdown(
    data: myMarkdown,
    shrinkWrap: true,
  ),
)
```

### With Custom Padding

```dart
Markdown(
  data: myMarkdown,
  padding: EdgeInsets.all(16),
)
```

### Inside a Card

```dart
Card(
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Markdown(data: myMarkdown),
  ),
)
```

## Need Help?

- Check the [README](README.md) for detailed documentation
- Look at [examples](example/lib/main.dart) for more use cases
- Review [IMPROVEMENTS.md](IMPROVEMENTS.md) to see what's new

Happy Markdown rendering! 🚀