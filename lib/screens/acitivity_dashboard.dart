import 'package:firebaseproject/controllers/activity_tracking_controller.dart';
import 'package:firebaseproject/main.dart';
import 'package:firebaseproject/models/quiz_activity_model.dart';
import 'package:firebaseproject/utils/quiz_heat_map.dart';
import 'package:firebaseproject/utils/monthly_activity_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ActivityDashboardScreen extends StatefulWidget {
  const ActivityDashboardScreen({super.key});

  @override
  State<ActivityDashboardScreen> createState() =>
      _ActivityDashboardScreenState();
}

class _ActivityDashboardScreenState extends State<ActivityDashboardScreen>
    with WidgetsBindingObserver {
  // Get the activity tracking controller
  final ActivityTrackingController activityController =
      Get.find<ActivityTrackingController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Force an immediate refresh when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshActivityData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh when dependencies change - useful when returning to this screen
    _refreshActivityData();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When app returns to the foreground, refresh data
    if (state == AppLifecycleState.resumed) {
      _refreshActivityData();
    }
  }

  @override
  void dispose() {
    // Unregister the observer when this screen is disposed
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Refresh activity data from storage and update stats
  Future<void> _refreshActivityData() async {
    print("Refreshing activity data...");
    await activityController.loadActivities();
    activityController.updateStats();
    print("Heatmap data after refresh: ${activityController.heatmapData}");
  }

  @override
  Widget build(BuildContext context) {
    // Calculate date range for heat map
    final now = DateTime.now();
    final endDate = DateTime(now.year, now.month, now.day);
    final startDate =
        endDate.subtract(const Duration(days: 365)); // Show one year

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Dashboard'),
        actions: [
          // Add refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh data',
            onPressed: _refreshActivityData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Pull to refresh functionality
          await _refreshActivityData();
          return Future.value(); // Explicitly return a completed Future
        },
        child: Obx(() => SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats cards
                  _buildStatsSection(activityController),

                  const SizedBox(height: 24),

                  // Heat map section
                  _buildHeatMapSection(
                    context,
                    activityController,
                    startDate,
                    endDate,
                  ),

                  const SizedBox(height: 32),

                  // Monthly activity section
                  _buildMonthlyActivitySection(activityController),

                  const SizedBox(height: 24),

                  // Continue button
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: ElevatedButton(
                      onPressed: () {
                        // Ensure data is saved before navigating
                        activityController.saveActivities();
                        Get.off(() =>
                            const HomeScreen()); // Use Get.off instead of Get.to to replace the current screen
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text(
                        'Continue to App',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ),
      // Add a floating action button for testing if needed
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show a dialog with options
          Get.dialog(
            AlertDialog(
              title: const Text('Dashboard Options'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.refresh),
                    title: const Text('Refresh Data'),
                    onTap: () async {
                      Get.back();
                      await _refreshActivityData();
                      Get.snackbar(
                        'Refreshed',
                        'Activity data has been refreshed',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.add),
                    title: const Text('Add Test Data'),
                    onTap: () {
                      Get.back();
                      _addMockData(activityController);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.more_vert),
      ),
    );
  }

  // Stats section with cards for key metrics
  Widget _buildStatsSection(ActivityTrackingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Quiz Stats',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            // Last Quiz Date
            Expanded(
              child: _buildStatCard(
                icon: Icons.calendar_today,
                iconColor: Colors.blue,
                title: 'Last Quiz',
                value: controller.lastQuizDate.value,
              ),
            ),
            const SizedBox(width: 12),

            // Current Streak
            Expanded(
              child: _buildStatCard(
                icon: Icons.local_fire_department,
                iconColor: Colors.orange,
                title: 'Current Streak',
                value: '${controller.currentStreak} days',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Total Quizzes
            Expanded(
              child: _buildStatCard(
                icon: Icons.quiz,
                iconColor: Colors.purple,
                title: 'Total Quizzes',
                value: controller.totalQuizzes.value,
              ),
            ),
            const SizedBox(width: 12),

            // Average Score
            Expanded(
              child: _buildStatCard(
                icon: Icons.score,
                iconColor: Colors.green,
                title: 'Avg. Score',
                value: controller.averageScore.value > 0
                    ? '${controller.averageScore.value.toStringAsFixed(1)}%'
                    : 'N/A',
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Build a single stat card
  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Heat map section
  Widget _buildHeatMapSection(
    BuildContext context,
    ActivityTrackingController controller,
    DateTime startDate,
    DateTime endDate,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Activity Calendar',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Longest streak: ${controller.longestStreak} days',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: QuizHeatMap(
              data: controller.heatmapData,
              startDate: startDate,
              endDate: endDate,
            ),
          ),
        ),
      ],
    );
  }

  // Monthly activity section
  Widget _buildMonthlyActivitySection(ActivityTrackingController controller) {
    final monthlySummary = controller.getMonthlySummary();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Monthly Activity',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: MonthlyActivityChart(
                monthlySummary: monthlySummary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper method to add mock data for testing
  void _addMockData(ActivityTrackingController controller) {
    // Generate mock data for the current month
    final now = DateTime.now();

    // Add a quiz for today
    controller.recordQuizActivity(
      'Frontend Developer',
      'JavaScript',
      'Intermediate',
      85.0,
    );

    // Add a quiz for yesterday
    controller.recordQuizActivity(
      'Backend Developer',
      'Node.js',
      'Basic',
      70.0,
    );

    // Add some random quizzes in the past month
    for (int i = 2; i < 30; i += 2) {
      if (i % 7 == 0) continue; // Skip some days for variety

      final date = now.subtract(Duration(days: i));
      final random = DateTime.now().millisecondsSinceEpoch % 100;

      controller.activities.add(
        QuizActivity(
          date: date,
          profession: random > 50 ? 'Frontend Developer' : 'Backend Developer',
          category: random > 50 ? 'JavaScript' : 'Python',
          level: random > 70
              ? 'Advanced'
              : (random > 30 ? 'Intermediate' : 'Basic'),
          score: 60 + (random % 40), // Score between 60-99
        ),
      );
    }

    // Update all stats and save to storage
    controller.updateStats();
    controller.saveActivities();

    // Show success message
    Get.snackbar(
      'Test Data Added',
      'Mock quiz activity data has been added for testing.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }
}
