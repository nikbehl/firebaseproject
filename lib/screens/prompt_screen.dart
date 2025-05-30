import 'package:firebaseproject/controllers/prompt_controller.dart';
import 'package:firebaseproject/screens/data_display_screen.dart';
import 'package:firebaseproject/screens/job_listing_screens.dart';

import 'package:firebaseproject/screens/quiz_level_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PromptScreen extends StatelessWidget {
  final String profession;
  final String category;

  const PromptScreen(
      {super.key, required this.profession, required this.category});

  @override
  Widget build(BuildContext context) {
    // Get the prompt controller
    final promptController = Get.find<PromptController>();

    // Clear any existing prompt
    promptController.clearPrompt();

    // Text editing controller for the text field
    final TextEditingController textController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('$profession - $category'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Main sections container
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Learning section
                    const Text(
                      'Learning Resources',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Get detailed information about this topic',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Enter a prompt to receive guides, tutorials, documentation links, and latest version information.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildSuggestionChip('Best practices',
                                    textController, promptController),
                                _buildSuggestionChip('Latest trends',
                                    textController, promptController),
                                _buildSuggestionChip('Getting started',
                                    textController, promptController),
                                _buildSuggestionChip('Advanced techniques',
                                    textController, promptController),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // "Or" text
                            const Center(
                              child: Text(
                                'OR',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // TextField moved here
                            TextField(
                              controller: textController,
                              decoration: const InputDecoration(
                                hintText: 'Enter your prompt here',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 3,
                              onChanged: (value) {
                                promptController.setPrompt(value);
                              },
                            ),
                            const SizedBox(height: 16),
                            Obx(() => ElevatedButton(
                                  onPressed: promptController.isPromptValid()
                                      ? () {
                                          // Navigate to data display screen
                                          Get.to(() => DataDisplayScreen(
                                                profession: profession,
                                                category: category,
                                                prompt: promptController
                                                    .prompt.value,
                                              ));
                                        }
                                      : null, // Disable button if prompt is empty
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(45),
                                  ),
                                  child: const Text('Get Information'),
                                )),

                            // TextField(
                            //   controller: textController,
                            //   decoration: const InputDecoration(
                            //     hintText: 'Enter your prompt here',
                            //     border: OutlineInputBorder(),
                            //   ),
                            //   maxLines: 3,
                            //   onChanged: (value) {
                            //     promptController.setPrompt(value);
                            //   },
                            // ),
                            // const SizedBox(height: 16),

                            // // Prompt suggestions
                            // Wrap(
                            //   spacing: 8,
                            //   runSpacing: 8,
                            //   children: [
                            //     _buildSuggestionChip('Best practices',
                            //         textController, promptController),
                            //     _buildSuggestionChip('Latest trends',
                            //         textController, promptController),
                            //     _buildSuggestionChip('Getting started',
                            //         textController, promptController),
                            //     _buildSuggestionChip('Advanced techniques',
                            //         textController, promptController),
                            //   ],
                            // ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Quiz section
                    const Text(
                      'Test Your Knowledge',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Card(
                      elevation: 2,
                      color: Colors.blue.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () {
                          // Navigate to quiz level screen
                          Get.to(() => QuizLevelScreen(
                                profession: profession,
                                category: category,
                              ));
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.quiz,
                                    size: 36,
                                    color: Colors.blue.shade700,
                                  ),
                                  const SizedBox(width: 16),
                                  const Expanded(
                                    child: Text(
                                      'Flash Challenge Quiz',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward,
                                    color: Colors.blue.shade700,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Test your knowledge with multiple-choice questions at different difficulty levels.',
                                style: TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 8),
                              // Wrap(
                              //   spacing: 8,
                              //   runSpacing: 8,
                              //   children: [
                              //     _buildLevelChip('Basic', Colors.green),
                              //     _buildLevelChip(
                              //         'Intermediate', Colors.orange),
                              //     _buildLevelChip('Advanced', Colors.red),
                              //   ],
                              // ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Job listings section
                    const Text(
                      'Career Opportunities',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Card(
                      elevation: 2,
                      color: Colors.green.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () {
                          // Navigate to job listings screen
                          Get.to(() => JobListingsScreen(
                                profession: profession,
                                category: category,
                              ));
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.work,
                                    size: 36,
                                    color: Colors.green.shade700,
                                  ),
                                  const SizedBox(width: 16),
                                  const Expanded(
                                    child: Text(
                                      'Job Listings',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward,
                                    color: Colors.green.shade700,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Explore relevant job opportunities for your profession and specialization.',
                                style: TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 16),

                              // Job highlights preview
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.green.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Available Jobs Include:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    _buildJobPreviewItem(
                                      Icons.code,
                                      '$profession Roles',
                                    ),
                                    const SizedBox(height: 4),
                                    _buildJobPreviewItem(
                                      Icons.school,
                                      '$category Specialists',
                                    ),
                                    const SizedBox(height: 4),
                                    _buildJobPreviewItem(
                                      Icons.business,
                                      'Both Startups & Enterprises',
                                    ),
                                    const SizedBox(height: 4),
                                    _buildJobPreviewItem(
                                      Icons.public,
                                      'Remote & On-site Positions',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build suggestion chips
  Widget _buildSuggestionChip(
    String label,
    TextEditingController textController,
    PromptController promptController,
  ) {
    return InputChip(
      label: Text(label),
      onPressed: () {
        final promptText = "Tell me about $label for $category in $profession";

        // Navigate directly to data display screen with the selected prompt
        Get.to(() => DataDisplayScreen(
              profession: profession,
              category: category,
              prompt: promptText,
            ));
      },
      backgroundColor: Colors.grey.shade200,
    );
  }

  // Helper method to build level chips
  Widget _buildLevelChip(String label, Color color) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: color.withOpacity(0.1),
    );
  }

  // Helper method to build job preview items
  Widget _buildJobPreviewItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.green.shade700,
        ),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }
}
