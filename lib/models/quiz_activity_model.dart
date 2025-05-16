class QuizActivity {
  final DateTime date;
  final String profession;
  final String category;
  final String level;
  final double score;

  QuizActivity({
    required this.date,
    required this.profession,
    required this.category,
    required this.level,
    required this.score,
  });

  factory QuizActivity.fromJson(Map<String, dynamic> json) {
    return QuizActivity(
      date: DateTime.parse(json['date']),
      profession: json['profession'] ?? '',
      category: json['category'] ?? '',
      level: json['level'] ?? '',
      score: json['score']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'profession': profession,
      'category': category,
      'level': level,
      'score': score,
    };
  }
}

class QuizActivitySummary {
  final DateTime date;
  final int count;
  final double averageScore;

  QuizActivitySummary({
    required this.date,
    required this.count,
    required this.averageScore,
  });
}
