import 'package:firebaseproject/controllers/activity_tracking_controller.dart';
import 'package:firebaseproject/controllers/quiz_controller.dart';
import 'package:firebaseproject/screens/acitivity_dashboard.dart';
import 'package:firebaseproject/screens/quiz_level_screen.dart';
import 'package:firebaseproject/screens/quiz_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QuizResultScreen extends StatelessWidget {
  final String profession;
  final String category;
  final String level;

  const QuizResultScreen({
    super.key,
    required this.profession,
    required this.category,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    // Get the quiz controller
    final quizController = Get.find<QuizController>();

    // Get the activity tracking controller
    final activityController = Get.find<ActivityTrackingController>();

    // Calculate score percentage
    final double scorePercentage = quizController.getScorePercentage();

    // Record the quiz activity
    _recordQuizActivity(activityController, quizController, scorePercentage);

    // Determine result message and color based on score
    String resultMessage;
    Color resultColor;
    IconData resultIcon;

    if (scorePercentage >= 80) {
      resultMessage = 'Excellent!';
      resultColor = Colors.green;
      resultIcon = Icons.emoji_events;
    } else if (scorePercentage >= 60) {
      resultMessage = 'Good Job!';
      resultColor = Colors.blue;
      resultIcon = Icons.thumb_up;
    } else {
      resultMessage = 'Keep Practicing!';
      resultColor = Colors.orange;
      resultIcon = Icons.school;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Results'),
        automaticallyImplyLeading: false, // Remove back button
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Results card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Icon(
                      resultIcon,
                      size: 80,
                      color: resultColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      resultMessage,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: resultColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You scored',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${quizController.score.value}/${quizController.questions.length}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${scorePercentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: resultColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Quiz information
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildInfoRow('Profession', profession),
                    const Divider(),
                    _buildInfoRow('Category', category),
                    const Divider(),
                    _buildInfoRow('Level', level),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Action buttons
            Row(
              children: [
                // Try again button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _retryQuiz(quizController);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Change level button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Clear all quiz data before going back to level screen
                      quizController.questions.clear();
                      quizController.resetQuiz();

                      // Go back to level selection
                      Get.offAll(() => QuizLevelScreen(
                            profession: profession,
                            category: category,
                          ));
                    },
                    icon: const Icon(Icons.format_list_bulleted),
                    label: const Text('Change Level'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Exit button
            ElevatedButton.icon(
              onPressed: () {
                // Clear all quiz data before going back
                quizController.questions.clear();
                quizController.resetQuiz();

                // Go back to prompt screen
                Get.back();
              },
              icon: const Icon(Icons.exit_to_app),
              label: const Text('Exit Quiz'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.grey.shade200,
                foregroundColor: Colors.black87,
              ),
            ),

            // View Activity Dashboard button
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                // Ensure data is saved before navigating
                activityController.saveActivities();
                activityController.updateStats();

                // Navigate to dashboard and remove previous screens from stack
                Get.offAll(() => const ActivityDashboardScreen());
              },
              icon: const Icon(Icons.bar_chart),
              label: const Text('View Activity Dashboard'),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to retry quiz
  void _retryQuiz(QuizController quizController) {
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
                Text('Generating new questions...'),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    // Make sure to fully reset everything
    quizController.questions.clear();
    quizController.resetQuiz();

    // Fetch quiz questions
    quizController.fetchQuizQuestions(profession, category, level).then((_) {
      // Close loading dialog
      Get.back();

      // Check if questions were loaded successfully
      if (quizController.questions.isNotEmpty) {
        // Navigate to quiz screen - use offAll to clear navigation stack
        Get.offAll(() => QuizScreen(
              profession: profession,
              category: category,
              level: level,
            ));
      } else if (quizController.errorMessage.isNotEmpty) {
        // Show error message
        Get.snackbar(
          'Error',
          quizController.errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      } else {
        // Generic error if no specific error message
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
      // Close loading dialog
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

  // Helper method to build info rows
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to record quiz activity
// In QuizResultScreen
  void _recordQuizActivity(ActivityTrackingController activityController,
      QuizController quizController, double scorePercentage) {
    // Record the activity
    activityController.recordQuizActivity(
      profession,
      category,
      level,
      scorePercentage,
    );

    // Explicitly save and update stats after recording
    activityController.saveActivities();
    activityController.updateStats();

    // For debugging - print current heatmap data
    print("Current heatmap data: ${activityController.heatmapData}");
  }
}
