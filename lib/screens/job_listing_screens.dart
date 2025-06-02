import 'package:firebaseproject/controllers/job_controller.dart';
import 'package:firebaseproject/models/job_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class JobListingsScreen extends StatelessWidget {
  final String profession;
  final String category;

  const JobListingsScreen({
    super.key,
    required this.profession,
    required this.category,
  });

  // List of Indian states
  final List<String> indianStates = const [
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

  @override
  Widget build(BuildContext context) {
    // Get the job controller
    final jobController = Get.find<JobController>();

    // Fetch jobs when the screen loads
    jobController.fetchJobs(profession, category);

    // Observable for selected state
    final selectedState = 'Delhi'.obs;

    return Scaffold(
      appBar: AppBar(
        title: Text('$profession Career Paths'),
      ),
      body: Column(
        children: [
          // State dropdown section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.blue.shade600,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Location:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          value: selectedState.value,
                          isExpanded: true,
                          underline: const SizedBox(),
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.grey.shade600,
                          ),
                          items: indianStates.map((String state) {
                            return DropdownMenuItem<String>(
                              value: state,
                              child: Text(
                                state,
                                style: const TextStyle(fontSize: 16),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              selectedState.value = newValue;
                              // No functionality for now as requested
                            }
                          },
                        ),
                      )),
                ),
              ],
            ),
          ),

          // Job listings section
          Expanded(
            child: Obx(() {
              // Show loading indicator
              if (jobController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              // Show error message if any
              if (jobController.errorMessage.value.isNotEmpty) {
                return Center(child: Text(jobController.errorMessage.value));
              }

              // Show jobs if available
              if (jobController.jobs.isNotEmpty) {
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: jobController.jobs.length,
                  itemBuilder: (context, index) {
                    final job = jobController.jobs[index];
                    return _buildJobCard(job);
                  },
                );
              }

              // Fallback (should not reach here)
              return const Center(child: Text('No job listings available'));
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Refresh job listings
          jobController.fetchJobs(profession, category);
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }

  // Helper method to build job cards
  Widget _buildJobCard(JobModel job) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job title
            Text(
              job.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // Company
            Row(
              children: [
                Icon(
                  Icons.business,
                  size: 16,
                  color: Colors.grey.shade700,
                ),
                const SizedBox(width: 4),
                Text(
                  job.company,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Skills needed section
            const Text(
              'Skills Required:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // Skills wrap
            job.skills.isNotEmpty
                ? Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: job.skills
                        .map((skill) => _buildSkillChip(skill))
                        .toList(),
                  )
                : const Text(
                    'No specific skills listed',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),

            const SizedBox(height: 16),

            // Experience level
            if (job.experience.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.work,
                      size: 16,
                      color: Colors.grey.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      job.experience,
                      style: TextStyle(
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 8),

            // Salary
            if (job.salary.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.attach_money,
                      size: 16,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      job.salary,
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Helper method to build skill chips
  Widget _buildSkillChip(String skill) {
    return Chip(
      label: Text(skill),
      backgroundColor: Colors.teal.shade50,
      labelStyle: TextStyle(color: Colors.teal.shade700),
    );
  }
}
