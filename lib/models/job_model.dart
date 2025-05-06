class JobModel {
  final String title;
  final String description;
  final String company;
  final String location;
  final String salary;
  final String experience;
  final String applyUrl;
  final List<String> skills;

  JobModel({
    required this.title,
    required this.description,
    required this.company,
    this.location = '',
    required this.salary,
    this.experience = '',
    this.applyUrl = '',
    this.skills = const [],
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      company: json['company'] ?? '',
      location: json['location'] ?? '',
      salary: json['salary'] ?? '',
      experience: json['experience'] ?? '',
      applyUrl: json['applyUrl'] ?? '',
      skills: json['skills'] != null ? List<String>.from(json['skills']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'company': company,
      'location': location,
      'salary': salary,
      'experience': experience,
      'applyUrl': applyUrl,
      'skills': skills,
    };
  }
}
