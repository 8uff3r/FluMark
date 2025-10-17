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
        primarySwatch: Colors.blue,
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
  final String _largeMarkdown = _generateLargeMarkdownString();
  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Markdown Performance Demo'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Regular Markdown'),
              Tab(text: 'Viewport Markdown'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Regular markdown with shrinkWrap for performance
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Markdown(
                  data: _largeMarkdown,
                  shrinkWrap: true,
                  textAlign: TextAlign.justify,
                ),
              ),
            ),
            // Viewport markdown for lazy loading
            SizedBox(
              height: 500, // Provide a fixed height to avoid unbounded height issues
              child: MarkdownViewport(
                data: _largeMarkdown,
                textAlign: TextAlign.justify,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _generateLargeMarkdownString() {
  final buffer = StringBuffer();
  
  // Add headers
  buffer.writeln('# Markdown Performance Demo');
  buffer.writeln('This demonstrates the performance improvements of the enhanced markdown parser.');
  buffer.writeln();
  
  for (int i = 0; i < 100; i++) {
    buffer.writeln('## Section $i');
    buffer.writeln('This is section $i with some content to demonstrate performance.');
    buffer.writeln();
    
    // Add some lists
    buffer.writeln('* Item ${i * 3 + 1}');
    buffer.writeln('* Item ${i * 3 + 2}');
    buffer.writeln('* Item ${i * 3 + 3}');
    buffer.writeln();
    
    // Add some bold and italic text
    buffer.writeln('This text has **bold** and *italic* formatting.');
    buffer.writeln();
    
    // Add some links occasionally
    if (i % 10 == 0) {
      buffer.writeln('[Link to example $i](https://example.com/$i)');
      buffer.writeln();
    }
  }
  
  // Add a table
  buffer.writeln('| Header 1 | Header 2 | Header 3 |');
  buffer.writeln('|----------|----------|----------|');
  for (int i = 0; i < 20; i++) {
    buffer.writeln('| Cell $i.1 | Cell $i.2 | Cell $i.3 |');
  }
  buffer.writeln();
  
  buffer.writeln('## Performance Comparison');
  buffer.writeln('This demo shows two approaches to rendering large markdown content:');
  buffer.writeln();
  buffer.writeln('* **Regular Markdown**: Renders all content at once');
  buffer.writeln('* **Viewport Markdown**: Renders content lazily as you scroll');
  buffer.writeln();
  buffer.writeln('The Viewport version is more efficient for large documents as it only builds widgets that are visible on screen.');
  
  return buffer.toString();
}