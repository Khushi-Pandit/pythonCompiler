import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const PythonCompilerApp());
}

class PythonCompilerApp extends StatelessWidget {
  const PythonCompilerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Interactive Python Compiler',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const PythonCompilerScreen(),
    );
  }
}

class PythonCompilerScreen extends StatefulWidget {
  const PythonCompilerScreen({Key? key}) : super(key: key);

  @override
  _PythonCompilerScreenState createState() => _PythonCompilerScreenState();
}

class _PythonCompilerScreenState extends State<PythonCompilerScreen> {
  final TextEditingController _codeController = TextEditingController();
  String _output = '';
  bool _isLoading = false;

  Future<void> _executeCode() async {
    setState(() {
      _isLoading = true;
      _output = '';
    });

    final url = Uri.parse('http://192.168.1.9:5000/execute'); // Replace with your backend URL
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'code': _codeController.text}),
    );

    setState(() {
      _isLoading = false;
      if (response.statusCode == 200) {
        _output = jsonDecode(response.body)['output'];
      } else {
        _output = 'Error: ${response.body}';
      }
    });
  }

  void _clearInputOutput() {
    setState(() {
      _codeController.clear();
      _output = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Interactive Python Compiler')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _codeController,
              maxLines: 8,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter Python Code',
                hintText: 'Write your Python code here...',
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _executeCode,
                  child: _isLoading ? const CircularProgressIndicator() : const Text('Run Code'),
                ),
                ElevatedButton(
                  onPressed: _clearInputOutput,
                  child: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Output:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(10.0),
                  color: Colors.grey[200],
                  child: Text(
                    _output,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
