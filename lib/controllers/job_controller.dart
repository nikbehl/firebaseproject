import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:firebaseproject/models/job_model.dart';

class JobController extends GetxController {
  // Observable variables
  final RxList<JobModel> jobs = <JobModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // API key (Consider using environment variables or secure storage in production)
  final String apiKey =
      "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";
  final String apiUrl = "https://api.groq.com/openai/v1/chat/completions";

  // Fetch job listings based on profession and category
  Future<void> fetchJobs(String profession, String category) async {
    isLoading.value = true;
    errorMessage.value = '';
    jobs.clear();

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
                  """Generate 5 realistic job listings for $profession specializing in $category.

Each job should include:
- title (specific role related to $profession and $category)
- description (2-3 sentences about the job responsibilities and requirements, mentioning specific skills required)
- company (fictional or real company name)
- salary range (realistic for this type of role)
- experience level (e.g., Entry-level, Mid-level, Senior)
- skills (list of 4-6 technical skills required for this position, specifically relevant to $category)

Format your response as a JSON array with this structure for each job:
{
  "title": "Job Title",
  "description": "Brief job description",
  "company": "Company Name",
  "salary": "Salary Range",
  "experience": "Experience Level",
  "skills": ["Skill1", "Skill2", "Skill3", "Skill4"]
}

Ensure the entire response is a properly formatted JSON array that can be parsed directly."""
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

            // Convert JSON to JobModel objects
            final List<JobModel> jobListings = jsonData
                .map((item) => JobModel(
                      title: item['title'] ?? '',
                      description: item['description'] ?? '',
                      company: item['company'] ?? '',
                      salary: item['salary'] ?? '',
                      experience: item['experience'] ?? '',
                      skills: List<String>.from(item['skills'] ?? []),
                    ))
                .toList();

            // Update jobs list
            jobs.value = jobListings;
          } else {
            throw Exception('Could not parse JSON data from response');
          }
        } catch (e) {
          errorMessage.value = 'Error parsing job data: $e';
        }
      } else if (response.statusCode == 401) {
        errorMessage.value =
            "Error 401: Unauthorized - Check your API key and permissions.";
      } else {
        errorMessage.value =
            'Error ${response.statusCode}: ${response.reasonPhrase}';
      }
    } catch (e) {
      errorMessage.value = 'Error during API call: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Clear job data
  void clearJobs() {
    jobs.clear();
    errorMessage.value = '';
  }
}
