import 'package:firebaseproject/controllers/job_controller.dart';
import 'package:firebaseproject/models/job_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class JobListingsScreen extends StatefulWidget {
  final String profession;
  final String category;

  const JobListingsScreen({
    super.key,
    required this.profession,
    required this.category,
  });

  @override
  State<JobListingsScreen> createState() => _JobListingsScreenState();
}

class _JobListingsScreenState extends State<JobListingsScreen> {
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

  late RxString selectedState;
  late JobController jobController;

  @override
  void initState() {
    super.initState();
    selectedState = 'Delhi'.obs;

    try {
      jobController = Get.find<JobController>();
    } catch (e) {
      jobController = Get.put(JobController());
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      jobController.fetchJobsInitial(widget.profession, widget.category);
    });
  }

  List<JobModel> getFilteredJobs() {
    if (jobController.jobs.isEmpty) return [];

    return jobController.jobs.where((job) {
      bool categoryMatch =
          job.category.toLowerCase() == widget.category.toLowerCase() &&
              job.profession.toLowerCase() == widget.profession.toLowerCase();

      if (!categoryMatch) return false;

      final searchState = selectedState.value.toLowerCase();
      bool locationMatch = false;

      if (job.state != null) {
        String jobState = job.state!.toLowerCase().trim();
        locationMatch =
            jobState == searchState || jobState.contains(searchState);
      }

      if (!locationMatch && job.city != null) {
        String jobCity = job.city!.toLowerCase().trim();
        locationMatch = jobCity.contains(searchState);
      }

      if (!locationMatch && job.location != null) {
        String jobLocation = job.location!.toLowerCase().trim();
        locationMatch = jobLocation.contains(searchState);
      }

      if (!locationMatch && job.address != null) {
        String jobAddress = job.address!.toLowerCase().trim();
        locationMatch = jobAddress.contains(searchState);
      }

      return locationMatch;
    }).toList();
  }

  // Method to show state selection dialog instead of dropdown
  void _showStateSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.blue.shade600),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Select State',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),

                // Search field
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search states...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        // Filter states based on search
                      });
                    },
                  ),
                ),

                // States list
                Expanded(
                  child: ListView.builder(
                    itemCount: indianStates.length,
                    itemBuilder: (context, index) {
                      final state = indianStates[index];
                      final isSelected = selectedState.value == state;

                      return ListTile(
                        leading: Icon(
                          Icons.location_city,
                          color: isSelected
                              ? Colors.blue.shade600
                              : Colors.grey.shade600,
                        ),
                        title: Text(
                          state,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? Colors.blue.shade700
                                : Colors.black87,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle,
                                color: Colors.blue.shade600,
                              )
                            : null,
                        onTap: () {
                          selectedState.value = state;
                          Navigator.pop(context);
                        },
                        tileColor: isSelected ? Colors.blue.shade50 : null,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.profession} - ${widget.category} Jobs'),
        backgroundColor: Colors.blue.shade50,
        foregroundColor: Colors.blue.shade800,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Location filter - Fixed version
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
                Icon(Icons.location_on, color: Colors.blue.shade600, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Location:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() => InkWell(
                        onTap: _showStateSelectionDialog,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                selectedState.value,
                                style: const TextStyle(fontSize: 16),
                              ),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.grey.shade600,
                              ),
                            ],
                          ),
                        ),
                      )),
                ),
              ],
            ),
          ),

          // Category display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.green.shade50,
            child: Text(
              'Category: ${widget.category}',
              style: TextStyle(
                color: Colors.green.shade700,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),

          // Jobs list
          Expanded(
            child: Obx(() {
              if (jobController.isLoading.value) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading job listings...'),
                    ],
                  ),
                );
              }

              if (jobController.errorMessage.value.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 64, color: Colors.red.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading jobs',
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.red.shade600,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          jobController.errorMessage.value,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          jobController.fetchJobsInitial(
                              widget.profession, widget.category);
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try Again'),
                      ),
                    ],
                  ),
                );
              }

              final filteredJobs = getFilteredJobs();

              if (filteredJobs.isNotEmpty) {
                return Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      color: Colors.blue.shade50,
                      child: Text(
                        'Showing ${filteredJobs.length} ${widget.category} job(s) in ${selectedState.value}',
                        style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          await jobController.forceRefreshJobs(
                              widget.profession, widget.category);
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredJobs.length,
                          itemBuilder: (context, index) {
                            final job = filteredJobs[index];
                            return _buildJobCard(job);
                          },
                        ),
                      ),
                    ),
                  ],
                );
              }

              if (jobController.jobs.isNotEmpty && filteredJobs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_off,
                          size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'No ${widget.category} jobs found in ${selectedState.value}',
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try selecting a different state or refresh jobs',
                        style: TextStyle(color: Colors.grey.shade500),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () => selectedState.value = 'Delhi',
                            child: const Text('Reset to Delhi'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () => jobController.forceRefreshJobs(
                                widget.profession, widget.category),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Refresh'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }

              if (jobController.jobs.isEmpty &&
                  !jobController.isLoading.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.work_off,
                          size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'No ${widget.category} job listings available',
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pull down to refresh or try again',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => jobController.fetchJobsInitial(
                            widget.profession, widget.category),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Load Jobs'),
                      ),
                    ],
                  ),
                );
              }

              return const Center(child: Text('Loading...'));
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            jobController.forceRefreshJobs(widget.profession, widget.category),
        backgroundColor: Colors.blue.shade600,
        tooltip: 'Refresh Jobs',
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Widget _buildJobCard(JobModel job) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    job.title,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    job.category,
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.business, size: 16, color: Colors.grey.shade700),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    job.company,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
                  ),
                ),
                if (_getJobLocation(job).isNotEmpty) ...[
                  const SizedBox(width: 16),
                  Icon(Icons.location_on, size: 16, color: Colors.red.shade600),
                  const SizedBox(width: 4),
                  Text(
                    _getJobLocation(job),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Skills Required:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
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
                        fontStyle: FontStyle.italic, color: Colors.grey),
                  ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (job.experience.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.work, size: 16, color: Colors.grey.shade700),
                        const SizedBox(width: 4),
                        Text(job.experience,
                            style: TextStyle(color: Colors.grey.shade800)),
                      ],
                    ),
                  ),
                if (job.jobType != null && job.jobType!.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      job.jobType!,
                      style:
                          TextStyle(color: Colors.green.shade700, fontSize: 12),
                    ),
                  ),
                if (job.workMode != null && job.workMode!.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      job.workMode!,
                      style: TextStyle(
                          color: Colors.purple.shade700, fontSize: 12),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (job.salary.isNotEmpty)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.attach_money,
                        size: 16, color: Colors.blue.shade700),
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

  String _getJobLocation(JobModel job) {
    if (job.location != null && job.location!.isNotEmpty) {
      return job.location!;
    }

    List<String> locationParts = [];
    if (job.city != null && job.city!.isNotEmpty) {
      locationParts.add(job.city!);
    }
    if (job.state != null && job.state!.isNotEmpty) {
      locationParts.add(job.state!);
    }

    return locationParts.join(', ');
  }

  Widget _buildSkillChip(String skill) {
    return Chip(
      label: Text(skill),
      backgroundColor: Colors.teal.shade50,
      labelStyle: TextStyle(color: Colors.teal.shade700),
    );
  }
}
