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
      final response = await http
          .post(
            Uri.parse(apiUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $apiKey',
            },
            body: jsonEncode({
              "model": "gemma2-9b-it",
              "messages": [
                {
                  "role": "system",
                  "content":
                      "You are a quiz generator. Always respond with valid JSON arrays only. No explanations or markdown formatting."
                },
                {
                  "role": "user",
                  "content": _buildQuizPrompt(profession, category, level)
                }
              ],
              "temperature": 0.3, // More consistent output
              "max_tokens": 1500, // Limit response length
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final responseMessage = data['choices'][0]['message']['content'];

        print('Raw API Response: $responseMessage'); // Debug log

        // Enhanced JSON extraction and parsing
        final extractedQuestions = _extractAndParseQuestions(responseMessage);

        if (extractedQuestions.isNotEmpty) {
          questions.assignAll(extractedQuestions);
          userAnswers
              .assignAll(List<int>.filled(extractedQuestions.length, -1));
          print('Successfully loaded ${questions.length} questions');
        } else {
          // Fallback: create sample questions
          final fallbackQuestions =
              _createFallbackQuestions(profession, category, level);
          questions.assignAll(fallbackQuestions);
          userAnswers.assignAll(List<int>.filled(fallbackQuestions.length, -1));
          print('Using fallback questions: ${questions.length}');
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

      // If API fails, use fallback questions
      final fallbackQuestions =
          _createFallbackQuestions(profession, category, level);
      questions.assignAll(fallbackQuestions);
      userAnswers.assignAll(List<int>.filled(fallbackQuestions.length, -1));

      errorMessage.value = 'Using offline questions due to connectivity issues';
    } finally {
      // Always update loading state when done
      isLoading.value = false;
    }
  }

  // Build optimized prompt for quiz generation
  String _buildQuizPrompt(String profession, String category, String level) {
    return '''Create exactly 5 multiple choice questions about $category for $profession at $level level.

Return ONLY a JSON array in this exact format:
[
  {
    "question": "Question text here?",
    "options": ["Option A", "Option B", "Option C", "Option D"],
    "correctAnswerIndex": 0,
    "explanation": "Brief explanation"
  }
]

Rules:
- Return JSON array immediately, no other text
- Each question must have exactly 4 options
- correctAnswerIndex must be 0, 1, 2, or 3
- Keep explanations under 100 characters
- Focus on $category concepts for $profession
- Make questions appropriate for $level level''';
  }

  // Enhanced JSON extraction and parsing with multiple fallback strategies
  List<QuizQuestion> _extractAndParseQuestions(String responseMessage) {
    final List<QuizQuestion> extractedQuestions = [];

    try {
      // Strategy 1: Try direct JSON parsing
      final directParsed = _tryDirectJsonParsing(responseMessage);
      if (directParsed.isNotEmpty) {
        return directParsed;
      }

      // Strategy 2: Extract JSON from markdown/text
      final extractedJson = _extractJsonFromText(responseMessage);
      if (extractedJson.isNotEmpty) {
        final parsed = _parseJsonToQuestions(extractedJson);
        if (parsed.isNotEmpty) {
          return parsed;
        }
      }

      // Strategy 3: Fix common JSON issues and retry
      final fixedJson = _fixCommonJsonIssues(responseMessage);
      if (fixedJson.isNotEmpty) {
        final parsed = _parseJsonToQuestions(fixedJson);
        if (parsed.isNotEmpty) {
          return parsed;
        }
      }

      // Strategy 4: Extract individual questions using regex
      final regexExtracted = _extractQuestionsWithRegex(responseMessage);
      if (regexExtracted.isNotEmpty) {
        return regexExtracted;
      }
    } catch (e) {
      print('Error in question extraction: $e');
    }

    return [];
  }

  // Strategy 1: Try direct JSON parsing
  List<QuizQuestion> _tryDirectJsonParsing(String text) {
    try {
      final cleaned = text.trim();
      if (cleaned.startsWith('[') && cleaned.endsWith(']')) {
        final List<dynamic> jsonData = jsonDecode(cleaned);
        return _parseJsonToQuestions(cleaned);
      }
    } catch (e) {
      print('Direct JSON parsing failed: $e');
    }
    return [];
  }

  // Strategy 2: Extract JSON from markdown/text wrapper
  String _extractJsonFromText(String text) {
    // Remove markdown code blocks
    String cleaned = text
        .replaceAll(RegExp(r'```json\s*'), '')
        .replaceAll(RegExp(r'```\s*'), '')
        .trim();

    // Find JSON array pattern
    final RegExp jsonArrayRegex = RegExp(r'\[\s*\{[\s\S]*?\}\s*\]');
    final Match? match = jsonArrayRegex.firstMatch(cleaned);

    if (match != null) {
      return match.group(0) ?? '';
    }

    // Try to find start and end of array manually
    final startIndex = cleaned.indexOf('[');
    final endIndex = cleaned.lastIndexOf(']');

    if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
      return cleaned.substring(startIndex, endIndex + 1);
    }

    return '';
  }

  // Strategy 3: Fix common JSON formatting issues
  String _fixCommonJsonIssues(String jsonString) {
    try {
      String fixed = jsonString.trim();

      // Ensure proper array brackets
      if (!fixed.startsWith('[')) fixed = '[' + fixed;
      if (!fixed.endsWith(']')) fixed = fixed + ']';

      // Fix common issues
      fixed = fixed
          // Remove trailing commas
          .replaceAll(RegExp(r',\s*}'), '}')
          .replaceAll(RegExp(r',\s*]'), ']')
          // Fix unquoted keys
          .replaceAll(RegExp(r'([{,]\s*)([a-zA-Z_]\w*)\s*:'), r'$1"$2":')
          // Fix single quotes to double quotes
          .replaceAll("'", '"')
          // Remove extra commas
          .replaceAll(RegExp(r',\s*,'), ',')
          // Fix broken strings
          .replaceAll(RegExp(r'"\s*\+\s*"'), '')
          // Remove newlines inside strings
          .replaceAll(RegExp(r'"\s*\n\s*"'), ' ');

      // Validate by attempting to parse
      jsonDecode(fixed);
      return fixed;
    } catch (e) {
      print('JSON fixing failed: $e');
      return '';
    }
  }

  // Strategy 4: Extract questions using regex patterns
  List<QuizQuestion> _extractQuestionsWithRegex(String text) {
    final List<QuizQuestion> questions = [];

    try {
      // Pattern to match question structures in text
      final RegExp questionRegex = RegExp(
          r'(?:question|q\d+)["\s:]*([^"]+).*?(?:options|choices)["\s:]*\[(.*?)\].*?(?:correct|answer)["\s:]*(\d+).*?(?:explanation)["\s:]*([^"]*)',
          caseSensitive: false,
          dotAll: true);

      final matches = questionRegex.allMatches(text);

      for (final match in matches) {
        try {
          final questionText = match.group(1)?.trim() ?? '';
          final optionsText = match.group(2)?.trim() ?? '';
          final correctIndexText = match.group(3)?.trim() ?? '0';
          final explanationText = match.group(4)?.trim() ?? '';

          if (questionText.isNotEmpty && optionsText.isNotEmpty) {
            // Parse options
            final options = optionsText
                .split(RegExp(r'[,"]'))
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty && s != ',')
                .take(4)
                .toList();

            if (options.length >= 4) {
              final correctIndex = int.tryParse(correctIndexText) ?? 0;

              questions.add(QuizQuestion(
                question: questionText,
                options: options,
                correctAnswerIndex: correctIndex.clamp(0, 3),
                explanation: explanationText.isEmpty
                    ? 'No explanation provided'
                    : explanationText,
              ));
            }
          }
        } catch (e) {
          print('Error parsing individual question: $e');
        }
      }
    } catch (e) {
      print('Regex extraction failed: $e');
    }

    return questions;
  }

  // Parse validated JSON string to QuizQuestion objects
  List<QuizQuestion> _parseJsonToQuestions(String jsonString) {
    try {
      final List<dynamic> jsonData = jsonDecode(jsonString);
      final List<QuizQuestion> questions = [];

      for (final item in jsonData) {
        if (item is Map<String, dynamic>) {
          final question = _createQuestionFromJson(item);
          if (question != null) {
            questions.add(question);
          }
        }
      }

      return questions;
    } catch (e) {
      print('JSON to questions parsing failed: $e');
      return [];
    }
  }

  // Create QuizQuestion from JSON with validation
  QuizQuestion? _createQuestionFromJson(Map<String, dynamic> json) {
    try {
      final questionText = json['question']?.toString().trim() ?? '';
      final options = json['options'];
      final correctIndex = json['correctAnswerIndex'];
      final explanation = json['explanation']?.toString().trim() ?? '';

      // Validate question text
      if (questionText.isEmpty) return null;

      // Validate and parse options
      List<String> optionsList = [];
      if (options is List) {
        optionsList = options
            .map((opt) => opt?.toString().trim() ?? '')
            .where((opt) => opt.isNotEmpty)
            .toList();
      }

      if (optionsList.length < 4) return null;

      // Validate correct index
      int correctAnswerIndex = 0;
      if (correctIndex is int) {
        correctAnswerIndex = correctIndex.clamp(0, 3);
      } else if (correctIndex is String) {
        correctAnswerIndex = int.tryParse(correctIndex)?.clamp(0, 3) ?? 0;
      }

      return QuizQuestion(
        question: questionText,
        options: optionsList.take(4).toList(),
        correctAnswerIndex: correctAnswerIndex,
        explanation:
            explanation.isEmpty ? 'No explanation provided' : explanation,
      );
    } catch (e) {
      print('Error creating question from JSON: $e');
      return null;
    }
  }

  // Create fallback questions when API fails
  List<QuizQuestion> _createFallbackQuestions(
      String profession, String category, String level) {
    // Create basic questions based on profession and category
    final List<QuizQuestion> fallbackQuestions = [];

    if (profession.toLowerCase().contains('frontend')) {
      if (category.toLowerCase().contains('javascript')) {
        fallbackQuestions.addAll(_createJavaScriptQuestions(level));
      } else if (category.toLowerCase().contains('html')) {
        fallbackQuestions.addAll(_createHTMLQuestions(level));
      } else if (category.toLowerCase().contains('css')) {
        fallbackQuestions.addAll(_createCSSQuestions(level));
      }
    } else if (profession.toLowerCase().contains('backend')) {
      if (category.toLowerCase().contains('node')) {
        fallbackQuestions.addAll(_createNodeJSQuestions(level));
      } else if (category.toLowerCase().contains('python')) {
        fallbackQuestions.addAll(_createPythonQuestions(level));
      }
    }

    // If no specific questions, create generic ones
    if (fallbackQuestions.isEmpty) {
      fallbackQuestions
          .addAll(_createGenericQuestions(profession, category, level));
    }

    return fallbackQuestions.take(5).toList();
  }

  // JavaScript fallback questions
  List<QuizQuestion> _createJavaScriptQuestions(String level) {
    if (level.toLowerCase() == 'basic') {
      return [
        QuizQuestion(
          question: "What does 'var' keyword do in JavaScript?",
          options: [
            "Declares a variable",
            "Creates a function",
            "Defines a class",
            "Imports a module"
          ],
          correctAnswerIndex: 0,
          explanation:
              "The 'var' keyword is used to declare variables in JavaScript.",
        ),
        QuizQuestion(
          question: "Which data type is NOT primitive in JavaScript?",
          options: ["String", "Number", "Object", "Boolean"],
          correctAnswerIndex: 2,
          explanation:
              "Object is a non-primitive data type, while others are primitive.",
        ),
        QuizQuestion(
          question: "How do you write a comment in JavaScript?",
          options: [
            "# This is a comment",
            "// This is a comment",
            "<!-- This is a comment -->",
            "* This is a comment"
          ],
          correctAnswerIndex: 1,
          explanation: "Single-line comments in JavaScript start with //",
        ),
        QuizQuestion(
          question: "Which method adds an element to the end of an array?",
          options: ["push()", "pop()", "shift()", "unshift()"],
          correctAnswerIndex: 0,
          explanation:
              "push() method adds one or more elements to the end of an array.",
        ),
        QuizQuestion(
          question:
              "What is the correct way to create a function in JavaScript?",
          options: [
            "function = myFunction() {}",
            "function myFunction() {}",
            "create myFunction() {}",
            "def myFunction() {}"
          ],
          correctAnswerIndex: 1,
          explanation:
              "Functions are declared using the 'function' keyword followed by name and parentheses.",
        ),
      ];
    }
    return [];
  }

  // HTML fallback questions
  List<QuizQuestion> _createHTMLQuestions(String level) {
    return [
      QuizQuestion(
        question: "What does HTML stand for?",
        options: [
          "Hyper Text Markup Language",
          "High Tech Modern Language",
          "Home Tool Markup Language",
          "Hyperlink and Text Markup Language"
        ],
        correctAnswerIndex: 0,
        explanation: "HTML stands for Hyper Text Markup Language.",
      ),
      QuizQuestion(
        question: "Which HTML tag is used for the largest heading?",
        options: ["<h6>", "<h1>", "<header>", "<head>"],
        correctAnswerIndex: 1,
        explanation: "<h1> tag represents the largest/most important heading.",
      ),
      QuizQuestion(
        question: "What is the correct HTML tag for inserting a line break?",
        options: ["<break>", "<lb>", "<br>", "<newline>"],
        correctAnswerIndex: 2,
        explanation: "<br> tag is used to insert a line break in HTML.",
      ),
      QuizQuestion(
        question: "Which attribute specifies the URL of a link?",
        options: ["src", "href", "link", "url"],
        correctAnswerIndex: 1,
        explanation:
            "The 'href' attribute specifies the URL of the page the link goes to.",
      ),
      QuizQuestion(
        question: "What is the correct HTML for creating a hyperlink?",
        options: [
          "<a url='http://example.com'>Link</a>",
          "<a href='http://example.com'>Link</a>",
          "<link href='http://example.com'>Link</link>",
          "<a src='http://example.com'>Link</a>"
        ],
        correctAnswerIndex: 1,
        explanation:
            "Hyperlinks are created using <a> tag with href attribute.",
      ),
    ];
  }

  // CSS fallback questions
  List<QuizQuestion> _createCSSQuestions(String level) {
    return [
      QuizQuestion(
        question: "What does CSS stand for?",
        options: [
          "Computer Style Sheets",
          "Cascading Style Sheets",
          "Creative Style Sheets",
          "Colorful Style Sheets"
        ],
        correctAnswerIndex: 1,
        explanation: "CSS stands for Cascading Style Sheets.",
      ),
      QuizQuestion(
        question: "Which CSS property is used to change text color?",
        options: ["text-color", "font-color", "color", "text-style"],
        correctAnswerIndex: 2,
        explanation: "The 'color' property is used to set the color of text.",
      ),
      QuizQuestion(
        question: "How do you add a comment in CSS?",
        options: [
          "// comment",
          "/* comment */",
          "# comment",
          "<!-- comment -->"
        ],
        correctAnswerIndex: 1,
        explanation: "CSS comments are written between /* and */",
      ),
      QuizQuestion(
        question: "Which property is used to change the background color?",
        options: [
          "bgcolor",
          "background-color",
          "bg-color",
          "color-background"
        ],
        correctAnswerIndex: 1,
        explanation:
            "background-color property sets the background color of an element.",
      ),
      QuizQuestion(
        question: "What is the correct CSS syntax?",
        options: [
          "body {color: black;}",
          "{body: color=black;}",
          "body: color=black;",
          "{body; color: black;}"
        ],
        correctAnswerIndex: 0,
        explanation: "CSS syntax: selector {property: value;}",
      ),
    ];
  }

  // Node.js fallback questions
  List<QuizQuestion> _createNodeJSQuestions(String level) {
    return [
      QuizQuestion(
        question: "What is Node.js?",
        options: [
          "A JavaScript framework",
          "A JavaScript runtime environment",
          "A database",
          "A web browser"
        ],
        correctAnswerIndex: 1,
        explanation:
            "Node.js is a JavaScript runtime built on Chrome's V8 JavaScript engine.",
      ),
      QuizQuestion(
        question: "Which command is used to install packages in Node.js?",
        options: [
          "node install",
          "npm install",
          "install npm",
          "package install"
        ],
        correctAnswerIndex: 1,
        explanation:
            "npm install is used to install packages in Node.js projects.",
      ),
      QuizQuestion(
        question: "What file contains project dependencies in Node.js?",
        options: [
          "package.json",
          "dependencies.json",
          "node.json",
          "modules.json"
        ],
        correctAnswerIndex: 0,
        explanation:
            "package.json file contains project metadata and dependencies.",
      ),
      QuizQuestion(
        question: "How do you import a module in Node.js?",
        options: [
          "import module",
          "require('module')",
          "include module",
          "load module"
        ],
        correctAnswerIndex: 1,
        explanation: "require() function is used to import modules in Node.js.",
      ),
      QuizQuestion(
        question: "Which is the default package manager for Node.js?",
        options: ["yarn", "bower", "npm", "pip"],
        correctAnswerIndex: 2,
        explanation:
            "npm (Node Package Manager) is the default package manager for Node.js.",
      ),
    ];
  }

  // Python fallback questions
  List<QuizQuestion> _createPythonQuestions(String level) {
    return [
      QuizQuestion(
        question: "What is Python?",
        options: [
          "A snake",
          "A programming language",
          "A database",
          "A web server"
        ],
        correctAnswerIndex: 1,
        explanation:
            "Python is a high-level, interpreted programming language.",
      ),
      QuizQuestion(
        question: "How do you create a comment in Python?",
        options: [
          "// comment",
          "/* comment */",
          "# comment",
          "<!-- comment -->"
        ],
        correctAnswerIndex: 2,
        explanation: "Comments in Python start with the # symbol.",
      ),
      QuizQuestion(
        question: "Which keyword is used to define a function in Python?",
        options: ["function", "def", "func", "define"],
        correctAnswerIndex: 1,
        explanation: "The 'def' keyword is used to define functions in Python.",
      ),
      QuizQuestion(
        question: "What is the correct way to create a list in Python?",
        options: [
          "list = (1, 2, 3)",
          "list = [1, 2, 3]",
          "list = {1, 2, 3}",
          "list = <1, 2, 3>"
        ],
        correctAnswerIndex: 1,
        explanation: "Lists in Python are created using square brackets [].",
      ),
      QuizQuestion(
        question: "Which function is used to display output in Python?",
        options: ["echo()", "print()", "display()", "output()"],
        correctAnswerIndex: 1,
        explanation: "print() function is used to display output in Python.",
      ),
    ];
  }

  // Generic fallback questions
  List<QuizQuestion> _createGenericQuestions(
      String profession, String category, String level) {
    return [
      QuizQuestion(
        question: "What is the primary focus of $profession?",
        options: [
          "Building user interfaces",
          "Server-side development",
          "Database management",
          "All of the above"
        ],
        correctAnswerIndex: 3,
        explanation:
            "Developers work on various aspects of software development.",
      ),
      QuizQuestion(
        question: "Which is important for $category development?",
        options: [
          "Problem-solving skills",
          "Continuous learning",
          "Best practices",
          "All of the above"
        ],
        correctAnswerIndex: 3,
        explanation: "All these aspects are crucial for effective development.",
      ),
      QuizQuestion(
        question: "What skill level does '$level' represent?",
        options: ["Entry level", "Intermediate", "Advanced", "Expert"],
        correctAnswerIndex: level.toLowerCase() == 'basic'
            ? 0
            : level.toLowerCase() == 'intermediate'
                ? 1
                : 2,
        explanation: "$level represents a specific skill proficiency level.",
      ),
      QuizQuestion(
        question: "Which is a best practice in software development?",
        options: [
          "Code documentation",
          "Version control",
          "Testing",
          "All of the above"
        ],
        correctAnswerIndex: 3,
        explanation:
            "All mentioned practices are essential in software development.",
      ),
      QuizQuestion(
        question: "What is important for career growth in $profession?",
        options: [
          "Staying updated with trends",
          "Building projects",
          "Networking",
          "All of the above"
        ],
        correctAnswerIndex: 3,
        explanation: "All these factors contribute to professional growth.",
      ),
    ];
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
