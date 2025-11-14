# Markdown Widget for Flutter

A high-performance Flutter package for parsing and rendering Markdown with extensive customization options. This package provides both standard and lazy-loading widgets optimized for documents of any size.

## Features

✨ **Comprehensive Markdown Support**
- Headers (H1-H6)
- Bold, italic, strikethrough text
- Inline code and code blocks
- Links with tap handling
- Lists (ordered and unordered)
- Tables
- Blockquotes
- Horizontal rules

🎨 **Extensive Styling**
- Style **normal text** (new feature!)
- Customize every markdown element independently
- Theme-aware default styles
- Support for custom decorations

🚀 **Performance Optimized**
- `Markdown` widget for small to medium documents
- `MarkdownViewport` with lazy loading for large documents
- Efficient regex-based parsing
- Minimal widget rebuilds

🛠️ **Custom Builders**
- Replace any markdown element with custom widgets
- Full control over rendering
- Easy integration with your app's design system

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  markdown: ^0.0.1
```

Then run:

```bash
flutter pub get
```

## Basic Usage

### Simple Markdown Rendering

```dart
import 'package:markdown/markdown.dart';

Markdown(
  data: '# Hello World\nThis is **bold** text',
)
```

### With Custom Styling (Including Normal Text!)

```dart
Markdown(
  data: myMarkdownString,
  style: MarkdownStyle(
    // NEW: Style normal text that doesn't belong to any category!
    text: TextStyle(fontSize: 16, height: 1.6),
    
    // Headers
    h1: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    h2: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
    
    // Inline formatting
    bold: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
    italic: TextStyle(fontStyle: FontStyle.italic),
    
    // Links
    link: TextStyle(color: Colors.purple, decoration: TextDecoration.underline),
    
    // Code
    inlineCode: TextStyle(
      backgroundColor: Colors.grey.shade200,
      fontFamily: 'monospace',
    ),
  ),
)
```

### Large Documents with Lazy Loading

For documents with hundreds or thousands of lines, use `MarkdownViewport` for better performance:

```dart
MarkdownViewport(
  data: largeMarkdownDocument,
  style: MarkdownStyle(
    text: TextStyle(fontSize: 16),
  ),
  padding: EdgeInsets.all(16),
)
```

### Custom Widget Builders

Replace any markdown element with completely custom widgets:

```dart
Markdown(
  data: myMarkdownString,
  builder: MarkdownBuilder(
    // Custom header rendering
    h1: (text) => Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blue, Colors.purple]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: TextStyle(fontSize: 28, color: Colors.white)),
    ),
    
    // Custom code block with syntax highlighting
    codeBlock: (code, language) => MyCustomCodeBlock(
      code: code,
      language: language,
    ),
    
    // Custom link handling
    link: (text, url) => InkWell(
      onTap: () => handleCustomLink(url),
      child: Text(text, style: TextStyle(color: Colors.blue)),
    ),
  ),
)
```

## API Reference

### Markdown Widget

Main widget for rendering markdown content.

**Properties:**
- `data` (String, required) - The markdown string to render
- `style` (MarkdownStyle?) - Custom styles for markdown elements
- `builder` (MarkdownBuilder?) - Custom widget builders
- `textAlign` (TextAlign?) - Text alignment for all elements
- `shrinkWrap` (bool) - Wrap content in SingleChildScrollView
- `physics` (ScrollPhysics?) - Scroll physics when shrinkWrap is true
- `padding` (EdgeInsets?) - Padding around content

### MarkdownViewport Widget

Performance-optimized widget for large documents with lazy loading.

**Properties:**
- `data` (String, required) - The markdown string to render
- `style` (MarkdownStyle?) - Custom styles for markdown elements
- `builder` (MarkdownBuilder?) - Custom widget builders
- `textAlign` (TextAlign?) - Text alignment for all elements
- `physics` (ScrollPhysics?) - Scroll physics
- `controller` (ScrollController?) - Scroll controller
- `padding` (EdgeInsets?) - Padding around content

### MarkdownStyle

Defines styling for all markdown elements.

**Properties:**
- `text` - Style for normal text (NEW!)
- `h1`, `h2`, `h3`, `h4`, `h5`, `h6` - Header styles
- `bold`, `italic`, `boldItalic` - Inline formatting styles
- `strikethrough` - Strikethrough text style
- `inlineCode` - Inline code style
- `codeBlock` - Code block text style
- `blockquote` - Blockquote text style
- `link` - Link text style
- `listItem` - List item style
- `tableHeader`, `tableCell` - Table styles
- `tableBorder` - Table border style
- `codeBlockDecoration` - Code block container decoration
- `blockquoteDecoration` - Blockquote container decoration

### MarkdownBuilder

Custom widget builders for complete control over rendering.

**Properties:**
- `h1`, `h2`, `h3`, `h4`, `h5`, `h6` - Header builders
- `bold`, `italic`, `boldItalic` - Inline formatting builders
- `strikethrough` - Strikethrough builder
- `inlineCode` - Inline code builder
- `codeBlock` - Code block builder
- `blockquote` - Blockquote builder
- `link` - Link builder
- `unorderedList`, `orderedList` - List item builders
- `horizontalRule` - Horizontal rule builder
- `table`, `tableRow`, `tableCell` - Table builders
- `image` - Image builder

## What's New in This Version

### Key Improvements

1. **Normal Text Styling** - You can now style text that doesn't belong to any special category (bold, italic, headers, etc.)

2. **Simplified API** - Removed unnecessary function-based styling. Now uses direct `TextStyle` objects for cleaner, more intuitive API.

3. **Better Default Styles** - Theme-aware defaults that look great out of the box and adapt to Material 3.

4. **Custom Decorations** - Add custom `BoxDecoration` to code blocks and blockquotes for complete visual control.

5. **Cleaner Code** - Removed unsafe null handling patterns and unnecessary complexity.

6. **Better Performance** - Optimized parsing and widget building.

## Supported Markdown Syntax

| Syntax | Example | Notes |
|--------|---------|-------|
| Headers | `# H1` to `###### H6` | All six levels supported |
| Bold | `**bold**` or `__bold__` | Both syntaxes work |
| Italic | `*italic*` or `_italic_` | Both syntaxes work |
| Bold+Italic | `***text***` | Combined formatting |
| Strikethrough | `~~text~~` | |
| Inline Code | `` `code` `` | |
| Code Block | ` ```language ` | Fenced code blocks |
| Link | `[text](url)` | Clickable links |
| Image | `![alt](url)` | Via custom builder |
| Unordered List | `* item` or `- item` | |
| Ordered List | `1. item` | Auto-numbering |
| Blockquote | `> quote` | |
| Horizontal Rule | `---` or `***` | |
| Table | Pipe-separated | With header row |

## Example

Check out the comprehensive example in the `/example` folder which demonstrates:
- Basic markdown rendering
- Custom styling (including normal text)
- Custom widget builders
- Large document performance with `MarkdownViewport`

Run the example:

```bash
cd example
flutter run
```

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## License

This package is available under the MIT License.