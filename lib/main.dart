import 'package:firebaseproject/controllers/activity_tracking_controller.dart';
import 'package:firebaseproject/controllers/category_controller.dart';
import 'package:firebaseproject/controllers/job_controller.dart';
import 'package:firebaseproject/controllers/profession_controller.dart';
import 'package:firebaseproject/controllers/prompt_controller.dart';
import 'package:firebaseproject/controllers/quiz_controller.dart';
import 'package:firebaseproject/controllers/tech_guide_controller.dart';
import 'package:firebaseproject/screens/acitivity_dashboard.dart';
import 'package:firebaseproject/utils/profession_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tech Guide',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialBinding: AppBindings(),
      home: const SplashScreen(),
    );
  }
}

// Simple splash screen that transitions to the activity dashboard
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Wait for 2 seconds then navigate to activity dashboard or home
    Future.delayed(const Duration(seconds: 2), () async {
      final activityController = Get.find<ActivityTrackingController>();

      // Make sure activity data is loaded before navigating
      await activityController.loadActivities();
      activityController.updateStats();

      // Navigate to activity dashboard
      Get.off(() => const ActivityDashboardScreen());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.code,
              size: 80,
              color: Colors.deepPurple,
            ),
            const SizedBox(height: 24),
            const Text(
              'Tech Guide',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your learning companion',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

// Define initial bindings for all controllers
class AppBindings extends Bindings {
  @override
  void dependencies() {
    // Register all controllers
    Get.put(ProfessionController());
    Get.put(CategoryController());
    Get.put(PromptController());
    Get.put(TechGuideController());
    Get.put(QuizController());
    Get.put(JobController());

    // Register the activity tracking controller as permanent
    // This ensures it stays alive throughout the app lifecycle
    Get.put(ActivityTrackingController(), permanent: true);
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the profession controller
    final professionController = Get.find<ProfessionController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tech Guide'),
        centerTitle: true,
        actions: [
          // Add button to access activity dashboard from home screen
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Activity Dashboard',
            onPressed: () async {
              // Refresh activity data before navigating
              final activityController = Get.find<ActivityTrackingController>();
              await activityController.refreshData();

              Get.to(() => const ActivityDashboardScreen());
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose your profession to get started',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Obx(() => GridView.count(
                    crossAxisCount: 2, // 2 columns
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1, // Adjust as needed for card height
                    children:
                        professionController.professions.map((profession) {
                      return ProfessionCard(
                        title: profession['title'],
                        status: profession['status'],
                        icon: _getIconData(profession['icon']),
                        color: _getColor(profession['color']),
                      );
                    }).toList(),
                  )),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'More professions coming soon!',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods to convert string to IconData and Color
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'web':
        return Icons.web;
      case 'storage':
        return Icons.storage;
      case 'design_services':
        return Icons.design_services;
      case 'analytics':
        return Icons.analytics;
      case 'phone_android':
        return Icons.phone_android;
      case 'settings':
        return Icons.settings;
      default:
        return Icons.help_outline;
    }
  }

  Color _getColor(String colorName) {
    switch (colorName) {
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      case 'blue':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
