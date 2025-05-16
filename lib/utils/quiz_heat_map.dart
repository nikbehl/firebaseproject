import 'package:flutter/material.dart';

class QuizHeatMap extends StatefulWidget {
  final Map<String, int> data;
  final DateTime startDate;
  final DateTime endDate;
  final int maxCellValue;
  final double cellSize;
  final double cellSpacing;

  const QuizHeatMap({
    super.key,
    required this.data,
    required this.startDate,
    required this.endDate,
    this.maxCellValue = 4, // Max intensity level
    this.cellSize = 14.0,
    this.cellSpacing = 4.0,
  });

  @override
  State<QuizHeatMap> createState() => _QuizHeatMapState();
}

class _QuizHeatMapState extends State<QuizHeatMap> {
  // Scroll controller to synchronize month labels with heat map
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month labels
        _buildMonthLabels(),

        // Main heatmap grid with day labels
        SizedBox(
          height:
              7 * (widget.cellSize + widget.cellSpacing), // 7 days in a week
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day of week labels
              _buildDayLabels(),

              // Heat map cells in a scrollable container
              Expanded(
                child: _buildHeatMapGrid(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Legend
        _buildLegend(),
      ],
    );
  }

  // Build month labels at the top
  Widget _buildMonthLabels() {
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

    // Calculate grid dimensions
    final days = widget.endDate.difference(widget.startDate).inDays + 1;
    final weeks = (days / 7).ceil();
    final totalWidth = weeks * (widget.cellSize + widget.cellSpacing);

    return Padding(
      padding: EdgeInsets.only(left: 30, bottom: 8), // Add space for day labels
      child: SizedBox(
        height: 20,
        child: ListView(
          scrollDirection: Axis.horizontal,
          controller: _scrollController, // Use the same controller as the grid
          physics:
              const NeverScrollableScrollPhysics(), // Grid will control scrolling
          children: [
            SizedBox(
              width: totalWidth,
              child: Stack(
                children: _getMonthPositions(totalWidth).map((item) {
                  return Positioned(
                    left: item.position,
                    child: Text(
                      months[item.month - 1],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build day of week labels on the left
  Widget _buildDayLabels() {
    final days = ['Sun', 'Mon', '', 'Wed', '', 'Fri', ''];

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(7, (index) {
        return Container(
          height: widget.cellSize + widget.cellSpacing,
          width: 30,
          alignment: Alignment.centerLeft,
          child: Text(
            days[index],
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
          ),
        );
      }),
    );
  }

  // Build the main heat map grid
  Widget _buildHeatMapGrid() {
    // Calculate grid dimensions
    final days = widget.endDate.difference(widget.startDate).inDays + 1;
    final weeks = (days / 7).ceil();
    final totalWidth = weeks * (widget.cellSize + widget.cellSpacing);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _scrollController,
      child: SizedBox(
        width: totalWidth,
        child: _buildGrid(),
      ),
    );
  }

  // Build the grid of cells
  Widget _buildGrid() {
    final days = widget.endDate.difference(widget.startDate).inDays + 1;
    final weeks = (days / 7).ceil();

    return Column(
      children: List.generate(7, (row) {
        return Row(
          children: List.generate(weeks, (col) {
            final dayOffset = col * 7 + row;

            // Skip if out of range
            if (dayOffset >= days) {
              return SizedBox(width: widget.cellSize + widget.cellSpacing);
            }

            final currentDate = widget.startDate.add(Duration(days: dayOffset));

            // Skip if date is after end date
            if (currentDate.isAfter(widget.endDate)) {
              return SizedBox(width: widget.cellSize + widget.cellSpacing);
            }

            // Format the date as key for data lookup
            final dateKey = '${currentDate.year}-' +
                '${currentDate.month.toString().padLeft(2, '0')}-' +
                '${currentDate.day.toString().padLeft(2, '0')}';

            // Get activity count for this date
            final count = widget.data[dateKey] ?? 0;

            return Padding(
              padding: EdgeInsets.all(widget.cellSpacing / 2),
              child: _buildCell(count, dateKey, currentDate),
            );
          }),
        );
      }),
    );
  }

  // Build individual cell
  Widget _buildCell(int count, String dateKey, DateTime date) {
    // Determine cell color based on activity count
    final color = _getCellColor(count);

    // Get today's date for comparison
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final cellDate = DateTime(date.year, date.month, date.day);

    // Determine if this is today's cell
    final isToday = cellDate.isAtSameMomentAs(today);

    return Container(
      width: widget.cellSize,
      height: widget.cellSize,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
        border: isToday ? Border.all(color: Colors.blue, width: 1) : null,
      ),
      child: Tooltip(
        message: count > 0
            ? '${_formatDate(date)}: $count quiz${count > 1 ? 'zes' : ''}'
            : _formatDate(date),
        child: const SizedBox.expand(),
      ),
    );
  }

  // Get cell color based on activity count
  Color _getCellColor(int count) {
    if (count == 0) {
      return Colors.grey.shade200;
    }

    final normalizedValue = (count / widget.maxCellValue).clamp(0.0, 1.0);

    if (normalizedValue <= 0.25) {
      return Colors.green.shade100;
    } else if (normalizedValue <= 0.5) {
      return Colors.green.shade300;
    } else if (normalizedValue <= 0.75) {
      return Colors.green.shade500;
    } else {
      return Colors.green.shade700;
    }
  }

  // Format date as "Mon Day, Year"
  String _formatDate(DateTime date) {
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
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  // Build color legend
  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Less',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(width: 4),
        Container(
          width: widget.cellSize,
          height: widget.cellSize,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 2),
        Container(
          width: widget.cellSize,
          height: widget.cellSize,
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 2),
        Container(
          width: widget.cellSize,
          height: widget.cellSize,
          decoration: BoxDecoration(
            color: Colors.green.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 2),
        Container(
          width: widget.cellSize,
          height: widget.cellSize,
          decoration: BoxDecoration(
            color: Colors.green.shade500,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 2),
        Container(
          width: widget.cellSize,
          height: widget.cellSize,
          decoration: BoxDecoration(
            color: Colors.green.shade700,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        const Text(
          'More',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  // Calculate month positions
  List<_MonthPosition> _getMonthPositions(double totalWidth) {
    final result = <_MonthPosition>[];

    // Start with the first of the month that contains the start date
    DateTime current =
        DateTime(widget.startDate.year, widget.startDate.month, 1);

    // End with the last day of the month that contains the end date
    final endMonth = DateTime(widget.endDate.year, widget.endDate.month + 1, 0);

    // Track previous month to avoid duplicates
    int? prevMonth;

    while (current.isBefore(endMonth) || current.month == endMonth.month) {
      // Skip if already processed this month
      if (prevMonth == current.month) {
        current = DateTime(current.year, current.month + 1, 1);
        continue;
      }

      // Calculate days from start date to first of this month
      final daysFromStart = current.difference(widget.startDate).inDays;

      // Skip if before start date
      if (daysFromStart < 0) {
        current = DateTime(current.year, current.month + 1, 1);
        continue;
      }

      // Calculate position
      final weekOffset = daysFromStart ~/ 7; // Number of weeks from start date
      final x = weekOffset * (widget.cellSize + widget.cellSpacing);

      result.add(_MonthPosition(month: current.month, position: x));

      prevMonth = current.month;

      // Move to next month
      current = DateTime(current.year, current.month + 1, 1);
    }

    return result;
  }
}

// Helper class for month positions
class _MonthPosition {
  final int month;
  final double position;

  _MonthPosition({required this.month, required this.position});
}
