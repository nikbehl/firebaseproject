import 'dart:convert';

import 'package:firebaseproject/modals/tech_guide_response.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class DataDisplayScreen extends StatefulWidget {
  final String profession;
  final String category;
  final String prompt;

  const DataDisplayScreen(
      {super.key,
      required this.profession,
      required this.category,
      required this.prompt});

  @override
  _DataDisplayScreenState createState() => _DataDisplayScreenState();
}

class _DataDisplayScreenState extends State<DataDisplayScreen> {
  bool _isLoading = true;
  late TechGuideResponse _response;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchData(widget.category, widget.prompt);
  }

  // Launch URL method
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  // Replace with actual free chatbot API endpoint and logic
  Future<void> fetchData(String category, String prompt) async {
    setState(() {
      _isLoading = true;
    });

    final String apiKey =
        "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"; // Your API key
    const String apiUrl =
        "https://api.groq.com/openai/v1/chat/completions"; // Correct endpoint for chat completions

    try {
      // First request to get the main content
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey', // Correct format for Groq API key
        },
        body: jsonEncode({
          "model": "gemma2-9b-it", // Or another available model
          "messages": [
            {
              "role": "user",
              "content":
                  """I need comprehensive information about $category related to $prompt. 
              
Please format your response with:
1. Detailed explanation
2. Latest Versions section listing the current versions of all relevant technologies/frameworks mentioned (include version numbers and release dates if available)
3. Sources/References section at the end with links
4. Documentation links section with official documentation for $category technologies mentioned.

Be sure to include actual URLs for both sources and documentation."""
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        // Successful API call
        final data = jsonDecode(response.body);
        print('API Response: $data');
        final responseMessage = data['choices'][0]['message']['content'];

        // Parse the response to extract sources and documentation links
        final parsedResponse =
            TechGuideResponse.fromRawResponse(responseMessage);

        // If no sources or documentation links were found, make another request to get them
        if (parsedResponse.sources.isEmpty ||
            parsedResponse.documentationLinks.isEmpty) {
          // Request specifically for sources and documentation if they weren't in the initial response
          await _fetchSourcesAndDocs(category, prompt, parsedResponse);
        } else {
          setState(() {
            _response = parsedResponse;
            _isLoading = false;
          });
        }
      } else if (response.statusCode == 401) {
        // Unauthorized error (API key issue)
        print('Error 401: Unauthorized - Check your API key and permissions.');
        print(response.body); // Print the error details from the server
        setState(() {
          _errorMessage =
              "Error 401: Unauthorized - Check your API key and permissions.";
          _isLoading = false;
        });
      } else {
        // Other errors
        print('Error ${response.statusCode}: ${response.body}');
        setState(() {
          _errorMessage =
              'Error ${response.statusCode}: ${response.reasonPhrase}';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error during API call: $e');
      setState(() {
        _errorMessage = 'Error during API call: $e';
        _isLoading = false;
      });
    }
  }

  // Method to fetch sources, documentation links, and version information separately
  Future<void> _fetchSourcesAndDocs(
      String category, String prompt, TechGuideResponse initialResponse) async {
    final String apiKey =
        "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"; // Your API key
    const String apiUrl = "https://api.groq.com/openai/v1/chat/completions";

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
                  """Based on the information about $category related to $prompt, 
              please provide:
              
              1. Latest Versions section - List the current versions of all $category technologies and frameworks related to $prompt. Include version numbers and release dates.
              2. A list of 3-5 reliable sources/references with full URLs
              3. A list of 3-5 official documentation links with full URLs for the $category technologies

              Format your response with three clear sections: "Latest Versions:", "Sources:", and "Documentation:". Include actual clickable URLs."""
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final responseMessage = data['choices'][0]['message']['content'];

        // Parse just the sources, documentation, and version sections
        final supplementalResponse =
            TechGuideResponse.fromRawResponse(responseMessage);

        // Combine with the initial response
        final combinedResponse = TechGuideResponse(
          mainContent: initialResponse.mainContent,
          sources: supplementalResponse.sources.isNotEmpty
              ? supplementalResponse.sources
              : initialResponse.sources,
          documentationLinks: supplementalResponse.documentationLinks.isNotEmpty
              ? supplementalResponse.documentationLinks
              : initialResponse.documentationLinks,
          versionDetails: supplementalResponse.versionDetails.isNotEmpty
              ? supplementalResponse.versionDetails
              : initialResponse.versionDetails,
        );

        setState(() {
          _response = combinedResponse;
          _isLoading = false;
        });
      } else {
        // If secondary request fails, just use what we have
        setState(() {
          _response = initialResponse;
          _isLoading = false;
        });
      }
    } catch (e) {
      // If secondary request fails, just use what we have
      setState(() {
        _response = initialResponse;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.profession} - ${widget.category} - Data'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Main content
                        Text(
                          _response.mainContent,
                          style: const TextStyle(fontSize: 16),
                        ),

                        const SizedBox(height: 24),

                        // Version information section
                        if (_response.versionDetails.isNotEmpty) ...[
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
                            _response.versionDetails.length,
                            (index) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${index + 1}. '),
                                  Expanded(
                                    child: _response.versionDetails[index]
                                            .technology.isNotEmpty
                                        ? RichText(
                                            text: TextSpan(
                                              style: const TextStyle(
                                                  color: Colors.black),
                                              children: [
                                                TextSpan(
                                                  text: _response
                                                      .versionDetails[index]
                                                      .technology,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                const TextSpan(text: ': v'),
                                                TextSpan(
                                                    text: _response
                                                        .versionDetails[index]
                                                        .version),
                                                if (_response
                                                    .versionDetails[index]
                                                    .releaseDate
                                                    .isNotEmpty) ...[
                                                  const TextSpan(
                                                      text: ' (Released: '),
                                                  TextSpan(
                                                      text: _response
                                                          .versionDetails[index]
                                                          .releaseDate),
                                                  const TextSpan(text: ')'),
                                                ],
                                              ],
                                            ),
                                          )
                                        : Text(_response.versionDetails[index]
                                            .additionalInfo),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Sources section
                        if (_response.sources.isNotEmpty) ...[
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
                            _response.sources.length,
                            (index) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: InkWell(
                                onTap: _response.sources[index].url.isNotEmpty
                                    ? () =>
                                        _launchUrl(_response.sources[index].url)
                                    : null,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${index + 1}. '),
                                    Expanded(
                                      child: Text(
                                        _response.sources[index].name,
                                        style: TextStyle(
                                          color: _response
                                                  .sources[index].url.isNotEmpty
                                              ? Colors.blue
                                              : null,
                                          decoration: _response
                                                  .sources[index].url.isNotEmpty
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
                        if (_response.documentationLinks.isNotEmpty) ...[
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
                            _response.documentationLinks.length,
                            (index) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: InkWell(
                                onTap: _response.documentationLinks[index].url
                                        .isNotEmpty
                                    ? () => _launchUrl(
                                        _response.documentationLinks[index].url)
                                    : null,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${index + 1}. '),
                                    Expanded(
                                      child: Text(
                                        _response
                                            .documentationLinks[index].name,
                                        style: TextStyle(
                                          color: _response
                                                  .documentationLinks[index]
                                                  .url
                                                  .isNotEmpty
                                              ? Colors.blue
                                              : null,
                                          decoration: _response
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
                ),
    );
  }
}
