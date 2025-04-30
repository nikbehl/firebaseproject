import 'package:firebaseproject/screens/prompt_screen.dart';
import 'package:flutter/material.dart';

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
