import 'package:firebaseproject/controllers/tech_guide_controller.dart';
import 'package:firebaseproject/models/tech_guide_response.dart';
import 'package:firebaseproject/models/version_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DataDisplayScreen extends StatefulWidget {
  final String profession;
  final String category;
  final String prompt;

  const DataDisplayScreen({
    super.key,
    required this.profession,
    required this.category,
    required this.prompt,
  });

  @override
  State<DataDisplayScreen> createState() => _DataDisplayScreenState();
}

class _DataDisplayScreenState extends State<DataDisplayScreen> {
  // Real-time version data controller
  final RxList<VersionInfo> realTimeVersions = <VersionInfo>[].obs;
  final RxBool isLoadingVersions = false.obs;
  final RxString versionErrorMessage = ''.obs;

  @override
  void initState() {
    super.initState();
    // Fetch real-time version data when screen loads
    _fetchRealTimeVersions();
  }

  // Fetch real-time version information from various APIs
  Future<void> _fetchRealTimeVersions() async {
    isLoadingVersions.value = true;
    versionErrorMessage.value = '';
    realTimeVersions.clear();

    try {
      final List<VersionInfo> versions = [];

      // Based on category, fetch relevant version information
      switch (widget.category.toLowerCase()) {
        case 'javascript':
          versions.addAll(await _fetchJavaScriptVersions());
          break;
        case 'css':
          versions.addAll(await _fetchCSSVersions());
          break;
        case 'html':
          versions.addAll(await _fetchHTMLVersions());
          break;
        case 'frameworks':
          versions.addAll(await _fetchFrameworkVersions());
          break;
        case 'node.js':
        case 'nodejs':
          versions.addAll(await _fetchNodeJSVersions());
          break;
        case 'python':
          versions.addAll(await _fetchPythonVersions());
          break;
        case 'databases':
          versions.addAll(await _fetchDatabaseVersions());
          break;
        case 'tools':
          versions.addAll(await _fetchDevelopmentToolVersions());
          break;
        default:
          versions.addAll(await _fetchGeneralVersions());
      }

      realTimeVersions.assignAll(versions);
    } catch (e) {
      versionErrorMessage.value = 'Failed to fetch real-time version data: $e';
      print('Error fetching versions: $e');
    } finally {
      isLoadingVersions.value = false;
    }
  }

