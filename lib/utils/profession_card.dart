import 'package:firebaseproject/main.dart';
import 'package:flutter/material.dart';

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
