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

IMPORTANT: Format your response as a valid JSON array. Make sure to:
1. Escape all quotes within strings using backslashes
2. Do not include any markdown formatting or code blocks
3. Return ONLY the JSON array, nothing else

Format structure for each job:
{
  "title": "Job Title",
  "description": "Brief job description",
  "company": "Company Name",
  "salary": "Salary Range",
  "experience": "Experience Level",
  "skills": ["Skill1", "Skill2", "Skill3", "Skill4", "Skill5"]
}"""
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final responseMessage = data['choices'][0]['message']['content'];

        // Try to extract and clean JSON from the response
        try {
          // Clean the response message
          final cleanedJson = _cleanJsonResponseEnhanced(responseMessage);

          if (cleanedJson.isEmpty) {
            throw Exception('No valid JSON found in response');
          }

          final List<dynamic> jsonData = jsonDecode(cleanedJson);

          if (jsonData.isEmpty) {
            throw Exception('Empty job data returned');
          }

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
              title: _cleanString(item['title'] ?? ''),
              description: _cleanString(item['description'] ?? ''),
              company: _cleanString(item['company'] ?? ''),
              salary: _cleanString(item['salary'] ?? ''),
              experience: _cleanString(item['experience'] ?? ''),
              skills: _cleanSkillsList(List<String>.from(item['skills'] ?? [])),
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
              contactEmail: _generateRandomEmail(item['company'] ?? 'company'),
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
        } catch (e) {
          errorMessage.value = 'Error parsing job data: $e';
          print('Parse error: $e');
          print('Raw response: $responseMessage');
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

  String _cleanJsonResponseEnhanced(String responseMessage) {
    try {
      // Remove markdown formatting
      String cleaned = responseMessage
          .replaceAll(RegExp(r'```json\s*'), '')
          .replaceAll(RegExp(r'```\s*'), '')
          .trim();

      // Try multiple extraction patterns
      List<String> attempts = [
        _extractWithPattern(cleaned, RegExp(r'\[\s*\{.*\}\s*\]', dotAll: true)),
        _extractWithPattern(cleaned, RegExp(r'\[[\s\S]*\]')),
        _tryFixBrokenJson(cleaned),
      ];

      for (String attempt in attempts) {
        if (attempt.isNotEmpty && _isValidJson(attempt)) {
          return attempt;
        }
      }

      // Fallback: create basic jobs
      print('Using fallback job creation');
      return _createBasicFallbackJobs();
    } catch (e) {
      print('JSON cleaning failed: $e');
      return _createBasicFallbackJobs();
    }
  }

  // NEW: Method to clean and extract JSON from response
  // String _cleanJsonResponse(String responseMessage) {
  //   try {
  //     // Remove any markdown code blocks
  //     String cleaned = responseMessage
  //         .replaceAll(RegExp(r'```json\s*'), '')
  //         .replaceAll(RegExp(r'```\s*'), '')
  //         .trim();

  //     // Find JSON array in the response
  //     final RegExp jsonRegex = RegExp(r'\[\s*\{.*\}\s*\]', dotAll: true);
  //     final Match? jsonMatch = jsonRegex.firstMatch(cleaned);

  //     if (jsonMatch != null) {
  //       String jsonString = jsonMatch.group(0) ?? '[]';

  //       // Additional cleaning for common JSON issues
  //       jsonString = _fixCommonJsonIssues(jsonString);

  //       // Test if it's valid JSON
  //       jsonDecode(jsonString); // This will throw if invalid

  //       return jsonString;
  //     }

  //     // If no JSON array found, try to extract from the entire response
  //     if (cleaned.startsWith('[') && cleaned.endsWith(']')) {
  //       cleaned = _fixCommonJsonIssues(cleaned);

  //       // Test if it's valid JSON
  //       jsonDecode(cleaned); // This will throw if invalid

  //       return cleaned;
  //     }

  //     return '';
  //   } catch (e) {
  //     print('JSON cleaning error: $e');
  //     return '';
  //   }
  // }

  // NEW: Method to fix common JSON formatting issues
  String _fixCommonJsonIssues(String jsonString) {
    // Fix unescaped quotes within string values
    // This is a more sophisticated approach to handle quotes in descriptions

    // Split by lines and process each line
    List<String> lines = jsonString.split('\n');
    List<String> fixedLines = [];

    for (String line in lines) {
      String fixedLine = line;

      // If line contains a field with quotes, fix them
      if (line.contains('"') && line.contains(':')) {
        // Match field: "value" pattern and fix quotes in value
        fixedLine =
            line.replaceAllMapped(RegExp(r'("[^"]+"):\s*(".*")'), (match) {
          String field = match.group(1) ?? '';
          String value = match.group(2) ?? '';

          // Fix quotes inside the value (but not the surrounding quotes)
          if (value.length > 2) {
            String innerValue = value.substring(1, value.length - 1);
            innerValue = innerValue.replaceAll('"', '\\"');
            value = '"$innerValue"';
          }

          return '$field: $value';
        });
      }

      fixedLines.add(fixedLine);
    }

    return fixedLines.join('\n');
  }

  // NEW: Method to clean individual strings
  String _cleanString(String value) {
    return value
        .replaceAll(RegExp(r'[^\w\s\-.,!?()₹%/]'),
            '') // Remove special chars except common ones
        .trim();
  }

  // NEW: Method to clean skills list
  List<String> _cleanSkillsList(List<String> skills) {
    return skills
        .map((skill) => _cleanString(skill))
        .where((skill) => skill.isNotEmpty)
        .toList();
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

  String _extractWithPattern(String text, RegExp pattern) {
    final match = pattern.firstMatch(text);
    if (match != null) {
      String extracted = match.group(0) ?? '';
      return _fixBasicJsonIssues(extracted);
    }
    return '';
  }

// 3. Try to fix broken JSON
  String _tryFixBrokenJson(String text) {
    if (!text.startsWith('[')) text = '[' + text;
    if (!text.endsWith(']')) text = text + ']';

    // Fix common issues
    text = text
        .replaceAll(RegExp(r',\s*}'), '}') // Remove trailing commas
        .replaceAll(RegExp(r',\s*]'), ']')
        .replaceAll(
            RegExp(r'([{,]\s*)([a-zA-Z_]\w*)\s*:'), r'$1"$2":'); // Quote keys

    return text;
  }

  bool _isValidJson(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString);
      return decoded is List && decoded.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

// 5. Create basic fallback jobs
  String _createBasicFallbackJobs() {
    final profession = _lastProfession ?? 'Developer';
    final category = _lastCategory ?? 'Technology';

    return jsonEncode([
      {
        "title": "$category $profession",
        "description":
            "Join our team as a $category specialist. Work on innovative projects and grow your skills.",
        "company": "TechFlow Solutions",
        "salary": "₹6-12 LPA",
        "experience": "2-4 years",
        "skills": [
          category,
          "Problem Solving",
          "Communication",
          "Teamwork",
          "Project Management"
        ]
      },
      {
        "title": "Senior $category Engineer",
        "description":
            "Lead $category development initiatives and mentor junior team members.",
        "company": "Innovation Labs",
        "salary": "₹12-20 LPA",
        "experience": "5+ years",
        "skills": [
          "Advanced $category",
          "Leadership",
          "System Design",
          "Mentoring",
          "Strategy"
        ]
      },
      {
        "title": "Junior $category Developer",
        "description":
            "Perfect opportunity for fresh graduates to start their career in $category development.",
        "company": "StartUp Hub",
        "salary": "₹4-8 LPA",
        "experience": "0-2 years",
        "skills": [
          "Basic $category",
          "Learning Agility",
          "Collaboration",
          "Documentation",
          "Testing"
        ]
      },
      {
        "title": "$category Consultant",
        "description":
            "Provide expert $category consulting services to clients across various industries.",
        "company": "ConsultPro",
        "salary": "₹10-15 LPA",
        "experience": "3-6 years",
        "skills": [
          category,
          "Client Management",
          "Analysis",
          "Presentation",
          "Business Understanding"
        ]
      },
      {
        "title": "Lead $category Architect",
        "description":
            "Design and implement large-scale $category solutions for enterprise clients.",
        "company": "Enterprise Solutions Inc",
        "salary": "₹18-25 LPA",
        "experience": "7+ years",
        "skills": [
          "Expert $category",
          "Architecture",
          "Team Leadership",
          "Enterprise Solutions",
          "Strategic Planning"
        ]
      }
    ]);
  }

  String _buildBetterPrompt(String profession, String category) {
    return '''You must return ONLY a valid JSON array. No explanations, no markdown.

Create 15 job listings for $profession specializing in $category.

Return this exact format:
[{"title":"Job Title","description":"Brief description","company":"Company Name","salary":"₹X-Y LPA","experience":"X years","skills":["skill1","skill2","skill3","skill4"]}]

Requirements:
- Focus on $category within $profession
- Include entry to senior levels  
- Use Indian salary ranges with ₹
- 4-6 skills per job
- Real company names preferred

Return JSON array immediately.''';
  }

  Future<void> _performJobFetchImproved(
      String profession, String category) async {
    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
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
                        "Return only valid JSON arrays. No markdown or explanations."
                  },
                  {
                    "role": "user",
                    "content": _buildBetterPrompt(profession, category),
                  }
                ],
                "temperature": 0.3, // More consistent output
                "max_tokens": 2000, // Limit response length
              }),
            )
            .timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final responseMessage = data['choices'][0]['message']['content'];

          // Use enhanced JSON cleaning
          final cleanedJson = _cleanJsonResponseEnhanced(responseMessage);

          if (cleanedJson.isNotEmpty) {
            final List<dynamic> jsonData = jsonDecode(cleanedJson);

            // Create job models with validation
            final List<JobModel> validJobs = [];

            for (int i = 0; i < jsonData.length && i < 15; i++) {
              final item = jsonData[i];

              if (item is Map<String, dynamic> &&
                  item['title'] != null &&
                  item['company'] != null) {
                final job =
                    _createJobModelSafely(item, i, profession, category);
                if (job != null) {
                  validJobs.add(job);
                }
              }
            }

            if (validJobs.length >= 3) {
              // At least 3 valid jobs
              jobs.value = validJobs;
              print('Successfully loaded ${validJobs.length} jobs');
              return; // Success!
            }
          }

          throw Exception('Insufficient valid job data received');
        } else if (response.statusCode == 401) {
          errorMessage.value = "API key error. Please check configuration.";
          return;
        } else {
          throw Exception(
              'HTTP ${response.statusCode}: ${response.reasonPhrase}');
        }
      } catch (e) {
        retryCount++;
        print('Attempt $retryCount failed: $e');

        if (retryCount >= maxRetries) {
          // Final fallback: use basic jobs
          print('All attempts failed, using fallback jobs');
          final fallbackJson = _createBasicFallbackJobs();
          final fallbackData = jsonDecode(fallbackJson);

          final fallbackJobs = fallbackData.map<JobModel>((item) {
            return _createJobModelSafely(item, 0, profession, category)!;
          }).toList();

          jobs.value = fallbackJobs;
          return;
        }

        // Wait before retry
        await Future.delayed(Duration(seconds: retryCount));
      }
    }

    isLoading.value = false;
  }

  JobModel? _createJobModelSafely(Map<String, dynamic> item, int index,
      String profession, String category) {
    try {
      // Validate required fields
      if (item['title'] == null || item['title'].toString().trim().isEmpty) {
        print('Skipping job with missing title at index $index');
        return null;
      }

      if (item['company'] == null ||
          item['company'].toString().trim().isEmpty) {
        print('Skipping job with missing company at index $index');
        return null;
      }

      // Smart location assignment (same as your existing logic)
      String assignedState;
      String assignedCity;

      if (index < 6) {
        // First 6 jobs go to Delhi to ensure availability
        assignedState = 'Delhi';
        final delhiCities = stateCities['Delhi'] ?? ['New Delhi'];
        assignedCity = delhiCities[_random.nextInt(delhiCities.length)];
      } else {
        // Remaining jobs distributed across other states
        assignedState = indianStates[_random.nextInt(indianStates.length)];
        final citiesForState = stateCities[assignedState] ?? [assignedState];
        assignedCity = citiesForState[_random.nextInt(citiesForState.length)];
      }

      // Create the job model with safe defaults
      return JobModel(
        id: 'job_${DateTime.now().millisecondsSinceEpoch}_$index',
        title: _cleanStringSafely(item['title']),
        description: _cleanStringSafely(item['description'],
            defaultValue: 'Job description not available'),
        company: _cleanStringSafely(item['company']),
        salary:
            _cleanStringSafely(item['salary'], defaultValue: '₹ Competitive'),
        experience: _cleanStringSafely(item['experience'],
            defaultValue: 'As per requirement'),
        skills: _cleanSkillsListSafely(item['skills']),
        category: category,
        profession: profession,
        // Location fields
        state: assignedState,
        city: assignedCity,
        location: '$assignedCity, $assignedState',
        address: '$assignedCity, $assignedState, India',
        // Optional fields with random data
        jobType: _getRandomJobType(),
        workMode: _getRandomWorkMode(),
        postedDate: DateTime.now().subtract(
          Duration(days: _random.nextInt(30)), // Posted within last 30 days
        ),
        isActive: true,
        contactEmail: _generateRandomEmailSafely(item['company']),
      );
    } catch (e) {
      print('Error creating job model at index $index: $e');
      return null;
    }
  }

  String _generateRandomEmailSafely(dynamic companyName) {
    try {
      final cleanCompanyName = (companyName?.toString() ?? 'company')
          .toLowerCase()
          .replaceAll(' ', '')
          .replaceAll(RegExp(r'[^a-z0-9]'), '');

      final domains = ['com', 'in', 'org', 'co.in'];
      final domain = domains[_random.nextInt(domains.length)];

      return 'careers@${cleanCompanyName.isEmpty ? 'company' : cleanCompanyName}.$domain';
    } catch (e) {
      return 'careers@company.com';
    }
  }

  String _cleanStringSafely(dynamic input, {String defaultValue = ''}) {
    if (input == null) return defaultValue;

    try {
      return input
          .toString()
          .replaceAll(RegExp(r'[^\w\s\-.,!?()₹%/:]'),
              '') // Remove special chars except common ones
          .trim();
    } catch (e) {
      return defaultValue;
    }
  }

  List<String> _cleanSkillsListSafely(dynamic skills) {
    try {
      if (skills == null) {
        return [
          'General Skills',
          'Communication',
          'Problem Solving',
          'Teamwork'
        ];
      }

      if (skills is! List) {
        return [
          'General Skills',
          'Communication',
          'Problem Solving',
          'Teamwork'
        ];
      }

      final cleanedSkills = skills
          .where((skill) => skill != null)
          .map((skill) => _cleanStringSafely(skill))
          .where((skill) => skill.isNotEmpty)
          .take(6) // Limit to 6 skills max
          .toList();

      // Ensure we have at least some skills
      if (cleanedSkills.isEmpty) {
        return [
          'General Skills',
          'Communication',
          'Problem Solving',
          'Teamwork'
        ];
      }

      return cleanedSkills;
    } catch (e) {
      return ['General Skills', 'Communication', 'Problem Solving', 'Teamwork'];
    }
  }

  String _fixBasicJsonIssues(String jsonString) {
    try {
      // Ensure proper array structure
      jsonString = jsonString.trim();
      if (!jsonString.startsWith('[')) {
        jsonString = '[' + jsonString;
      }
      if (!jsonString.endsWith(']')) {
        jsonString = jsonString + ']';
      }

      // Fix common JSON formatting issues
      jsonString = jsonString
          // Fix unquoted keys
          .replaceAll(
              RegExp(r'([{,]\s*)([a-zA-Z_][a-zA-Z0-9_]*)\s*:'), r'$1"$2":')
          // Quote unquoted string values (but not numbers, booleans, arrays, objects)
          .replaceAll(RegExp(r':\s*([^"\[\{][^,\]\}]*[^,\]\}\s])'), r': "$1"')
          // Fix double quotes
          .replaceAll(RegExp(r'""([^"]*)\""'), r'"$1"')
          // Remove trailing commas in objects
          .replaceAll(RegExp(r',\s*}'), '}')
          // Remove trailing commas in arrays
          .replaceAll(RegExp(r',\s*]'), ']');

      return jsonString;
    } catch (e) {
      print('Error fixing JSON: $e');
      return jsonString;
    }
  }
}