  // Fetch JavaScript ecosystem versions
  Future<List<VersionInfo>> _fetchJavaScriptVersions() async {
    final List<VersionInfo> versions = [];

    try {
      // Fetch Node.js versions from official API
      final nodeResponse = await http.get(
        Uri.parse('https://nodejs.org/dist/index.json'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (nodeResponse.statusCode == 200) {
        final nodeData = jsonDecode(nodeResponse.body) as List;
        if (nodeData.isNotEmpty) {
          final latestNode = nodeData.first;
          versions.add(VersionInfo(
            technology: 'Node.js',
            version: latestNode['version']?.toString().replaceFirst('v', '') ??
                'Unknown',
            releaseDate: latestNode['date']?.toString() ?? '',
            additionalInfo: 'LTS: ${latestNode['lts'] ?? 'No'}',
          ));
        }
      }

      // Fetch npm versions
      final npmResponse = await http.get(
        Uri.parse('https://registry.npmjs.org/npm/latest'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (npmResponse.statusCode == 200) {
        final npmData = jsonDecode(npmResponse.body);
        versions.add(VersionInfo(
          technology: 'npm',
          version: npmData['version']?.toString() ?? 'Unknown',
          releaseDate: npmData['time']?[npmData['version']]?.toString() ?? '',
          additionalInfo: 'Package Manager',
        ));
      }

      // Fetch TypeScript versions
      final tsResponse = await http.get(
        Uri.parse('https://registry.npmjs.org/typescript/latest'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (tsResponse.statusCode == 200) {
        final tsData = jsonDecode(tsResponse.body);
        versions.add(VersionInfo(
          technology: 'TypeScript',
          version: tsData['version']?.toString() ?? 'Unknown',
          releaseDate: tsData['time']?[tsData['version']]?.toString() ?? '',
          additionalInfo: 'Superset of JavaScript',
        ));
      }
    } catch (e) {
      print('Error fetching JavaScript versions: $e');
    }

    return versions;
  }

  // Fetch Framework versions
  Future<List<VersionInfo>> _fetchFrameworkVersions() async {
    final List<VersionInfo> versions = [];

    try {
      // Popular frameworks to check
      final frameworks = [
        'react',
        'vue',
        '@angular/core',
        'svelte',
        'next',
        'nuxt',
        'express',
      ];

      for (final framework in frameworks) {
        try {
          final response = await http.get(
            Uri.parse('https://registry.npmjs.org/$framework/latest'),
            headers: {'Accept': 'application/json'},
          ).timeout(const Duration(seconds: 8));

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            final frameworkName = framework.contains('/')
                ? framework.split('/').last.toUpperCase()
                : _capitalizeString(framework);

            versions.add(VersionInfo(
              technology: frameworkName,
              version: data['version']?.toString() ?? 'Unknown',
              releaseDate: data['time']?[data['version']]?.toString() ?? '',
              additionalInfo:
                  data['description']?.toString().split('.').first ?? '',
            ));
          }
        } catch (e) {
          print('Error fetching $framework version: $e');
        }
      }
    } catch (e) {
      print('Error fetching framework versions: $e');
    }

    return versions;
  }

  // Fetch Node.js ecosystem versions
  Future<List<VersionInfo>> _fetchNodeJSVersions() async {
    final List<VersionInfo> versions = [];

    try {
      // Node.js versions (same as JavaScript but more detailed)
      final nodeResponse = await http.get(
        Uri.parse('https://nodejs.org/dist/index.json'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (nodeResponse.statusCode == 200) {
        final nodeData = jsonDecode(nodeResponse.body) as List;

        // Get latest LTS and current
        final latestLTS = nodeData.firstWhere((node) => node['lts'] != false,
            orElse: () => nodeData.first);

        versions.add(VersionInfo(
          technology: 'Node.js (Current)',
          version:
              nodeData.first['version']?.toString().replaceFirst('v', '') ??
                  'Unknown',
          releaseDate: nodeData.first['date']?.toString() ?? '',
          additionalInfo: 'Latest Release',
        ));

        if (latestLTS['version'] != nodeData.first['version']) {
          versions.add(VersionInfo(
            technology: 'Node.js (LTS)',
            version: latestLTS['version']?.toString().replaceFirst('v', '') ??
                'Unknown',
            releaseDate: latestLTS['date']?.toString() ?? '',
            additionalInfo: 'Long Term Support: ${latestLTS['lts']}',
          ));
        }
      }

      // Popular Node.js packages
      final packages = ['express', 'lodash', 'axios', 'moment', 'uuid'];

      for (final package in packages) {
        try {
          final response = await http.get(
            Uri.parse('https://registry.npmjs.org/$package/latest'),
            headers: {'Accept': 'application/json'},
          ).timeout(const Duration(seconds: 8));

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            versions.add(VersionInfo(
              technology: _capitalizeString(package),
              version: data['version']?.toString() ?? 'Unknown',
              releaseDate: data['time']?[data['version']]?.toString() ?? '',
              additionalInfo:
                  data['description']?.toString().split('.').first ?? '',
            ));
          }
        } catch (e) {
          print('Error fetching $package version: $e');
        }
      }
    } catch (e) {
      print('Error fetching Node.js versions: $e');
    }

    return versions;
  }

  // Fetch Python versions
  Future<List<VersionInfo>> _fetchPythonVersions() async {
    final List<VersionInfo> versions = [];

    try {
      // Python releases from GitHub API
      final pythonResponse = await http.get(
        Uri.parse(
            'https://api.github.com/repos/python/cpython/releases/latest'),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      ).timeout(const Duration(seconds: 10));

      if (pythonResponse.statusCode == 200) {
        final pythonData = jsonDecode(pythonResponse.body);
        versions.add(VersionInfo(
          technology: 'Python',
          version: pythonData['tag_name']?.toString().replaceFirst('v', '') ??
              'Unknown',
          releaseDate: pythonData['published_at']?.toString() ?? '',
          additionalInfo: 'Official CPython Release',
        ));
      }

      // Popular Python packages from PyPI
      final packages = ['django', 'flask', 'requests', 'numpy', 'pandas'];

      for (final package in packages) {
        try {
          final response = await http.get(
            Uri.parse('https://pypi.org/pypi/$package/json'),
            headers: {'Accept': 'application/json'},
          ).timeout(const Duration(seconds: 8));

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            final info = data['info'];
            versions.add(VersionInfo(
              technology: _capitalizeString(package),
              version: info['version']?.toString() ?? 'Unknown',
              releaseDate: '', // PyPI doesn't provide easy release date access
              additionalInfo:
                  info['summary']?.toString().split('.').first ?? '',
            ));
          }
        } catch (e) {
          print('Error fetching $package version: $e');
        }
      }
    } catch (e) {
      print('Error fetching Python versions: $e');
    }

    return versions;
  }

  // Fetch Database versions
  Future<List<VersionInfo>> _fetchDatabaseVersions() async {
    final List<VersionInfo> versions = [];

    try {
      // MongoDB versions from GitHub
      final mongoResponse = await http.get(
        Uri.parse('https://api.github.com/repos/mongodb/mongo/releases/latest'),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      ).timeout(const Duration(seconds: 10));

      if (mongoResponse.statusCode == 200) {
        final mongoData = jsonDecode(mongoResponse.body);
        versions.add(VersionInfo(
          technology: 'MongoDB',
          version: mongoData['tag_name']?.toString().replaceFirst('r', '') ??
              'Unknown',
          releaseDate: mongoData['published_at']?.toString() ?? '',
          additionalInfo: 'Document Database',
        ));
      }

      // PostgreSQL versions from GitHub
      final pgResponse = await http.get(
        Uri.parse(
            'https://api.github.com/repos/postgres/postgres/releases/latest'),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      ).timeout(const Duration(seconds: 10));

      if (pgResponse.statusCode == 200) {
        final pgData = jsonDecode(pgResponse.body);
        versions.add(VersionInfo(
          technology: 'PostgreSQL',
          version: pgData['tag_name']
                  ?.toString()
                  .replaceAll(RegExp(r'[REL_]'), '')
                  .replaceAll('_', '.') ??
              'Unknown',
          releaseDate: pgData['published_at']?.toString() ?? '',
          additionalInfo: 'Relational Database',
        ));
      }

      // Redis from GitHub
      final redisResponse = await http.get(
        Uri.parse('https://api.github.com/repos/redis/redis/releases/latest'),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      ).timeout(const Duration(seconds: 10));

      if (redisResponse.statusCode == 200) {
        final redisData = jsonDecode(redisResponse.body);
        versions.add(VersionInfo(
          technology: 'Redis',
          version: redisData['tag_name']?.toString() ?? 'Unknown',
          releaseDate: redisData['published_at']?.toString() ?? '',
          additionalInfo: 'In-Memory Data Store',
        ));
      }
    } catch (e) {
      print('Error fetching database versions: $e');
    }

    return versions;
  }

  // Fetch Development Tools versions
  Future<List<VersionInfo>> _fetchDevelopmentToolVersions() async {
    final List<VersionInfo> versions = [];

    try {
      // Git from GitHub
      final gitResponse = await http.get(
        Uri.parse('https://api.github.com/repos/git/git/releases/latest'),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      ).timeout(const Duration(seconds: 10));

      if (gitResponse.statusCode == 200) {
        final gitData = jsonDecode(gitResponse.body);
        versions.add(VersionInfo(
          technology: 'Git',
          version: gitData['tag_name']?.toString().replaceFirst('v', '') ??
              'Unknown',
          releaseDate: gitData['published_at']?.toString() ?? '',
          additionalInfo: 'Version Control System',
        ));
      }

      // Docker from GitHub
      final dockerResponse = await http.get(
        Uri.parse(
            'https://api.github.com/repos/docker/docker-ce/releases/latest'),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      ).timeout(const Duration(seconds: 10));

      if (dockerResponse.statusCode == 200) {
        final dockerData = jsonDecode(dockerResponse.body);
        versions.add(VersionInfo(
          technology: 'Docker',
          version: dockerData['tag_name']?.toString().replaceFirst('v', '') ??
              'Unknown',
          releaseDate: dockerData['published_at']?.toString() ?? '',
          additionalInfo: 'Containerization Platform',
        ));
      }

      // VS Code from GitHub
      final vscodeResponse = await http.get(
        Uri.parse(
            'https://api.github.com/repos/microsoft/vscode/releases/latest'),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      ).timeout(const Duration(seconds: 10));

      if (vscodeResponse.statusCode == 200) {
        final vscodeData = jsonDecode(vscodeResponse.body);
        versions.add(VersionInfo(
          technology: 'VS Code',
          version: vscodeData['tag_name']?.toString() ?? 'Unknown',
          releaseDate: vscodeData['published_at']?.toString() ?? '',
          additionalInfo: 'Code Editor',
        ));
      }
    } catch (e) {
      print('Error fetching development tool versions: $e');
    }

    return versions;
  }

  // Fetch CSS-related versions
  Future<List<VersionInfo>> _fetchCSSVersions() async {
    final List<VersionInfo> versions = [];

    try {
      // CSS preprocessors and tools
      final tools = ['sass', 'less', 'postcss', 'autoprefixer', 'tailwindcss'];

      for (final tool in tools) {
        try {
          final response = await http.get(
            Uri.parse('https://registry.npmjs.org/$tool/latest'),
            headers: {'Accept': 'application/json'},
          ).timeout(const Duration(seconds: 8));

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            versions.add(VersionInfo(
              technology: tool.toUpperCase(),
              version: data['version']?.toString() ?? 'Unknown',
              releaseDate: data['time']?[data['version']]?.toString() ?? '',
              additionalInfo:
                  data['description']?.toString().split('.').first ?? '',
            ));
          }
        } catch (e) {
          print('Error fetching $tool version: $e');
        }
      }

      // Add CSS specification info (static but useful)
      versions.add(VersionInfo(
        technology: 'CSS',
        version: '3 + CSS4 (modules)',
        releaseDate: 'Ongoing',
        additionalInfo: 'W3C Specification',
      ));
    } catch (e) {
      print('Error fetching CSS versions: $e');
    }

    return versions;
  }

  // Fetch HTML-related versions
  Future<List<VersionInfo>> _fetchHTMLVersions() async {
    final List<VersionInfo> versions = [];

    // HTML specifications (mostly static but current)
    versions.add(VersionInfo(
      technology: 'HTML',
      version: '5.3 (Living Standard)',
      releaseDate: 'Ongoing updates',
      additionalInfo: 'WHATWG Living Standard',
    ));

    try {
      // HTML-related tools
      final tools = ['html-webpack-plugin', 'html-minifier', 'prettier'];

      for (final tool in tools) {
        try {
          final response = await http.get(
            Uri.parse('https://registry.npmjs.org/$tool/latest'),
            headers: {'Accept': 'application/json'},
          ).timeout(const Duration(seconds: 8));

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            String toolName = tool
                .split('-')
                .map((word) => _capitalizeString(word))
                .join(' ');

            versions.add(VersionInfo(
              technology: toolName,
              version: data['version']?.toString() ?? 'Unknown',
              releaseDate: data['time']?[data['version']]?.toString() ?? '',
              additionalInfo:
                  data['description']?.toString().split('.').first ?? '',
            ));
          }
        } catch (e) {
          print('Error fetching $tool version: $e');
        }
      }
    } catch (e) {
      print('Error fetching HTML tool versions: $e');
    }

    return versions;
  }

  // Fetch general technology versions
  Future<List<VersionInfo>> _fetchGeneralVersions() async {
    final List<VersionInfo> versions = [];

    try {
      // Browser versions from GitHub
      final browsers = [
        {'repo': 'chromium/chromium', 'name': 'Chromium'},
        {'repo': 'mozilla/gecko-dev', 'name': 'Firefox'},
      ];

      for (final browser in browsers) {
        try {
          final response = await http.get(
            Uri.parse(
                'https://api.github.com/repos/${browser['repo']}/releases/latest'),
            headers: {'Accept': 'application/vnd.github.v3+json'},
          ).timeout(const Duration(seconds: 10));

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            versions.add(VersionInfo(
              technology: browser['name']!,
              version: data['tag_name']?.toString() ?? 'Unknown',
              releaseDate: data['published_at']?.toString() ?? '',
              additionalInfo: 'Web Browser',
            ));
          }
        } catch (e) {
          print('Error fetching ${browser['name']} version: $e');
        }
      }
    } catch (e) {
      print('Error fetching general versions: $e');
    }

    return versions;
  }

  // Helper method to capitalize strings (replaces extension to avoid conflicts)
  String _capitalizeString(String text) {
    if (text.isEmpty) return text;
    return "${text[0].toUpperCase()}${text.substring(1)}";
  }

  // Format date helper
  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Unknown';

    try {
      final date = DateTime.parse(dateString);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString.split('T').first; // Try to extract date part
    }
  }

  // Launch URL method with better error handling
  Future<void> _launchUrl(String url) async {
    if (url.isEmpty) {
      Get.snackbar(
        'Error',
        'No URL provided',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      final Uri uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch URL');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not open link: $url',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Method to clean and format text content
  String _cleanContent(String text) {
    // Remove excessive special characters while preserving readability
    return text
        .replaceAll(RegExp(r'\*{2,}'), '') // Remove multiple asterisks
        .replaceAll(RegExp(r'_{2,}'), '') // Remove multiple underscores
        .replaceAll(RegExp(r'#{1,6}\s*'), '') // Remove markdown headers
        .replaceAll(RegExp(r'```[\s\S]*?```'), '') // Remove code blocks
        .replaceAllMapped(RegExp(r'`([^`]*)`'),
            (match) => match.group(1) ?? '') // Remove inline code formatting
        .replaceAllMapped(RegExp(r'\*([^*]*)\*'),
            (match) => match.group(1) ?? '') // Remove italic asterisks
        .replaceAllMapped(RegExp(r'_([^_]*)_'),
            (match) => match.group(1) ?? '') // Remove italic underscores
        .replaceAllMapped(RegExp(r'\*\*([^*]*)\*\*'),
            (match) => match.group(1) ?? '') // Remove bold asterisks
        .replaceAllMapped(RegExp(r'__([^_]*)__'),
            (match) => match.group(1) ?? '') // Remove bold underscores
        .replaceAll(RegExp(r'^\s*[-*+]\s+', multiLine: true),
            '• ') // Convert list items to bullets
        .replaceAll(RegExp(r'^\s*\d+\.\s+', multiLine: true),
            '') // Remove numbered lists
        .replaceAll(
            RegExp(r'\n\s*\n\s*\n'), '\n\n') // Clean up excessive line breaks
        .trim();
  }

  // Method to remove special characters from names (for documentation/sources)
  String _cleanName(String name) {
    return name
        .replaceAll(RegExp(r'[*_~`#\[\]{}|\\]'), '')
        .replaceAll(RegExp(r'[^\w\s.,!?;:()\-&]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    final techGuideController = Get.find<TechGuideController>();

    // Fetch data when the screen loads
    techGuideController.fetchTechGuideData(widget.category, widget.prompt);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.profession} - ${widget.category}'),
        actions: [
          // Refresh versions button
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Version Data',
            onPressed: () {
              _fetchRealTimeVersions();
              Get.snackbar(
                'Refreshing',
                'Fetching latest version information...',
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(seconds: 2),
              );
            },
          ),
          // Share button
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Copy content to clipboard
              _copyToClipboard(techGuideController);
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
                  'Loading information about ${widget.category}...',
                  style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                if (isLoadingVersions.value) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Fetching real-time version data...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'Error: ${techGuideController.errorMessage.value}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    techGuideController.fetchTechGuideData(
                        widget.category, widget.prompt);
                    _fetchRealTimeVersions();
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
                              'About ${widget.category} in ${widget.profession}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Main content text
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: SelectableText(
                                _cleanContent(response.mainContent),
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ENHANCED Real-time Version information section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Latest Versions',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                            if (isLoadingVersions.value)
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                          ],
                        ),
                        if (versionErrorMessage.value.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.warning,
                                    color: Colors.red.shade600, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    versionErrorMessage.value,
                                    style: TextStyle(
                                      color: Colors.red.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Card(
                          elevation: 2,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4.0),
                            child: realTimeVersions.isNotEmpty
                                ? _buildEnhancedVersionTable(realTimeVersions)
                                : response.versionDetails.isNotEmpty
                                    ? _buildVersionTable(
                                        response.versionDetails)
                                    : Container(
                                        padding: const EdgeInsets.all(32),
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.info_outline,
                                              color: Colors.grey.shade400,
                                              size: 48,
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'No version information available',
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            ElevatedButton.icon(
                                              onPressed: _fetchRealTimeVersions,
                                              icon: const Icon(Icons.refresh,
                                                  size: 16),
                                              label:
                                                  const Text('Fetch Versions'),
                                              style: ElevatedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 8),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Sources section in a table
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Sources',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            // Debug info badge
                            if (response.sources.isEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'AI Generated',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.orange.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Card(
                          elevation: 2,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4.0),
                            child: response.sources.isNotEmpty
                                ? _buildSourcesTable(
                                    response.sources,
                                    onTap: (url) => _launchUrl(url),
                                  )
                                : _buildEmptySourcesTable(),
                          ),
                        ),
                      ],
                    ),

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

                    // Extra padding at bottom
                    const SizedBox(height: 100),
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
          techGuideController.fetchTechGuideData(
              widget.category, widget.prompt);
          _fetchRealTimeVersions();
        },
        icon: const Icon(Icons.refresh),
        label: const Text('Refresh All'),
      ),
    );
  }

