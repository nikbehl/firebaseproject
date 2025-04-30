import 'package:firebaseproject/screens/data_display_screen.dart';
import 'package:flutter/material.dart';

class PromptScreen extends StatefulWidget {
  final String profession;
  final String category;

  const PromptScreen(
      {super.key, required this.profession, required this.category});

  @override
  _PromptScreenState createState() => _PromptScreenState();
}

class _PromptScreenState extends State<PromptScreen> {
  final TextEditingController _promptController = TextEditingController();

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.profession} - ${widget.category} - Prompt'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _promptController,
              decoration: const InputDecoration(
                hintText: 'Enter your prompt here',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DataDisplayScreen(
                      profession: widget.profession,
                      category: widget.category,
                      prompt: _promptController.text,
                    ),
                  ),
                );
              },
              child: const Text('Get Data'),
            ),
          ],
        ),
      ),
    );
  }
}
