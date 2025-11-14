import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart';

void main() {
  runApp(const MarkdownDemoApp());
}

class MarkdownDemoApp extends StatelessWidget {
  const MarkdownDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Markdown Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MarkdownDemoScreen(),
    );
  }
}

class MarkdownDemoScreen extends StatefulWidget {
  const MarkdownDemoScreen({super.key});

  @override
  State<MarkdownDemoScreen> createState() => _MarkdownDemoScreenState();
}

class _MarkdownDemoScreenState extends State<MarkdownDemoScreen> {
  double _fontSize = 16.0;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Markdown Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: () =>
                setState(() => _fontSize = (_fontSize - 2).clamp(10, 30)),
          ),
          Text('${_fontSize.toInt()}px'),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () =>
                setState(() => _fontSize = (_fontSize + 2).clamp(10, 30)),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search in markdown...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Markdown(
                data: _markdownContent,
                shrinkWrap: true,
                // Global style affects ALL text elements (normal, bold, italic, headers, etc.)
                globalStyle: TextStyle(fontSize: _fontSize),
                // Search query for highlighting
                searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
                style: MarkdownStyle(
                  // Content-aware styling for normal text
                  text: (content) {
                    if (content.startsWith('Answer:')) {
                      return TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      );
                    } else if (content.startsWith('Question:')) {
                      return TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      );
                    } else if (content.startsWith('Note:')) {
                      return TextStyle(
                        color: Colors.orange.shade700,
                        fontStyle: FontStyle.italic,
                      );
                    }
                    return const TextStyle(color: Colors.black87);
                  },
                  // Content-aware header styling
                  h1: (content) {
                    if (content.contains('Important')) {
                      return const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      );
                    }
                    return const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    );
                  },
                  h2: (content) => const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                  // Content-aware bold styling
                  bold: (content) {
                    if (content.toLowerCase() == 'warning') {
                      return const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      );
                    }
                    return const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    );
                  },
                  // Regular styling
                  italic: (content) => const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.purple,
                  ),
                  link: (content) => const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                  inlineCode: (content) => TextStyle(
                    fontFamily: 'monospace',
                    backgroundColor: Colors.grey.shade200,
                    color: Colors.teal.shade800,
                  ),
                  codeBlockDecoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  // Custom highlight style for search results
                  highlightStyle: const TextStyle(
                    backgroundColor: Color(0xFFFFD54F),
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const String _markdownContent = '''
# Important: Content-Aware Styling Demo

Use the +/- buttons to change the **global font size** for ALL text.

Try searching for words like "Question", "Answer", "styling", or "WARNING" in the search box above!

## What is Content-Aware Styling?

Content-aware styling allows you to change the appearance of text based on its content!

Question: How does it work?

Answer: The style functions receive the text content as a parameter, so you can use if statements to style differently based on what the text says!

Note: This is super useful for chat interfaces, Q&A systems, and more.

## Examples

This is normal text.

Question: Can I style based on keywords?

Answer: Yes! Notice how lines starting with "Question:" and "Answer:" have different colors.

This paragraph has **bold** text and *italic* text. Notice the bold text is colored.

This paragraph has a **WARNING** in it. Notice how "WARNING" is red because of content-aware styling!

## Features

* Normal text that starts with "Question:" is blue
* Normal text that starts with "Answer:" is green
* Normal text that starts with "Note:" is orange and italic
* Headers containing "Important" are red
* Bold text that says "WARNING" is red
* Everything else uses default styling

## Code Example

Here's how to use it:

```dart
MarkdownStyle(
  text: (content) {
    if (content.startsWith('Answer:')) {
      return TextStyle(color: Colors.green);
    }
    return TextStyle(color: Colors.black);
  },
)
```

## Links

Check out [Flutter](https://flutter.dev) for more information.

---

Try adjusting the font size with the buttons above. The **globalStyle** affects all text elements uniformly while preserving the custom styling!
''';
