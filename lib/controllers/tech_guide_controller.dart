import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:firebaseproject/models/tech_guide_response.dart';

class TechGuideController extends GetxController {
  // Observable variables
  final Rx<TechGuideResponse?> response = Rx<TechGuideResponse?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // API key (Consider using environment variables or secure storage in production)
  final String apiKey =
      "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";
  final String apiUrl = "https://api.groq.com/openai/v1/chat/completions";

  // Fetch data from the API
  Future<void> fetchTechGuideData(String category, String prompt) async {
    isLoading.value = true;
    errorMessage.value = '';
    response.value = null;

    try {
      // First request to get the main content
      final apiResponse = await http.post(
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

      if (apiResponse.statusCode == 200) {
        final data = jsonDecode(apiResponse.body);
        final responseMessage = data['choices'][0]['message']['content'];

        // Parse the response
        final parsedResponse =
            TechGuideResponse.fromRawResponse(responseMessage);

        // If no sources or documentation links were found, make another request
        if (parsedResponse.sources.isEmpty ||
            parsedResponse.documentationLinks.isEmpty) {
          await _fetchSourcesAndDocs(category, prompt, parsedResponse);
        } else {
          response.value = parsedResponse;
          isLoading.value = false;
        }
      } else if (apiResponse.statusCode == 401) {
        errorMessage.value =
            "Error 401: Unauthorized - Check your API key and permissions.";
        isLoading.value = false;
      } else {
        errorMessage.value =
            'Error ${apiResponse.statusCode}: ${apiResponse.reasonPhrase}';
        isLoading.value = false;
      }
    } catch (e) {
      errorMessage.value = 'Error during API call: $e';
      isLoading.value = false;
    }
  }

  // Fetch sources, documentation links, and version information separately
  Future<void> _fetchSourcesAndDocs(
      String category, String prompt, TechGuideResponse initialResponse) async {
    try {
      final apiResponse = await http.post(
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

      if (apiResponse.statusCode == 200) {
        final data = jsonDecode(apiResponse.body);
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

        response.value = combinedResponse;
      } else {
        // If secondary request fails, just use what we have
        response.value = initialResponse;
      }
    } catch (e) {
      // If secondary request fails, just use what we have
      response.value = initialResponse;
    } finally {
      isLoading.value = false;
    }
  }

  // Clear response data
  void clearData() {
    response.value = null;
    errorMessage.value = '';
  }
}
