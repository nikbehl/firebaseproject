class JobModel {
  final String id;
  final String title;
  final String company;
  final List<String> skills;
  final String experience;
  final String salary;
  final String description;
  final String category;
  final String profession;

  // Location fields for filtering
  final String? location; // Full location string
  final String? city; // City name
  final String? state; // State name
  final String? address; // Complete address
  final String? pincode; // Pin code

  // Additional useful fields
  final String? jobType; // Full-time, Part-time, Contract, etc.
  final String? workMode; // Remote, On-site, Hybrid
  final DateTime? postedDate;
  final DateTime? lastDate; // Application deadline
  final bool isActive;
  final String? contactEmail;
  final String? contactPhone;
  final String? companyWebsite;
  final List<String>? benefits; // List of benefits offered

  JobModel({
    required this.id,
    required this.title,
    required this.company,
    required this.skills,
    required this.experience,
    required this.salary,
    required this.description,
    required this.category,
    required this.profession,
    this.location,
    this.city,
    this.state,
    this.address,
    this.pincode,
    this.jobType,
    this.workMode,
    this.postedDate,
    this.lastDate,
    this.isActive = true,
    this.contactEmail,
    this.contactPhone,
    this.companyWebsite,
    this.benefits,
  });

  // Factory constructor to create JobModel from JSON
  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      company: json['company'] ?? '',
      skills: List<String>.from(json['skills'] ?? []),
      experience: json['experience'] ?? '',
      salary: json['salary'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      profession: json['profession'] ?? '',
      location: json['location'],
      city: json['city'],
      state: json['state'],
      address: json['address'],
      pincode: json['pincode'],
      jobType: json['jobType'],
      workMode: json['workMode'],
      postedDate: json['postedDate'] != null
          ? DateTime.tryParse(json['postedDate'])
          : null,
      lastDate:
          json['lastDate'] != null ? DateTime.tryParse(json['lastDate']) : null,
      isActive: json['isActive'] ?? true,
      contactEmail: json['contactEmail'],
      contactPhone: json['contactPhone'],
      companyWebsite: json['companyWebsite'],
      benefits:
          json['benefits'] != null ? List<String>.from(json['benefits']) : null,
    );
  }

  // Method to convert JobModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'company': company,
      'skills': skills,
      'experience': experience,
      'salary': salary,
      'description': description,
      'category': category,
      'profession': profession,
      'location': location,
      'city': city,
      'state': state,
      'address': address,
      'pincode': pincode,
      'jobType': jobType,
      'workMode': workMode,
      'postedDate': postedDate?.toIso8601String(),
      'lastDate': lastDate?.toIso8601String(),
      'isActive': isActive,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'companyWebsite': companyWebsite,
      'benefits': benefits,
    };
  }

  // Copy with method for creating modified copies
  JobModel copyWith({
    String? id,
    String? title,
    String? company,
    List<String>? skills,
    String? experience,
    String? salary,
    String? description,
    String? category,
    String? profession,
    String? location,
    String? city,
    String? state,
    String? address,
    String? pincode,
    String? jobType,
    String? workMode,
    DateTime? postedDate,
    DateTime? lastDate,
    bool? isActive,
    String? contactEmail,
    String? contactPhone,
    String? companyWebsite,
    List<String>? benefits,
  }) {
    return JobModel(
      id: id ?? this.id,
      title: title ?? this.title,
      company: company ?? this.company,
      skills: skills ?? this.skills,
      experience: experience ?? this.experience,
      salary: salary ?? this.salary,
      description: description ?? this.description,
      category: category ?? this.category,
      profession: profession ?? this.profession,
      location: location ?? this.location,
      city: city ?? this.city,
      state: state ?? this.state,
      address: address ?? this.address,
      pincode: pincode ?? this.pincode,
      jobType: jobType ?? this.jobType,
      workMode: workMode ?? this.workMode,
      postedDate: postedDate ?? this.postedDate,
      lastDate: lastDate ?? this.lastDate,
      isActive: isActive ?? this.isActive,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      companyWebsite: companyWebsite ?? this.companyWebsite,
      benefits: benefits ?? this.benefits,
    );
  }

  // Helper method to get formatted location string
  String get formattedLocation {
    List<String> locationParts = [];

    if (city != null && city!.isNotEmpty) {
      locationParts.add(city!);
    }
    if (state != null && state!.isNotEmpty) {
      locationParts.add(state!);
    }
    if (locationParts.isEmpty && location != null && location!.isNotEmpty) {
      return location!;
    }

    return locationParts.join(', ');
  }

  // Improved helper method to check if job matches a location
  bool matchesLocation(String searchLocation) {
    final search = searchLocation.toLowerCase().trim();

    // Direct state match (highest priority)
    if (state != null) {
      final jobState = state!.toLowerCase().trim();
      if (jobState == search || jobState.contains(search)) {
        return true;
      }
    }

    // City match
    if (city != null) {
      final jobCity = city!.toLowerCase().trim();
      if (jobCity == search || jobCity.contains(search)) {
        return true;
      }
    }

    // Location field match
    if (location != null) {
      final jobLocation = location!.toLowerCase().trim();
      if (jobLocation.contains(search)) {
        return true;
      }
    }

    // Address match
    if (address != null) {
      final jobAddress = address!.toLowerCase().trim();
      if (jobAddress.contains(search)) {
        return true;
      }
    }

    return false;
  }

  // Helper method to check if job matches category and profession
  bool matchesCategoryAndProfession(
      String searchCategory, String searchProfession) {
    return category.toLowerCase().trim() ==
            searchCategory.toLowerCase().trim() &&
        profession.toLowerCase().trim() ==
            searchProfession.toLowerCase().trim();
  }

  // Combined method to check category, profession, and location
  bool matchesCriteria({
    required String category,
    required String profession,
    String? location,
  }) {
    // Check category and profession
    bool categoryMatch = matchesCategoryAndProfession(category, profession);

    // If location is specified, check location match
    if (location != null && location.isNotEmpty) {
      return categoryMatch && matchesLocation(location);
    }

    return categoryMatch;
  }

  @override
  String toString() {
    return 'JobModel(id: $id, title: $title, company: $company, category: $category, location: $formattedLocation)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is JobModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
