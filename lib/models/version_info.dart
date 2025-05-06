class VersionInfo {
  final String technology;
  final String version;
  final String releaseDate;
  final String additionalInfo;

  VersionInfo({
    required this.technology,
    required this.version,
    this.releaseDate = '',
    this.additionalInfo = '',
  });

  factory VersionInfo.fromJson(Map<String, dynamic> json) {
    return VersionInfo(
      technology: json['technology'] ?? '',
      version: json['version'] ?? '',
      releaseDate: json['releaseDate'] ?? '',
      additionalInfo: json['additionalInfo'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'technology': technology,
      'version': version,
      'releaseDate': releaseDate,
      'additionalInfo': additionalInfo,
    };
  }
}
