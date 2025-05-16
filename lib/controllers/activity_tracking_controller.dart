import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebaseproject/models/quiz_activity_model.dart';

class ActivityTrackingController extends GetxController {
  // Observable variables
  final RxList<QuizActivity> activities = <QuizActivity>[].obs;
  final RxMap<String, int> heatmapData = <String, int>{}.obs;
  final RxString lastQuizDate = ''.obs;
  final RxString currentStreak = '0'.obs;
  final RxString longestStreak = '0'.obs;
  final RxString totalQuizzes = '0'.obs;
  final RxDouble averageScore = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadActivities();
  }

  // Public method to update stats that can be called from outside the controller
  void updateStats() {
    _updateStats();
  }

  // Load quiz activities from local storage
  Future<void> loadActivities() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final activitiesJson = prefs.getStringList('quiz_activities') ?? [];

      activities.value = activitiesJson
          .map((json) => QuizActivity.fromJson(jsonDecode(json)))
          .toList();

      // Update other stats
      _updateStats();
    } catch (e) {
      print('Error loading activities: $e');
    }
  }

  // Save quiz activities to local storage
  Future<void> saveActivities() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final activitiesJson =
          activities.map((activity) => jsonEncode(activity.toJson())).toList();

      await prefs.setStringList('quiz_activities', activitiesJson);
    } catch (e) {
      print('Error saving activities: $e');
    }
  }

  // Record a new quiz activity
  Future<void> recordQuizActivity(
      String profession, String category, String level, double score) async {
    final activity = QuizActivity(
      date: DateTime.now(),
      profession: profession,
      category: category,
      level: level,
      score: score,
    );

    activities.add(activity);

    // Update stats
    _updateStats();

    // Save to local storage
    await saveActivities();
  }

  // Update all stats based on current activities
  void _updateStats() {
    if (activities.isEmpty) {
      lastQuizDate.value = 'Never';
      currentStreak.value = '0';
      longestStreak.value = '0';
      totalQuizzes.value = '0';
      averageScore.value = 0.0;
      heatmapData.clear();
      return;
    }

    // Sort activities by date (newest first)
    activities.sort((a, b) => b.date.compareTo(a.date));

    // Update last quiz date
    final lastQuiz = activities.first;
    lastQuizDate.value = _formatDate(lastQuiz.date);

    // Update total quizzes
    totalQuizzes.value = activities.length.toString();

    // Calculate average score
    final totalScore = activities.fold(0.0, (sum, item) => sum + item.score);
    averageScore.value = totalScore / activities.length;

    // Calculate streak information
    _calculateStreaks();

    // Generate heatmap data
    _generateHeatmapData();
  }

  // Format date as "Month Day, Year"
  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  // Calculate current and longest streaks
  void _calculateStreaks() {
    if (activities.isEmpty) {
      currentStreak.value = '0';
      longestStreak.value = '0';
      return;
    }

    // Group activities by day
    final Map<String, List<QuizActivity>> activityByDay = {};
    for (final activity in activities) {
      final dateKey =
          '${activity.date.year}-${activity.date.month}-${activity.date.day}';
      if (!activityByDay.containsKey(dateKey)) {
        activityByDay[dateKey] = [];
      }
      activityByDay[dateKey]!.add(activity);
    }

    // Get sorted unique dates
    final List<DateTime> uniqueDates = activityByDay.keys.map((dateKey) {
      final parts = dateKey.split('-');
      return DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    }).toList()
      ..sort((a, b) => b.compareTo(a)); // Sort descending

    // Calculate current streak
    int current = 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // If had quiz today, start with 1
    if (uniqueDates.isNotEmpty &&
        uniqueDates[0].year == today.year &&
        uniqueDates[0].month == today.month &&
        uniqueDates[0].day == today.day) {
      current = 1;

      // Check consecutive days before today
      for (int i = 1; i < uniqueDates.length; i++) {
        final expectedDate = today.subtract(Duration(days: i));
        final foundDate = uniqueDates.firstWhere(
          (date) =>
              date.year == expectedDate.year &&
              date.month == expectedDate.month &&
              date.day == expectedDate.day,
          orElse: () => DateTime(0),
        );

        if (foundDate.year == 0) {
          break; // Streak broken
        }
        current++;
      }
    } else if (uniqueDates.isNotEmpty) {
      // Check if had quiz yesterday
      final yesterday = today.subtract(const Duration(days: 1));
      if (uniqueDates[0].year == yesterday.year &&
          uniqueDates[0].month == yesterday.month &&
          uniqueDates[0].day == yesterday.day) {
        current = 1;

        // Check consecutive days before yesterday
        for (int i = 1; i < uniqueDates.length; i++) {
          final expectedDate = yesterday.subtract(Duration(days: i));
          final foundDate = uniqueDates.firstWhere(
            (date) =>
                date.year == expectedDate.year &&
                date.month == expectedDate.month &&
                date.day == expectedDate.day,
            orElse: () => DateTime(0),
          );

          if (foundDate.year == 0) {
            break; // Streak broken
          }
          current++;
        }
      }
    }

    // Calculate longest streak
    int longest = 0;
    int tempStreak = 0;
    DateTime? lastDate;

    // Sort dates in ascending order for longest streak calculation
    uniqueDates.sort((a, b) => a.compareTo(b));

    for (final date in uniqueDates) {
      if (lastDate == null) {
        tempStreak = 1;
      } else {
        final difference = date.difference(lastDate).inDays;
        if (difference == 1) {
          tempStreak++;
        } else {
          tempStreak = 1; // Reset streak
        }
      }

      if (tempStreak > longest) {
        longest = tempStreak;
      }

      lastDate = date;
    }

    currentStreak.value = current.toString();
    longestStreak.value = longest.toString();
  }

  // Generate heatmap data
  void _generateHeatmapData() {
    final Map<String, int> data = {};

    // Group activities by day and count
    for (final activity in activities) {
      final dateKey =
          '${activity.date.year}-${activity.date.month.toString().padLeft(2, '0')}-${activity.date.day.toString().padLeft(2, '0')}';
      if (data.containsKey(dateKey)) {
        data[dateKey] = data[dateKey]! + 1;
      } else {
        data[dateKey] = 1;
      }
    }

    heatmapData.value = data;
  }

  // Get monthly activity summary for the past 12 months
  List<QuizActivitySummary> getMonthlySummary() {
    if (activities.isEmpty) {
      return [];
    }

    final Map<String, List<QuizActivity>> monthlySummaries = {};
    final now = DateTime.now();

    // Consider last 12 months
    for (int i = 0; i < 12; i++) {
      final month = now.month - i <= 0 ? now.month - i + 12 : now.month - i;

      final year = now.month - i <= 0 ? now.year - 1 : now.year;

      final key = '$year-${month.toString().padLeft(2, '0')}';
      monthlySummaries[key] = [];
    }

    // Group activities by month
    for (final activity in activities) {
      final key =
          '${activity.date.year}-${activity.date.month.toString().padLeft(2, '0')}';
      if (monthlySummaries.containsKey(key)) {
        monthlySummaries[key]!.add(activity);
      }
    }

    // Convert to summary objects
    final List<QuizActivitySummary> summaries = [];

    monthlySummaries.forEach((key, monthActivities) {
      if (monthActivities.isNotEmpty) {
        final parts = key.split('-');
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);

        // Calculate average score for the month
        final totalScore =
            monthActivities.fold(0.0, (sum, item) => sum + item.score);
        final avg = monthActivities.isNotEmpty
            ? totalScore / monthActivities.length
            : 0.0;

        summaries.add(QuizActivitySummary(
          date: DateTime(year, month, 1),
          count: monthActivities.length,
          averageScore: avg,
        ));
      } else {
        final parts = key.split('-');
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);

        summaries.add(QuizActivitySummary(
          date: DateTime(year, month, 1),
          count: 0,
          averageScore: 0.0,
        ));
      }
    });

    // Sort by date (newest first)
    summaries.sort((a, b) => b.date.compareTo(a.date));

    return summaries;
  }
}
