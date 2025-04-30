import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tech Guide'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose your profession to get started',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2, // 2 columns
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1, // Adjust as needed for card height
                children: const [
                  ProfessionCard(
                    title: 'Frontend Developer',
                    status: 'Available',
                    icon: Icons.web,
                    color: Colors.green,
                  ),
                  ProfessionCard(
                    title: 'Backend Developer',
                    status: 'Available',
                    icon: Icons.storage,
                    color: Colors.green,
                  ),
                  ProfessionCard(
                    title: 'UI/UX Designer',
                    status: 'Coming Soon',
                    icon: Icons.design_services,
                    color: Colors.orange,
                  ),
                  ProfessionCard(
                    title: 'Data Scientist',
                    status: 'Coming Soon',
                    icon: Icons.analytics,
                    color: Colors.orange,
                  ),
                  ProfessionCard(
                    title: 'Mobile Developer',
                    status: 'Coming Soon',
                    icon: Icons.phone_android,
                    color: Colors.orange,
                  ),
                  ProfessionCard(
                    title: 'DevOps Engineer',
                    status: 'Coming Soon',
                    icon: Icons.settings,
                    color: Colors.orange,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'More professions coming soon!',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfessionCard extends StatelessWidget {
  final String title;
  final String status;
  final IconData icon;
  final Color color;

  const ProfessionCard(
      {super.key,
      required this.title,
      required this.status,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: status == 'Available'
            ? () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          TechnologyCategoriesScreen(profession: title),
                    ));
                print("Navigating to $title");
              }
            : null, // Disable onTap if status is not 'Available'
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 10),
              Text(title, textAlign: TextAlign.center),
              const SizedBox(height: 5),
              Text(
                status,
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TechnologyCategoriesScreen extends StatelessWidget {
  final String profession;
  const TechnologyCategoriesScreen({super.key, required this.profession});

  @override
  Widget build(BuildContext context) {
    List<String> categories = [];
    if (profession == 'Frontend Developer') {
      categories = ['HTML', 'CSS', 'JavaScript', 'Frameworks', 'Tools'];
    } else if (profession == 'Backend Developer') {
      categories = ['Node.js', 'Python', 'Databases', 'Server', 'Tools'];
    }
    // Add more professions and their categories here

    return Scaffold(
      appBar: AppBar(
        title: Text('$profession - Categories'),
      ),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(categories[index]),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PromptScreen(
                    profession: profession,
                    category: categories[index],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

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

class DataDisplayScreen extends StatefulWidget {
  final String profession;
  final String category;
  final String prompt;

  const DataDisplayScreen(
      {super.key,
      required this.profession,
      required this.category,
      required this.prompt});

  @override
  _DataDisplayScreenState createState() => _DataDisplayScreenState();
}

class _DataDisplayScreenState extends State<DataDisplayScreen> {
  String _data = 'Loading...';

  @override
  void initState() {
    super.initState();
    fetchData(
        widget.category, widget.prompt); // Corrected: Passing the arguments
  }

  // Replace with actual free chatbot API endpoint and logic
  Future<void> fetchData(String category, String prompt) async {
    final String apiKey =
        "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"; // Your API key
    const String apiUrl =
        "https://api.groq.com/openai/v1/chat/completions"; // Correct endpoint for chat completions

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey', // Correct format for Groq API key
        },
        body: jsonEncode({
          "model":
              "gemma2-9b-it", // Or another available model, refer to documentation
          "messages": [
            {"role": "user", "content": "category: $category ,prompt: $prompt"}
          ],
        }),
      );

      if (response.statusCode == 200) {
        // Successful API call
        final data = jsonDecode(response.body);
        print('API Response: $data');
        final responseMessage = data['choices'][0]['message']['content'];

        setState(() {
          _data = responseMessage;
        });
      } else if (response.statusCode == 401) {
        // Unauthorized error (API key issue)
        print('Error 401: Unauthorized - Check your API key and permissions.');
        print(response.body); // Print the error details from the server
        setState(() {
          _data =
              "Error 401: Unauthorized - Check your API key and permissions.";
        });
      } else {
        // Other errors
        print('Error ${response.statusCode}: ${response.body}');
        print(response.body); // Print the error details from the server
        setState(() {
          _data = 'Error ${response.statusCode}: ${response.body}';
        });
      }
    } catch (e) {
      print('Error during API call: $e');
      setState(() {
        _data = 'Error during API call: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.profession} - ${widget.category} - Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(child: Text(_data)),
      ),
    );
  }
}
