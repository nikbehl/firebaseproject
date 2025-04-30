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
}
