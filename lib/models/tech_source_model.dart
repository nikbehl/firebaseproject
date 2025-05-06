class TechSource {
  final String name;
  final String url;

  TechSource({required this.name, required this.url});

  factory TechSource.fromJson(Map<String, dynamic> json) {
    return TechSource(
      name: json['name'] ?? '',
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
    };
  }
}
