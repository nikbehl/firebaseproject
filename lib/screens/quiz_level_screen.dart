import 'package:firebaseproject/controllers/quiz_controller.dart';
import 'package:firebaseproject/screens/quiz_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QuizLevelScreen extends StatelessWidget {
  final String profession;
  final String category;

  const QuizLevelScreen({
    super.key,
    required this.profession,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    // Get the quiz controller
    final quizController = Get.find<QuizController>();

    // Reset quiz state when entering level selection
    quizController.resetQuiz();

    return Scaffold(
      appBar: AppBar(
        title: Text('$profession - $category Quiz'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Choose Difficulty Level',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Basic level card
            _buildLevelCard(
              context: context,
              level: 'Basic',
              description: 'Fundamental concepts and terminology',
              color: Colors.green,
              icon: Icons.school,
              onTap: () => _startQuiz(quizController, 'Basic'),
            ),

            const SizedBox(height: 16),

            // Intermediate level card
            _buildLevelCard(
              context: context,
              level: 'Intermediate',
              description: 'Advanced topics and practical applications',
              color: Colors.orange,
              icon: Icons.star,
              onTap: () => _startQuiz(quizController, 'Intermediate'),
            ),

            const SizedBox(height: 16),

            // Advanced level card
            _buildLevelCard(
              context: context,
              level: 'Advanced',
              description: 'Expert knowledge and complex scenarios',
              color: Colors.red,
              icon: Icons.workspace_premium,
              onTap: () => _startQuiz(quizController, 'Advanced'),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build level cards
  Widget _buildLevelCard({
    required BuildContext context,
    required String level,
    required String description,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      level,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }

  // Method to start quiz with selected level
  void _startQuiz(QuizController controller, String level) {
    // Set the selected level in the controller
    controller.setLevel(level);

    // Show loading dialog
    Get.dialog(
      const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Generating quiz questions...'),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    // Explicitly clear previous quiz data before fetching new questions
    controller.questions.clear();
    controller.resetQuiz();

    // Fetch quiz questions
    controller.fetchQuizQuestions(profession, category, level).then((_) {
      // Close loading dialog
      Get.back();

      // Debugging output to see current state
      print('Questions loaded: ${controller.questions.length}');
      print('Error message: ${controller.errorMessage.value}');

      // Check if questions were loaded successfully
      if (controller.questions.isNotEmpty) {
        // Navigate to quiz screen
        Get.to(() => QuizScreen(
              profession: profession,
              category: category,
              level: level,
            ));
      } else if (controller.errorMessage.isNotEmpty) {
        // Show error message
        Get.snackbar(
          'Error',
          controller.errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      } else {
        // Generic error if no specific error message but no questions loaded
        Get.snackbar(
          'Error',
          'Failed to load quiz questions. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      }
    }).catchError((error) {
      // Close loading dialog in case of error
      Get.back();
      // Show error message
      Get.snackbar(
        'Error',
        'An unexpected error occurred: $error',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    });
  }
}
