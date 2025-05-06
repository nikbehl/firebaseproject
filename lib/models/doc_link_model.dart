class DocLink {
  final String name;
  final String url;

  DocLink({required this.name, required this.url});

  factory DocLink.fromJson(Map<String, dynamic> json) {
    return DocLink(
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
