import 'package:firebaseproject/models/quiz_activity_model.dart';
import 'package:flutter/material.dart';

class MonthlyActivityChart extends StatelessWidget {
  final List<QuizActivitySummary> monthlySummary;
  final double barHeight;
  final double barSpacing;

  const MonthlyActivityChart({
    super.key,
    required this.monthlySummary,
    this.barHeight = 20.0,
    this.barSpacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    if (monthlySummary.isEmpty) {
      return const Center(
        child: Text('No monthly activity data available.'),
      );
    }

    // Find the maximum count for scaling
    final maxCount = monthlySummary.fold(
        0, (max, summary) => summary.count > max ? summary.count : max);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...monthlySummary.map(
          (summary) => Padding(
            padding: EdgeInsets.only(bottom: barSpacing),
            child: _buildMonthBar(context, summary, maxCount),
          ),
        ),
      ],
    );
  }

  // Build a single month bar
  Widget _buildMonthBar(
      BuildContext context, QuizActivitySummary summary, int maxCount) {
    // Format month name
    final monthName = _getMonthName(summary.date.month);

    // Calculate bar width percentage
    final double percentage = maxCount > 0 ? (summary.count / maxCount) : 0.0;

    // Format score
    final scoreText = summary.count > 0
        ? 'Avg: ${summary.averageScore.toStringAsFixed(1)}%'
        : '';

    return Row(
      children: [
        // Month label
        SizedBox(
          width: 50,
          child: Text(
            '$monthName ${summary.date.year}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ),

        // Bar and count
        Expanded(
          child: Row(
            children: [
              // Bar
              Expanded(
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // Full width background
                    Container(
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),

                    // Colored bar based on percentage
                    FractionallySizedBox(
                      widthFactor: percentage.clamp(0.0, 1.0),
                      child: Container(
                        height: barHeight,
                        decoration: BoxDecoration(
                          color: _getBarColor(percentage),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),

                    // Count label inside the bar
                    Positioned(
                      left: 8,
                      child: Text(
                        '${summary.count}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: percentage > 0.3 ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Average score
              if (summary.count > 0)
                Container(
                  width: 80,
                  alignment: Alignment.centerRight,
                  child: Text(
                    scoreText,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // Get month name from month number
  String _getMonthName(int month) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  // Get color based on percentage value
  Color _getBarColor(double percentage) {
    if (percentage <= 0.0) {
      return Colors.grey.shade300;
    } else if (percentage <= 0.25) {
      return Colors.blue.shade300;
    } else if (percentage <= 0.5) {
      return Colors.blue.shade500;
    } else if (percentage <= 0.75) {
      return Colors.blue.shade700;
    } else {
      return Colors.blue.shade900;
    }
  }
}
