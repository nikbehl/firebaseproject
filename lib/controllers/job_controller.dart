import 'dart:convert';
import 'dart:math';
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

  // List of Indian states for random assignment
  final List<String> indianStates = [
    'Delhi',
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
  ];

  // Sample cities for each state (expanded mapping)
  final Map<String, List<String>> stateCities = {
    'Delhi': [
      'New Delhi',
      'Central Delhi',
      'South Delhi',
      'North Delhi',
      'East Delhi',
      'West Delhi'
    ],
    'Maharashtra': [
      'Mumbai',
      'Pune',
      'Nagpur',
      'Nashik',
      'Aurangabad',
      'Thane'
    ],
    'Karnataka': [
      'Bangalore',
      'Mysore',
      'Mangalore',
      'Hubli',
      'Belgaum',
      'Shimoga'
    ],
    'Tamil Nadu': [
      'Chennai',
      'Coimbatore',
      'Madurai',
      'Salem',
      'Tiruchirappalli',
      'Vellore'
    ],
    'Gujarat': [
      'Ahmedabad',
      'Surat',
      'Vadodara',
      'Rajkot',
      'Gandhinagar',
      'Junagadh'
    ],
    'Rajasthan': ['Jaipur', 'Jodhpur', 'Udaipur', 'Kota', 'Ajmer', 'Bikaner'],
    'West Bengal': [
      'Kolkata',
      'Howrah',
      'Durgapur',
      'Asansol',
      'Siliguri',
      'Malda'
    ],
    'Uttar Pradesh': [
      'Lucknow',
      'Kanpur',
      'Agra',
      'Varanasi',
      'Meerut',
      'Allahabad'
    ],
    'Telangana': [
      'Hyderabad',
      'Warangal',
      'Nizamabad',
      'Karimnagar',
      'Khammam',
      'Mahbubnagar'
    ],
    'Kerala': [
      'Kochi',
      'Thiruvananthapuram',
      'Kozhikode',
      'Thrissur',
      'Kannur',
      'Kollam'
    ],
    'Haryana': [
      'Gurugram',
      'Faridabad',
      'Panipat',
      'Ambala',
      'Yamunanagar',
      'Rohtak'
    ],
    'Punjab': [
      'Chandigarh',
      'Ludhiana',
      'Amritsar',
      'Jalandhar',
      'Patiala',
      'Bathinda'
    ],
    'Odisha': [
      'Bhubaneswar',
      'Cuttack',
      'Rourkela',
      'Berhampur',
      'Sambalpur',
      'Puri'
    ],
    'Assam': [
      'Guwahati',
      'Dibrugarh',
      'Silchar',
      'Jorhat',
      'Nagaon',
      'Tinsukia'
    ],
    'Bihar': [
      'Patna',
      'Gaya',
      'Bhagalpur',
      'Muzaffarpur',
      'Purnia',
      'Darbhanga'
    ],
  };

  // Random number generator
  final Random _random = Random();

  // Store the last fetched profession and category to avoid unnecessary refetches
  String? _lastProfession;
  String? _lastCategory;

  // Fetch job listings based on profession and category
  Future<void> fetchJobs(String profession, String category) async {
    // Set loading state immediately
    isLoading.value = true;
    errorMessage.value = '';

    // Check if we already have jobs for this exact profession/category combination
    // Only skip if we have jobs AND it's the same combination AND we're not already loading
    if (_lastProfession == profession &&
        _lastCategory == category &&
        jobs.isNotEmpty) {
      print('Using cached jobs for $profession - $category');
      isLoading.value = false;
      return; // Use cached data
    }

    // Clear jobs if we're fetching a different profession/category combination
    if (_lastProfession != profession || _lastCategory != category) {
      print('Clearing jobs for new combination: $profession - $category');
      jobs.clear();
    }

    // Update tracking variables
    _lastProfession = profession;
    _lastCategory = category;

    print('Fetching new jobs for $profession - $category');

    await _performJobFetch(profession, category);
  }

  // Fetch jobs without cache check (for initial load)
  Future<void> fetchJobsInitial(String profession, String category) async {
    print('Initial fetch for $profession - $category');
    // Don't check cache, always fetch fresh data
    isLoading.value = true;
    errorMessage.value = '';
    jobs.clear();

    _lastProfession = profession;
    _lastCategory = category;

    await _performJobFetch(profession, category);
  }

  // Private method to perform the actual API call
  Future<void> _performJobFetch(String profession, String category) async {
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
                  """Generate 15 realistic job listings for $profession specializing in $category.

Each job should include:
- title (specific role related to $profession and $category)
- description (2-3 sentences about the job responsibilities and requirements, mentioning specific skills required)
- company (fictional or real company name)
- salary range (realistic for this type of role in India, use ₹ symbol)
- experience level (e.g., Entry-level, Mid-level, Senior, 0-2 years, 3-5 years, etc.)
- skills (list of 4-6 technical skills required for this position, specifically relevant to $category)

Make sure jobs are diverse and cover different levels from entry to senior positions.
Focus on creating jobs that are specifically relevant to the $category specialization within $profession.

Format your response as a JSON array with this structure for each job:
{
  "title": "Job Title",
  "description": "Brief job description",
  "company": "Company Name",
  "salary": "Salary Range",
  "experience": "Experience Level",
  "skills": ["Skill1", "Skill2", "Skill3", "Skill4", "Skill5"]
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

            // Convert JSON to JobModel objects with better location distribution
            final List<JobModel> jobListings =
                jsonData.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;

              // Smart location assignment - ensure Delhi gets more jobs
              String assignedState;
              String assignedCity;

              if (index < 6) {
                // First 6 jobs go to Delhi to ensure availability
                assignedState = 'Delhi';
                final delhiCities = stateCities['Delhi'] ?? ['New Delhi'];
                assignedCity = delhiCities[_random.nextInt(delhiCities.length)];
              } else {
                // Remaining jobs distributed across other states
                assignedState =
                    indianStates[_random.nextInt(indianStates.length)];
                final citiesForState =
                    stateCities[assignedState] ?? [assignedState];
                assignedCity =
                    citiesForState[_random.nextInt(citiesForState.length)];
              }

              return JobModel(
                id: 'job_${DateTime.now().millisecondsSinceEpoch}_$index',
                title: item['title'] ?? '',
                description: item['description'] ?? '',
                company: item['company'] ?? '',
                salary: item['salary'] ?? '',
                experience: item['experience'] ?? '',
                skills: List<String>.from(item['skills'] ?? []),
                category: category, // Ensure category matches exactly
                profession: profession, // Ensure profession matches exactly
                // Location fields
                state: assignedState,
                city: assignedCity,
                location: '$assignedCity, $assignedState',
                address: '${assignedCity}, $assignedState, India',
                // Optional fields with some random data
                jobType: _getRandomJobType(),
                workMode: _getRandomWorkMode(),
                postedDate: DateTime.now().subtract(
                  Duration(
                      days: _random.nextInt(30)), // Posted within last 30 days
                ),
                isActive: true,
                contactEmail:
                    _generateRandomEmail(item['company'] ?? 'company'),
              );
            }).toList();

            // Update jobs list
            jobs.value = jobListings;

            // Debug print to verify jobs are created correctly
            print(
                'Created ${jobListings.length} jobs for $profession - $category');
            final delhiJobs = jobListings
                .where((job) =>
                    job.state?.toLowerCase() == 'delhi' ||
                    job.city?.toLowerCase().contains('delhi') == true ||
                    job.location?.toLowerCase().contains('delhi') == true)
                .length;
            print('Delhi jobs created: $delhiJobs');
          } else {
            throw Exception('Could not parse JSON data from response');
          }
        } catch (e) {
          errorMessage.value = 'Error parsing job data: $e';
          print('Parse error: $e');
        }
      } else if (response.statusCode == 401) {
        errorMessage.value =
            "Error 401: Unauthorized - Check your API key and permissions.";
      } else {
        errorMessage.value =
            'Error ${response.statusCode}: ${response.reasonPhrase}';
        print('API Error: ${errorMessage.value}');
      }
    } catch (e) {
      errorMessage.value = 'Error during API call: $e';
      print('Network error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Helper method to generate random email
  String _generateRandomEmail(String companyName) {
    final cleanCompanyName = companyName
        .toLowerCase()
        .replaceAll(' ', '')
        .replaceAll(RegExp(r'[^a-z0-9]'), '');
    final domains = ['com', 'in', 'org', 'co.in'];
    final domain = domains[_random.nextInt(domains.length)];
    return 'careers@$cleanCompanyName.$domain';
  }

  // Helper method to get random job type
  String _getRandomJobType() {
    final jobTypes = [
      'Full-time',
      'Part-time',
      'Contract',
      'Internship',
      'Freelance'
    ];
    return jobTypes[_random.nextInt(jobTypes.length)];
  }

  // Helper method to get random work mode
  String _getRandomWorkMode() {
    final workModes = ['On-site', 'Remote', 'Hybrid'];
    return workModes[_random.nextInt(workModes.length)];
  }

  // Force refresh job listings (ignores cache)
  Future<void> forceRefreshJobs(String profession, String category) async {
    print('Force refreshing jobs for $profession - $category');
    _lastProfession = null;
    _lastCategory = null;
    jobs.clear();
    await fetchJobs(profession, category);
  }

  // Clear job data
  void clearJobs() {
    jobs.clear();
    errorMessage.value = '';
    _lastProfession = null;
    _lastCategory = null;
  }

  // Filter jobs by state with better matching (additional helper method)
  List<JobModel> getJobsByState(String state) {
    return jobs.where((job) => job.matchesLocation(state)).toList();
  }

  // Get jobs by category and state (new method for better filtering)
  List<JobModel> getJobsByCategoryAndState(
      String category, String profession, String state) {
    return jobs.where((job) {
      // Check category and profession match
      bool categoryMatch =
          job.category.toLowerCase() == category.toLowerCase() &&
              job.profession.toLowerCase() == profession.toLowerCase();

      // Check location match
      bool locationMatch = job.matchesLocation(state);

      return categoryMatch && locationMatch;
    }).toList();
  }

  // Get jobs by work mode
  List<JobModel> getJobsByWorkMode(String workMode) {
    return jobs
        .where((job) => job.workMode?.toLowerCase() == workMode.toLowerCase())
        .toList();
  }

  // Get jobs by experience level
  List<JobModel> getJobsByExperience(String experience) {
    return jobs
        .where((job) =>
            job.experience.toLowerCase().contains(experience.toLowerCase()))
        .toList();
  }

  // Get job statistics for debugging
  Map<String, int> getJobStatistics() {
    Map<String, int> stats = {};

    // Count by state
    for (var job in jobs) {
      String state = job.state ?? 'Unknown';
      stats[state] = (stats[state] ?? 0) + 1;
    }

    return stats;
  }

  // Debug method to print job distribution
  void printJobDistribution() {
    print('\n=== Job Distribution ===');
    print('Total jobs: ${jobs.length}');

    final stats = getJobStatistics();
    stats.forEach((state, count) {
      print('$state: $count jobs');
    });

    print('========================\n');
  }
}
