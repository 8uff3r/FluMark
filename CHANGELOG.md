# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.1] - 2024-01-XX

### Added

- **Normal text styling**: Added `text` property to `MarkdownStyle` allowing users to style plain text that doesn't belong to any special category (bold, italic, headers, etc.)
- **Custom decorations**: Added `codeBlockDecoration` and `blockquoteDecoration` properties to `MarkdownStyle` for complete control over container styling
- **Padding support**: Added `padding` parameter to both `Markdown` and `MarkdownViewport` widgets
- **Theme-aware defaults**: Default styles now automatically adapt to the app's theme and Material 3 design
- **Better API documentation**: Added comprehensive documentation with examples to all public APIs
- **Comprehensive example app**: New example demonstrating:
  - Basic markdown rendering
  - Custom styling (including normal text)
  - Custom widget builders
  - Large document performance with lazy loading

### Changed

- **Simplified styling API**: Replaced function-based styling `TextStyle? Function(String)?` with direct `TextStyle?` for cleaner, more intuitive API
- **Unified list styling**: Combined `unorderedList` and `orderedList` styles into a single `listItem` style for consistency
- **Better default styles**: Improved default styling with better spacing, colors, and typography
- **Optimized parsing**: Improved line splitting and text processing for better performance
- **Cleaner code structure**: Refactored parser to eliminate code duplication and improve maintainability

### Fixed

- **Null safety**: Removed unsafe null handling patterns (force unwraps with `!`)
- **Type safety**: Fixed all type-related warnings and errors
- **Table parsing**: Improved table cell parsing with better edge case handling
- **Style merging**: Fixed style inheritance and merging logic

### Removed

- **Removed `globalStyle` parameter**: Styling is now handled through the unified `MarkdownStyle` object for simplicity
- **Removed unnecessary complexity**: Eliminated overly complex style merging logic in favor of simpler approach
- **Removed redundant checks**: Cleaned up redundant null checks and pattern matches

## Features

### Core Functionality

- ✅ Headers (H1-H6)
- ✅ Bold, italic, and combined formatting
- ✅ Strikethrough text
- ✅ Inline code and fenced code blocks
- ✅ Links with tap handling
- ✅ Ordered and unordered lists
- ✅ Tables with customizable borders
- ✅ Blockquotes
- ✅ Horizontal rules
- ✅ Escape characters
- ✅ Image placeholders (via custom builders)

### Widgets

- **Markdown**: Standard widget for small to medium documents
- **MarkdownViewport**: Lazy-loading widget optimized for large documents

### Customization

- **MarkdownStyle**: Style every element including normal text
- **MarkdownBuilder**: Replace any element with custom widgets
- Full theme integration with Material 3

## Migration Guide

If you were using an older version, here's how to migrate:

### Styling Changes

**Before:**
```dart
Markdown(
  globalStyle: TextStyle(fontSize: 16),
  style: MarkdownStyle(
    h1: (text) => TextStyle(fontSize: 32),
    bold: (text) => TextStyle(fontWeight: FontWeight.bold),
  ),
)
```

**After:**
```dart
Markdown(
  style: MarkdownStyle(
    text: TextStyle(fontSize: 16),  // Style normal text
    h1: TextStyle(fontSize: 32),
    bold: TextStyle(fontWeight: FontWeight.bold),
  ),
)
```

### List Styling

**Before:**
```dart
MarkdownStyle(
  unorderedList: (text) => TextStyle(...),
  orderedList: (text) => TextStyle(...),
)
```

**After:**
```dart
MarkdownStyle(
  listItem: TextStyle(...),  // Single style for all lists
)
```

### Decorations

**Before:**
```dart
// Code blocks and blockquotes had hardcoded styles
```

**After:**
```dart
MarkdownStyle(
  codeBlockDecoration: BoxDecoration(...),
  blockquoteDecoration: BoxDecoration(...),
)
```

## Performance

- Efficient regex-based parsing
- Lazy loading support for large documents
- Minimal widget rebuilds
- Optimized line processing

## License

MIT License - see LICENSE file for details.