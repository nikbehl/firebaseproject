import 'dart:convert';

import 'package:firebaseproject/screens/data_display_screen.dart';
import 'package:firebaseproject/screens/prompt_screen.dart';
import 'package:firebaseproject/utils/profession_card.dart';
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