  // Copy content to clipboard
  void _copyToClipboard(TechGuideController controller) {
    if (controller.response.value != null) {
      final content = _cleanContent(controller.response.value!.mainContent);
      Clipboard.setData(ClipboardData(text: content));
      Get.snackbar(
        'Copied',
        'Content copied to clipboard',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  // Build enhanced version table with real-time data
  Widget _buildEnhancedVersionTable(List<VersionInfo> versions) {
    return Table(
      border: TableBorder.all(
        color: Colors.grey.shade300,
        width: 1,
      ),
      columnWidths: const {
        0: IntrinsicColumnWidth(),
        1: FlexColumnWidth(3),
        2: FlexColumnWidth(2),
        3: FlexColumnWidth(2),
        4: FlexColumnWidth(3),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        // Table header
        TableRow(
          decoration: BoxDecoration(
            color: Colors.green.shade50,
          ),
          children: [
            _buildTableHeaderCell('#'),
            _buildTableHeaderCell('Technology'),
            _buildTableHeaderCell('Version'),
            _buildTableHeaderCell('Release Date'),
            _buildTableHeaderCell('Details'),
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
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Technology name
              TableCell(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _cleanName(versions[index].technology),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Version number
              TableCell(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Text(
                      versions[index].version,
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
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
                        ? _formatDate(versions[index].releaseDate)
                        : 'Unknown',
                    style: TextStyle(
                      fontStyle: versions[index].releaseDate.isNotEmpty
                          ? FontStyle.normal
                          : FontStyle.italic,
                      color: versions[index].releaseDate.isNotEmpty
                          ? Colors.black87
                          : Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              // Additional info
              TableCell(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    versions[index].additionalInfo.isNotEmpty
                        ? versions[index].additionalInfo
                        : 'Live data',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Build regular version table (fallback)
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
                    _cleanName(versions[index].technology),
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

  // Build empty sources table when no sources are available
  Widget _buildEmptySourcesTable() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.library_books_outlined,
            color: Colors.blue.shade300,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'No External Sources Available',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This information was generated using AI knowledge.\nFor additional sources, try asking more specific questions.',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  _showSourceSuggestionDialog();
                },
                icon: const Icon(Icons.search, size: 16),
                label: const Text('Suggest Sources'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade50,
                  foregroundColor: Colors.blue.shade700,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () {
                  _showManualSourceDialog();
                },
                icon: const Icon(Icons.add_link, size: 16),
                label: const Text('Add Source'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue.shade700,
                  side: BorderSide(color: Colors.blue.shade200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Show dialog to suggest finding sources
  void _showSourceSuggestionDialog() {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.lightbulb_outline, color: Colors.orange),
            const SizedBox(width: 8),
            const Text('Find Reliable Sources'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('To find authoritative sources for this topic, try:'),
            const SizedBox(height: 12),
            _buildSuggestionItem(
              Icons.school,
              'Official Documentation',
              'Search for official docs from ${widget.category} creators',
            ),
            const SizedBox(height: 8),
            _buildSuggestionItem(
              Icons.article,
              'Research Papers',
              'Look for academic papers on Google Scholar',
            ),
            const SizedBox(height: 8),
            _buildSuggestionItem(
              Icons.business,
              'Industry Reports',
              'Check industry blogs and tech company publications',
            ),
            const SizedBox(height: 8),
            _buildSuggestionItem(
              Icons.forum,
              'Community Resources',
              'Explore Stack Overflow, Reddit, and dev communities',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Got it'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _launchUrl(
                  'https://scholar.google.com/scholar?q=${widget.category}+${widget.profession}');
            },
            child: const Text('Search Scholar'),
          ),
        ],
      ),
    );
  }

  // Build suggestion item for the dialog
  Widget _buildSuggestionItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(icon, size: 16, color: Colors.blue.shade600),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Show dialog to manually add a source
  void _showManualSourceDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController urlController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Add External Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Source Name',
                hintText: 'e.g., Official React Documentation',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'URL (optional)',
                hintText: 'https://example.com',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Note: This will only open the URL in your browser',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final url = urlController.text.trim();

              if (name.isNotEmpty) {
                Get.back();
                if (url.isNotEmpty) {
                  _launchUrl(url);
                } else {
                  // Search for the source name
                  final searchQuery =
                      '$name ${widget.category} ${widget.profession}';
                  _launchUrl(
                      'https://www.google.com/search?q=${Uri.encodeComponent(searchQuery)}');
                }
              }
            },
            child: const Text('Open/Search'),
          ),
        ],
      ),
    );
  }

  Widget _buildSourcesTable(
    List<dynamic> sources, {
    required Function(String) onTap,
    bool isDocumentation = false,
  }) {
    // Filter out empty or invalid sources
    final validSources = sources.where((source) {
      if (source == null) return false;

      // Check if source has a valid name
      final name = source.name?.toString().trim() ?? '';
      if (name.isEmpty) return false;

      // Additional validation - check if name is not just whitespace or special characters
      if (name.replaceAll(RegExp(r'[^\w\s]'), '').trim().isEmpty) return false;

      return true;
    }).toList();

    // If no valid sources after filtering, show empty state
    if (validSources.isEmpty) {
      return _buildEmptySourcesTable();
    }

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
        // Table rows for each valid source
        ...List.generate(
          validSources.length,
          (index) {
            final source = validSources[index];
            final sourceName =
                _cleanName(source.name?.toString() ?? 'Unknown Source');
            final sourceUrl = source.url?.toString().trim() ?? '';

            return TableRow(
              decoration: index % 2 == 0
                  ? BoxDecoration(color: Colors.grey.shade50)
                  : null,
              children: [
                // Index number
                TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDocumentation
                              ? Colors.green.shade100
                              : Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: isDocumentation
                                ? Colors.green.shade700
                                : Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Source/Documentation name
                TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Icon(
                          isDocumentation ? Icons.menu_book : Icons.link,
                          size: 16,
                          color: isDocumentation
                              ? Colors.green.shade600
                              : Colors.blue.shade600,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            sourceName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Open link button
                TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: sourceUrl.isNotEmpty
                          ? ElevatedButton.icon(
                              onPressed: () => onTap(sourceUrl),
                              icon: Icon(
                                Icons.open_in_new,
                                size: 14,
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
                                  vertical: 4,
                                ),
                                minimumSize: const Size(60, 28),
                                textStyle: const TextStyle(fontSize: 11),
                                elevation: 1,
                              ),
                            )
                          : OutlinedButton.icon(
                              onPressed: () {
                                // Search for the source name if no URL
                                final searchQuery =
                                    '$sourceName ${widget.category} ${widget.profession}';
                                onTap(
                                    'https://www.google.com/search?q=${Uri.encodeComponent(searchQuery)}');
                              },
                              icon: Icon(
                                Icons.search,
                                size: 14,
                              ),
                              label: const Text('Search'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: isDocumentation
                                    ? Colors.green.shade700
                                    : Colors.blue.shade700,
                                side: BorderSide(
                                  color: isDocumentation
                                      ? Colors.green.shade300
                                      : Colors.blue.shade300,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                minimumSize: const Size(60, 28),
                                textStyle: const TextStyle(fontSize: 11),
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            );
          },
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
                _showFollowUpDialog();
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

  // Show follow-up question dialog
  void _showFollowUpDialog() {
    final TextEditingController questionController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Ask a Follow-up Question'),
        content: TextField(
          controller: questionController,
          decoration: const InputDecoration(
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
              final question = questionController.text.trim();
              if (question.isNotEmpty) {
                Get.back();
                // Navigate to new data display with the follow-up question
                Get.to(() => DataDisplayScreen(
                      profession: widget.profession,
                      category: widget.category,
                      prompt: question,
                    ));
              }
            },
            child: const Text('Ask'),
          ),
        ],
      ),
    );
  }

  // Show feedback dialog
  void _showFeedbackDialog() {
    final List<String> feedbackOptions = [
      'Information is not accurate',
      'Not enough details',
      'Too much information',
      'Missing sources',
      'Version data is outdated',
      'Other issues',
    ];

    final List<bool> selectedOptions =
        List.filled(feedbackOptions.length, false);

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('What could we improve?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: feedbackOptions.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;

              return CheckboxListTile(
                title: Text(option),
                value: selectedOptions[index],
                onChanged: (value) {
                  setState(() {
                    selectedOptions[index] = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              );
            }).toList(),
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
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
