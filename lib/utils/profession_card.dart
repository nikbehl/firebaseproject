import 'package:firebaseproject/controllers/profession_controller.dart';
import 'package:firebaseproject/screens/tech_category_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfessionCard extends StatelessWidget {
  final String title;
  final String status;
  final IconData icon;
  final Color color;

  const ProfessionCard({
    super.key,
    required this.title,
    required this.status,
    required this.icon,
    required this.color,
    required Future<Null> Function() onTap,
  });

  @override
  Widget build(BuildContext context) {
    final professionController = Get.find<ProfessionController>();

    return Card(
      elevation: 4,
      child: InkWell(
        onTap: status == 'Available'
            ? () {
                // Set the selected profession in the controller
                professionController.setSelectedProfession(title);

                // Navigate to categories screen
                Get.to(() => TechnologyCategoriesScreen(profession: title));
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
