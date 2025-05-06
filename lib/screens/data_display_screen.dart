import 'package:firebaseproject/controllers/tech_guide_controller.dart';
import 'package:firebaseproject/models/tech_guide_response.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class DataDisplayScreen extends StatelessWidget {
  final String profession;
  final String category;
  final String prompt;

  const DataDisplayScreen(
      {super.key,
      required this.profession,
      required this.category,
      required this.prompt});

  // Launch URL method
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      Get.snackbar(
        'Error',
        'Could not launch $url',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the tech guide controller
    final techGuideController = Get.find<TechGuideController>();

    // Fetch data when the screen loads
    techGuideController.fetchTechGuideData(category, prompt);

    return Scaffold(
      appBar: AppBar(
        title: Text('$profession - $category'),
      ),
      body: Obx(() {
        // Show loading indicator
        if (techGuideController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // Show error message if any
        if (techGuideController.errorMessage.value.isNotEmpty) {
          return Center(child: Text(techGuideController.errorMessage.value));
        }

        // Show data if available
        if (techGuideController.response.value != null) {
          final TechGuideResponse response =
              techGuideController.response.value!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main content
                  Text(
                    response.mainContent,
                    style: const TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 24),

                  // Version information section
                  if (response.versionDetails.isNotEmpty) ...[
                    const Divider(),
                    const Text(
                      'Latest Versions:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...List.generate(
                      response.versionDetails.length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${index + 1}. '),
                            Expanded(
                              child: response.versionDetails[index].technology
                                      .isNotEmpty
                                  ? RichText(
                                      text: TextSpan(
                                        style: const TextStyle(
                                            color: Colors.black),
                                        children: [
                                          TextSpan(
                                            text: response.versionDetails[index]
                                                .technology,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const TextSpan(text: ': v'),
                                          TextSpan(
                                              text: response
                                                  .versionDetails[index]
                                                  .version),
                                          if (response.versionDetails[index]
                                              .releaseDate.isNotEmpty) ...[
                                            const TextSpan(
                                                text: ' (Released: '),
                                            TextSpan(
                                                text: response
                                                    .versionDetails[index]
                                                    .releaseDate),
                                            const TextSpan(text: ')'),
                                          ],
                                        ],
                                      ),
                                    )
                                  : Text(response
                                      .versionDetails[index].additionalInfo),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Sources section
                  if (response.sources.isNotEmpty) ...[
                    const Divider(),
                    const Text(
                      'Sources:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...List.generate(
                      response.sources.length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: InkWell(
                          onTap: response.sources[index].url.isNotEmpty
                              ? () => _launchUrl(response.sources[index].url)
                              : null,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${index + 1}. '),
                              Expanded(
                                child: Text(
                                  response.sources[index].name,
                                  style: TextStyle(
                                    color:
                                        response.sources[index].url.isNotEmpty
                                            ? Colors.blue
                                            : null,
                                    decoration:
                                        response.sources[index].url.isNotEmpty
                                            ? TextDecoration.underline
                                            : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Documentation links section
                  if (response.documentationLinks.isNotEmpty) ...[
                    const Divider(),
                    const Text(
                      'Documentation:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...List.generate(
                      response.documentationLinks.length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: InkWell(
                          onTap:
                              response.documentationLinks[index].url.isNotEmpty
                                  ? () => _launchUrl(
                                      response.documentationLinks[index].url)
                                  : null,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${index + 1}. '),
                              Expanded(
                                child: Text(
                                  response.documentationLinks[index].name,
                                  style: TextStyle(
                                    color: response.documentationLinks[index]
                                            .url.isNotEmpty
                                        ? Colors.blue
                                        : null,
                                    decoration: response
                                            .documentationLinks[index]
                                            .url
                                            .isNotEmpty
                                        ? TextDecoration.underline
                                        : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }

        // Fallback (should not reach here)
        return const Center(child: Text('No data available.'));
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Refresh data
          techGuideController.fetchTechGuideData(category, prompt);
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
