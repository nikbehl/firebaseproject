import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebaseproject/models/quiz_question.dart';

class QuizController extends GetxController {
  // Observable variables
  final RxList<QuizQuestion> questions = <QuizQuestion>[].obs;
  final RxInt currentQuestionIndex = 0.obs;
  final RxInt score = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool quizCompleted = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString selectedLevel = ''.obs;
  final RxList<int> userAnswers = <int>[].obs;

  // API key (Consider using environment variables or secure storage in production)
  final String apiKey =
      "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";
  final String apiUrl = "https://api.groq.com/openai/v1/chat/completions";

  // Reset quiz state
  void resetQuiz() {
    currentQuestionIndex.value = 0;
    score.value = 0;
    quizCompleted.value = false;
    userAnswers.clear();
    errorMessage.value = '';
    // Important: Don't clear questions here, as they might be reused
  }

  // Set the selected difficulty level
  void setLevel(String level) {
    selectedLevel.value = level;
  }

  // Fetch quiz questions from API based on profession, category, and level
  Future<void> fetchQuizQuestions(
      String profession, String category, String level) async {
    // Set loading state
    isLoading.value = true;
    errorMessage.value = '';

    // Clear previous questions (important for retries)
    questions.clear();
    resetQuiz();

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          "model": "gemma2-9b-it",
          "messages": [
            {
              "role": "user",
              "content":
                  """Create 5 multiple choice quiz questions for $level level about $category for $profession.

Each question should have 4 options with only one correct answer.

Format your response as a JSON array with the following structure for each question:
{
  "question": "Question text",
  "options": ["Option A", "Option B", "Option C", "Option D"],
  "correctAnswerIndex": correct_option_index_number_from_0_to_3,
  "explanation": "Brief explanation of why the answer is correct"
}

Make sure the entire response is a properly formatted JSON array that can be parsed directly."""
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final responseMessage = data['choices'][0]['message']['content'];

        // Try to extract JSON from the response
        try {
          // Find JSON array in the response
          final RegExp jsonRegex = RegExp(r'\[\s*\{.*\}\s*\]', dotAll: true);
          final Match? jsonMatch = jsonRegex.firstMatch(responseMessage);

          if (jsonMatch != null) {
            final String jsonString = jsonMatch.group(0) ?? '[]';
            final List<dynamic> jsonData = jsonDecode(jsonString);

            // Check if we actually got questions
            if (jsonData.isEmpty) {
              throw Exception('No questions were returned');
            }

            // Convert JSON to QuizQuestion objects
            final List<QuizQuestion> quizQuestions = jsonData
                .map((item) => QuizQuestion(
                      question: item['question'] ?? '',
                      options: List<String>.from(item['options'] ?? []),
                      correctAnswerIndex: item['correctAnswerIndex'] ?? 0,
                      explanation: item['explanation'] ?? '',
                    ))
                .toList();

            // Update questions list
            questions.assignAll(quizQuestions);

            // Initialize userAnswers list with -1 (unanswered) for each question
            userAnswers.assignAll(List<int>.filled(quizQuestions.length, -1));

            // Log successful question loading
            print('Successfully loaded ${questions.length} questions');
          } else {
            throw Exception('Could not parse JSON data from response');
          }
        } catch (e) {
          print('Error parsing quiz data: $e');
          errorMessage.value = 'Error parsing quiz data: $e';
        }
      } else if (response.statusCode == 401) {
        errorMessage.value =
            "Error 401: Unauthorized - Check your API key and permissions.";
      } else {
        errorMessage.value =
            'Error ${response.statusCode}: ${response.reasonPhrase}';
      }
    } catch (e) {
      print('Error during API call: $e');
      errorMessage.value = 'Error during API call: $e';
    } finally {
      // Always update loading state when done
      isLoading.value = false;
    }
  }

  // Answer current question
  void answerQuestion(int selectedOptionIndex) {
    // Record user's answer
    userAnswers[currentQuestionIndex.value] = selectedOptionIndex;

    // Update score if correct
    if (selectedOptionIndex ==
        questions[currentQuestionIndex.value].correctAnswerIndex) {
      score.value++;
    }

    // Move to next question or complete quiz
    if (currentQuestionIndex.value < questions.length - 1) {
      currentQuestionIndex.value++;
    } else {
      quizCompleted.value = true;
    }
  }

  // Get percentage score
  double getScorePercentage() {
    if (questions.isEmpty) return 0.0;
    return (score.value / questions.length) * 100;
  }

  // Check if user has answered current question
  bool hasAnsweredCurrentQuestion() {
    if (currentQuestionIndex.value >= userAnswers.length) return false;
    return userAnswers[currentQuestionIndex.value] != -1;
  }

  // Get user's answer for current question
  int getUserAnswerForCurrentQuestion() {
    if (currentQuestionIndex.value >= userAnswers.length) return -1;
    return userAnswers[currentQuestionIndex.value];
  }

  // Get color for option based on state (selected, correct, incorrect)
  Color getOptionColor(int optionIndex) {
    // If quiz is completed or user has answered this question
    if (quizCompleted.value || hasAnsweredCurrentQuestion()) {
      // Correct answer is always highlighted in green
      if (optionIndex ==
          questions[currentQuestionIndex.value].correctAnswerIndex) {
        return Colors.green;
      }

      // User's incorrect answer is highlighted in red
      if (optionIndex == getUserAnswerForCurrentQuestion() &&
          optionIndex !=
              questions[currentQuestionIndex.value].correctAnswerIndex) {
        return Colors.red;
      }
    }

    // Default unselected color
    return Colors.grey.shade200;
  }
}
