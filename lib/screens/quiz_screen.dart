import 'package:firebaseproject/controllers/quiz_controller.dart';
import 'package:firebaseproject/screens/quiz_result_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QuizScreen extends StatelessWidget {
  final String profession;
  final String category;
  final String level;

  const QuizScreen({
    super.key,
    required this.profession,
    required this.category,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    // Get the quiz controller
    final quizController = Get.find<QuizController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('$level Quiz'),
        // Prevent back button from navigating back during quiz
        automaticallyImplyLeading: false,
        actions: [
          // Exit button
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              // Show confirmation dialog
              Get.dialog(
                AlertDialog(
                  title: const Text('Exit Quiz?'),
                  content: const Text('Your progress will be lost.'),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.back(); // Close dialog
                        Get.back(); // Go back to quiz level screen
                      },
                      child: const Text('Exit'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        // Check if quiz is completed
        if (quizController.quizCompleted.value) {
          // Navigate to results screen
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.off(() => QuizResultScreen(
                  profession: profession,
                  category: category,
                  level: level,
                ));
          });
        }

        // If questions are available
        if (quizController.questions.isNotEmpty) {
          final currentQuestion = quizController
              .questions[quizController.currentQuestionIndex.value];

          return Column(
            children: [
              // Progress indicator
              LinearProgressIndicator(
                value: (quizController.currentQuestionIndex.value + 1) /
                    quizController.questions.length,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.deepPurple,
                ),
              ),

              // Progress text
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question ${quizController.currentQuestionIndex.value + 1}/${quizController.questions.length}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Score: ${quizController.score.value}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Question card
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Question text
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              currentQuestion.question,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Options
                        ...List.generate(
                          currentQuestion.options.length,
                          (index) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: InkWell(
                              onTap: quizController.hasAnsweredCurrentQuestion()
                                  ? null // Disable if already answered
                                  : () => quizController.answerQuestion(index),
                              child: Card(
                                elevation: 2,
                                color: quizController.getOptionColor(index),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.white,
                                        child: Text(
                                          String.fromCharCode(
                                              65 + index), // A, B, C, D
                                          style: TextStyle(
                                            color: quizController
                                                .getOptionColor(index),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          currentQuestion.options[index],
                                          style: const TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Explanation (shown after answering)
                        if (quizController.hasAnsweredCurrentQuestion()) ...[
                          Card(
                            elevation: 2,
                            color: Colors.blue.shade50,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Explanation:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    currentQuestion.explanation,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              // Next button (shown after answering)
              if (quizController.hasAnsweredCurrentQuestion() &&
                  quizController.currentQuestionIndex.value <
                      quizController.questions.length - 1) ...[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      quizController.currentQuestionIndex.value++;
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text(
                      'Next Question',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],

              // Finish button (shown after answering the last question)
              if (quizController.hasAnsweredCurrentQuestion() &&
                  quizController.currentQuestionIndex.value ==
                      quizController.questions.length - 1) ...[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      quizController.quizCompleted.value = true;
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: Colors.green,
                    ),
                    child: const Text(
                      'Finish Quiz',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ],
          );
        }

        // Fallback (should not reach here)
        return const Center(
          child: Text('No questions available'),
        );
      }),
    );
  }
}
