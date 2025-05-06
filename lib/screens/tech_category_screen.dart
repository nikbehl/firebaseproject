import 'package:firebaseproject/controllers/category_controller.dart';
import 'package:firebaseproject/controllers/profession_controller.dart';
import 'package:firebaseproject/screens/prompt_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TechnologyCategoriesScreen extends StatelessWidget {
  final String profession;

  const TechnologyCategoriesScreen({super.key, required this.profession});

  @override
  Widget build(BuildContext context) {
    // Get the controllers
    final categoryController = Get.find<CategoryController>();

    // Load categories based on profession
    categoryController.loadCategories(profession);

    return Scaffold(
      appBar: AppBar(
        title: Text('$profession - Categories'),
      ),
      body: Obx(() => ListView.builder(
            itemCount: categoryController.categories.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(categoryController.categories[index]),
                onTap: () {
                  // Set the selected category
                  categoryController.setSelectedCategory(
                      categoryController.categories[index]);

                  // Navigate to prompt screen
                  Get.to(() => PromptScreen(
                        profession: profession,
                        category: categoryController.categories[index],
                      ));
                },
              );
            },
          )),
    );
  }
}
