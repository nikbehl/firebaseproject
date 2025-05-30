import 'package:firebaseproject/controllers/tech_guide_controller.dart';
import 'package:firebaseproject/models/tech_guide_response.dart';
import 'package:firebaseproject/models/version_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class DataDisplayScreen extends StatelessWidget {
  final String profession;
  final String category;
  final String prompt;

  const DataDisplayScreen({
    super.key,
    required this.profession,
    required this.category,
    required this.prompt,
  });

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

  // Method to remove special characters from text
  String _removeSpecialCharacters(String text) {
    // Remove common markdown/special characters while preserving basic punctuation
    return text
        .replaceAll(
            RegExp(r'[*_~`#\[\]{}|\\]'), '') // Remove markdown characters
        .replaceAll(
            RegExp(r'^\s*[-•]\s*', multiLine: true), '') // Remove bullet points
        .replaceAll(RegExp(r'^\s*\d+\.\s*', multiLine: true),
            '') // Remove numbered lists
        .replaceAll(
            RegExp(r'\n\s*\n'), '\n\n') // Clean up excessive line breaks
        .replaceAll(RegExp(r'[^\w\s.,!?;:()\-\n]'),
            '') // Keep only alphanumeric, basic punctuation, and newlines
        .trim();
  }

  // Method to remove special characters from names (for documentation/sources)
  String _removeSpecialCharactersFromName(String name) {
    // Remove special characters from names while preserving spaces and basic punctuation
    return name
        .replaceAll(
            RegExp(r'[*_~`#\[\]{}|\\]'), '') // Remove markdown characters
        .replaceAll(RegExp(r'[^\w\s.,!?;:()\-&]'),
            '') // Keep alphanumeric, spaces, and basic punctuation
        .replaceAll(
            RegExp(r'\s+'), ' ') // Replace multiple spaces with single space
        .trim();
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
        actions: [
          // Share button
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              Get.snackbar(
                'Share',
                'Sharing functionality will be implemented soon!',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
          // Bookmark button
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {
              Get.snackbar(
                'Bookmark',
                'Content saved to bookmarks',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        // Show loading indicator
        if (techGuideController.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                Text(
                  'Loading information about $category...',
                  style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          );
        }

        // Show error message if any
        if (techGuideController.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error: ${techGuideController.errorMessage.value}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    techGuideController.fetchTechGuideData(category, prompt);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          );
        }

        // Show data if available
        if (techGuideController.response.value != null) {
          final TechGuideResponse response =
              techGuideController.response.value!;

          return CustomScrollView(
            slivers: [
              // Sticky header with tabs
              // SliverAppBar(
              //   pinned: true,
              //   automaticallyImplyLeading: false,
              //   backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              //   title: _buildTabBar(context),
              // ),

              // Content section
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Main content
                    Card(
                      color: Colors.white,
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Heading
                            Text(
                              'About $category in $profession',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Main content text - REPLACED SelectableText with TextField and removed special characters
                            TextField(
                              controller: TextEditingController(
                                  text: _removeSpecialCharacters(
                                      response.mainContent)),
                              maxLines: null, // Allows multiple lines
                              readOnly:
                                  false, // Set to true if you want it read-only
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(2.0),
                              ),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Version information section in a table
                    if (response.versionDetails.isNotEmpty) ...[
                      const Text(
                        'Latest Versions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        elevation: 2,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4.0),
                          child: _buildVersionTable(response.versionDetails),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Sources section in a table
                    if (response.sources.isNotEmpty) ...[
                      const Text(
                        'Sources',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        elevation: 2,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4.0),
                          child: _buildSourcesTable(
                            response.sources,
                            onTap: (url) => _launchUrl(url),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Documentation links section in a table
                    if (response.documentationLinks.isNotEmpty) ...[
                      const Text(
                        'Documentation',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        elevation: 2,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4.0),
                          child: _buildSourcesTable(
                            response.documentationLinks,
                            onTap: (url) => _launchUrl(url),
                            isDocumentation: true,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Feedback section
                    _buildFeedbackSection(),
                  ]),
                ),
              ),
            ],
          );
        }

        // Fallback (should not reach here)
        return const Center(child: Text('No data available.'));
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Refresh data
          techGuideController.fetchTechGuideData(category, prompt);
        },
        icon: const Icon(Icons.refresh),
        label: const Text('Refresh'),
      ),
    );
  }

  // Build tab bar for navigation
  // Widget _buildTabBar(BuildContext context) {
  //   return SingleChildScrollView(
  //     scrollDirection: Axis.horizontal,
  //     child: Row(
  //       children: [
  //         _buildTab(
  //           label: 'Overview',
  //           icon: Icons.info_outline,
  //           isActive: true,
  //           onTap: () {},
  //         ),
  //         _buildTab(
  //           label: 'Versions',
  //           icon: Icons.new_releases_outlined,
  //           isActive: false,
  //           onTap: () {},
  //         ),
  //         _buildTab(
  //           label: 'Sources',
  //           icon: Icons.source_outlined,
  //           isActive: false,
  //           onTap: () {},
  //         ),
  //         _buildTab(
  //           label: 'Docs',
  //           icon: Icons.menu_book_outlined,
  //           isActive: false,
  //           onTap: () {},
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Build single tab
  Widget _buildTab({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? Colors.deepPurple.shade50 : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive ? Colors.deepPurple : Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: isActive ? Colors.deepPurple : Colors.grey.shade600,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive ? Colors.deepPurple : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build version table
  Widget _buildVersionTable(List<VersionInfo> versions) {
    return Table(
      border: TableBorder.all(
        color: Colors.grey.shade300,
        width: 1,
      ),
      columnWidths: const {
        0: IntrinsicColumnWidth(),
        1: FlexColumnWidth(3),
        2: FlexColumnWidth(2),
        3: FlexColumnWidth(3),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        // Table header
        TableRow(
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
          ),
          children: [
            _buildTableHeaderCell('#'),
            _buildTableHeaderCell('Technology'),
            _buildTableHeaderCell('Version'),
            _buildTableHeaderCell('Release Date'),
          ],
        ),
        // Table rows for each version
        ...List.generate(
          versions.length,
          (index) => TableRow(
            decoration: index % 2 == 0
                ? BoxDecoration(color: Colors.grey.shade50)
                : null,
            children: [
              // Index number
              TableCell(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              // Technology name
              TableCell(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    versions[index].technology,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Version number
              TableCell(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    versions[index].version,
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Release date
              TableCell(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    versions[index].releaseDate.isNotEmpty
                        ? versions[index].releaseDate
                        : 'Not specified',
                    style: TextStyle(
                      fontStyle: versions[index].releaseDate.isNotEmpty
                          ? FontStyle.normal
                          : FontStyle.italic,
                      color: versions[index].releaseDate.isNotEmpty
                          ? Colors.black
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Build sources/documentation table
  Widget _buildSourcesTable(
    List<dynamic> sources, {
    required Function(String) onTap,
    bool isDocumentation = false,
  }) {
    return Table(
      border: TableBorder.all(
        color: Colors.grey.shade300,
        width: 1,
      ),
      columnWidths: const {
        0: IntrinsicColumnWidth(),
        1: FlexColumnWidth(5),
        2: FlexColumnWidth(2),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        // Table header
        TableRow(
          decoration: BoxDecoration(
            color: isDocumentation ? Colors.green.shade50 : Colors.blue.shade50,
          ),
          children: [
            _buildTableHeaderCell('#'),
            _buildTableHeaderCell('Name'),
            _buildTableHeaderCell('Action'),
          ],
        ),
        // Table rows for each source
        ...List.generate(
          sources.length,
          (index) => TableRow(
            decoration: index % 2 == 0
                ? BoxDecoration(color: Colors.grey.shade50)
                : null,
            children: [
              // Index number
              TableCell(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              // Source/Documentation name
              TableCell(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _removeSpecialCharactersFromName(sources[index].name),
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              // Open link button
              TableCell(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: ElevatedButton.icon(
                      onPressed: sources[index].url.isNotEmpty
                          ? () => onTap(sources[index].url)
                          : null,
                      icon: Icon(
                        isDocumentation ? Icons.menu_book : Icons.link,
                        size: 16,
                      ),
                      label: const Text('Open'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDocumentation
                            ? Colors.green.shade100
                            : Colors.blue.shade100,
                        foregroundColor: isDocumentation
                            ? Colors.green.shade800
                            : Colors.blue.shade800,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 0,
                        ),
                        minimumSize: const Size(60, 30),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Build a table header cell
  Widget _buildTableHeaderCell(String text) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // Build feedback section
  Widget _buildFeedbackSection() {
    return Card(
      elevation: 2,
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.feedback, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Was this helpful?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.thumb_up_alt_outlined,
                      color: Colors.green),
                  onPressed: () {
                    Get.snackbar(
                      'Thank You!',
                      'We appreciate your feedback',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.thumb_down_alt_outlined,
                      color: Colors.red),
                  onPressed: () {
                    _showFeedbackDialog();
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                Get.dialog(
                  AlertDialog(
                    title: const Text('Ask a Follow-up Question'),
                    content: const TextField(
                      decoration: InputDecoration(
                        hintText: 'Type your question here...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Get.back();
                          Get.snackbar(
                            'Question Submitted',
                            'We\'ll get back to you soon!',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                        child: const Text('Submit'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.question_answer),
              label: const Text('Ask a Follow-up Question'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(40),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show feedback dialog
  void _showFeedbackDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('What could we improve?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFeedbackOption('Information is not accurate'),
            _buildFeedbackOption('Not enough details'),
            _buildFeedbackOption('Too much information'),
            _buildFeedbackOption('Missing sources'),
            _buildFeedbackOption('Other issues'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Feedback Submitted',
                'Thank you for helping us improve!',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  // Build feedback option
  Widget _buildFeedbackOption(String text) {
    return CheckboxListTile(
      title: Text(text),
      value: false,
      onChanged: (value) {},
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}
