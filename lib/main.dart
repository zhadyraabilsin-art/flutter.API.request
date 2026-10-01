import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const ApiBuilderApp());
}

class ApiBuilderApp extends StatelessWidget {
  const ApiBuilderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'API & cURL Builder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const ApiBuilderScreen(),
    );
  }
}

class HeaderPair {
  String key;
  String value;
  bool enabled;

  HeaderPair({required this.key, required this.value, this.enabled = true});
}

class ApiBuilderScreen extends StatefulWidget {
  const ApiBuilderScreen({super.key});

  @override
  State<ApiBuilderScreen> createState() => _ApiBuilderScreenState();
}

class _ApiBuilderScreenState extends State<ApiBuilderScreen> {
  String _method = 'POST';
  final _urlController = TextEditingController(
    text: 'https://api.github.com/repos/zhadyraabilsin-art/flutter-app',
  );
  final _bodyController = TextEditingController(
    text: '{\n  "name": "flutter-app",\n  "private": false\n}',
  );

  final List<HeaderPair> _headers = [
    HeaderPair(key: 'Content-Type', value: 'application/json'),
    HeaderPair(key: 'Authorization', value: 'Bearer YOUR_TOKEN_HERE'),
  ];

  final _newKeyController = TextEditingController();
  final _newValController = TextEditingController();

  Color _methodColor(String m) {
    switch (m) {
      case 'GET':
        return Colors.greenAccent;
      case 'POST':
        return Colors.orangeAccent;
      case 'PUT':
        return Colors.blueAccent;
      case 'DELETE':
        return Colors.redAccent;
      default:
        return Colors.white;
    }
  }

  String get _generatedCurl {
    final buffer = StringBuffer(
      'curl -X $_method "${_urlController.text.trim()}"',
    );
    for (final h in _headers.where(
      (item) => item.enabled && item.key.trim().isNotEmpty,
    )) {
      buffer.write(' \\\n  -H "${h.key.trim()}: ${h.value.trim()}"');
    }
    if ((_method == 'POST' || _method == 'PUT') &&
        _bodyController.text.trim().isNotEmpty) {
      final escapedBody = _bodyController.text.trim().replaceAll('"', '\\"');
      buffer.write(' \\\n  -d "$escapedBody"');
    }
    return buffer.toString();
  }

  void _addHeader() {
    final k = _newKeyController.text.trim();
    final v = _newValController.text.trim();
    if (k.isEmpty) return;
    setState(() {
      _headers.add(HeaderPair(key: k, value: v));
    });
    _newKeyController.clear();
    _newValController.clear();
  }

  void _copyCurl() {
    Clipboard.setData(ClipboardData(text: _generatedCurl));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('cURL command copied to clipboard!'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('API & cURL Studio'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1E29),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _methodColor(_method)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _method,
                      style: TextStyle(
                        color: _methodColor(_method),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      items: ['GET', 'POST', 'PUT', 'DELETE']
                          .map(
                            (m) => DropdownMenuItem(value: m, child: Text(m)),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _method = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Endpoint URL',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text(
              'Request Headers',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._headers.map((h) {
              return Card(
                margin: const EdgeInsets.only(bottom: 6),
                child: CheckboxListTile(
                  dense: true,
                  value: h.enabled,
                  onChanged: (val) => setState(() => h.enabled = val ?? true),
                  title: Text(
                    h.key,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                  subtitle: Text(
                    h.value,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                  secondary: IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => setState(() => _headers.remove(h)),
                  ),
                ),
              );
            }),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newKeyController,
                    decoration: const InputDecoration(
                      hintText: 'Header Key',
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _newValController,
                    decoration: const InputDecoration(
                      hintText: 'Value',
                      isDense: true,
                    ),
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: _addHeader,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            if (_method == 'POST' || _method == 'PUT') ...[
              const SizedBox(height: 18),
              const Text(
                'JSON Payload Body',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _bodyController,
                maxLines: 4,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Generated cURL Command',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                FilledButton.tonalIcon(
                  onPressed: _copyCurl,
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Copy cURL'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF10131A),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.orangeAccent.withValues(alpha: 0.35),
                ),
              ),
              child: SelectableText(
                _generatedCurl,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12.5,
                  color: Colors.orangeAccent,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
