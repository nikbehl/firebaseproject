import 'package:firebaseproject/models/doc_link_model.dart';
import 'package:firebaseproject/models/tech_source_model.dart';
import 'package:firebaseproject/models/version_info.dart';

class TechGuideResponse {
  final String mainContent;
  final List<TechSource> sources;
  final List<DocLink> documentationLinks;
  final List<VersionInfo> versionDetails;

  TechGuideResponse({
    required this.mainContent,
    required this.sources,
    required this.documentationLinks,
    this.versionDetails = const [],
  });

  factory TechGuideResponse.fromJson(Map<String, dynamic> json) {
    return TechGuideResponse(
      mainContent: json['mainContent'] ?? '',
      sources: (json['sources'] as List?)
              ?.map((e) => TechSource.fromJson(e))
              .toList() ??
          [],
      documentationLinks: (json['documentationLinks'] as List?)
              ?.map((e) => DocLink.fromJson(e))
              .toList() ??
          [],
      versionDetails: (json['versionDetails'] as List?)
              ?.map((e) => VersionInfo.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mainContent': mainContent,
      'sources': sources.map((e) => e.toJson()).toList(),
      'documentationLinks': documentationLinks.map((e) => e.toJson()).toList(),
      'versionDetails': versionDetails.map((e) => e.toJson()).toList(),
    };
  }

  factory TechGuideResponse.fromRawResponse(String rawResponse) {
    // Check if the response has sources and documentation sections
    final List<TechSource> sources = [];
    final List<DocLink> documentationLinks = [];
    String mainContent = rawResponse;

    // Extract sources section if it exists
    final RegExp sourcesRegex = RegExp(
        r'(?:Sources|References):\s*(?:\n|-)*((?:(?:\d+\.\s*|\*\s*|-).*\n*)+)',
        caseSensitive: false);
    final Match? sourcesMatch = sourcesRegex.firstMatch(rawResponse);

    if (sourcesMatch != null) {
      final String sourcesText = sourcesMatch.group(1) ?? '';
      final List<String> sourcesList = sourcesText
          .split(RegExp(r'\n(?:\d+\.\s*|\*\s*|-)'))
          .where((s) => s.trim().isNotEmpty)
          .toList();

      for (final source in sourcesList) {
        final RegExp linkRegex = RegExp(r'(https?://\S+)');
        final Match? linkMatch = linkRegex.firstMatch(source);
        if (linkMatch != null) {
          sources.add(TechSource(
            name: source.replaceAll(linkMatch.group(0) ?? '', '').trim(),
            url: linkMatch.group(0) ?? '',
          ));
        } else {
          // Add even if there's no URL
          sources.add(TechSource(name: source.trim(), url: ''));
        }
      }

      // Remove sources section from main content
      mainContent = mainContent.replaceAll(sourcesMatch.group(0) ?? '', '');
    }

    // Extract documentation links section if it exists
    final RegExp docsRegex = RegExp(
        r'(?:Documentation|Official\s+Documentation):\s*(?:\n|-)*((?:(?:\d+\.\s*|\*\s*|-).*\n*)+)',
        caseSensitive: false);
    final Match? docsMatch = docsRegex.firstMatch(rawResponse);

    if (docsMatch != null) {
      final String docsText = docsMatch.group(1) ?? '';
      final List<String> docsList = docsText
          .split(RegExp(r'\n(?:\d+\.\s*|\*\s*|-)'))
          .where((s) => s.trim().isNotEmpty)
          .toList();

      for (final doc in docsList) {
        final RegExp linkRegex = RegExp(r'(https?://\S+)');
        final Match? linkMatch = linkRegex.firstMatch(doc);
        if (linkMatch != null) {
          documentationLinks.add(DocLink(
            name: doc.replaceAll(linkMatch.group(0) ?? '', '').trim(),
            url: linkMatch.group(0) ?? '',
          ));
        } else {
          // Add even if there's no URL
          documentationLinks.add(DocLink(name: doc.trim(), url: ''));
        }
      }

      // Remove documentation section from main content
      mainContent = mainContent.replaceAll(docsMatch.group(0) ?? '', '');
    }

    // Additional check for embedded links in the content
    if (sources.isEmpty && documentationLinks.isEmpty) {
      final RegExp linkRegex = RegExp(r'\[(.*?)\]\((https?://\S+)\)');
      final Iterable<Match> matches = linkRegex.allMatches(rawResponse);

      for (final match in matches) {
        final String name = match.group(1) ?? '';
        final String url = match.group(2) ?? '';

        if (url.contains('documentation') ||
            url.contains('docs') ||
            url.contains('reference')) {
          documentationLinks.add(DocLink(name: name, url: url));
        } else {
          sources.add(TechSource(name: name, url: url));
        }
      }
    }

    // Extract version information if it exists
    final List<VersionInfo> versionDetails = [];
    final RegExp versionRegex = RegExp(
        r'(?:Latest\s+Versions|Current\s+Versions|Version\s+Information):\s*(?:\n|-)*((?:(?:\d+\.\s*|\*\s*|-).*\n*)+)',
        caseSensitive: false);
    final Match? versionMatch = versionRegex.firstMatch(rawResponse);

    if (versionMatch != null) {
      final String versionText = versionMatch.group(1) ?? '';
      final List<String> versionsList = versionText
          .split(RegExp(r'\n(?:\d+\.\s*|\*\s*|-)'))
          .where((s) => s.trim().isNotEmpty)
          .toList();

      for (final version in versionsList) {
        // Try to extract technology name and version number
        final RegExp techVersionRegex = RegExp(
            r'([^:]+):\s*(?:v|version\s+)?([0-9\.]+)',
            caseSensitive: false);
        final Match? techVersionMatch = techVersionRegex.firstMatch(version);

        if (techVersionMatch != null) {
          versionDetails.add(VersionInfo(
            technology: techVersionMatch.group(1)?.trim() ?? '',
            version: techVersionMatch.group(2)?.trim() ?? '',
            releaseDate: _extractReleaseDate(version),
            additionalInfo: version.trim(),
          ));
        } else {
          // Fallback if the regex doesn't match
          versionDetails.add(VersionInfo(
            technology: '',
            version: '',
            releaseDate: '',
            additionalInfo: version.trim(),
          ));
        }
      }

      // Remove version section from main content
      mainContent = mainContent.replaceAll(versionMatch.group(0) ?? '', '');
    }

    // If no version section was found, try to extract version information from the content
    if (versionDetails.isEmpty) {
      final RegExp inlineVersionRegex = RegExp(
          r'(?:([a-zA-Z0-9\s\.\/]+)\s+version\s+(?:is\s+)?([0-9\.]+))',
          caseSensitive: false);
      final Iterable<Match> inlineMatches =
          inlineVersionRegex.allMatches(rawResponse);

      for (final match in inlineMatches) {
        final String technology = match.group(1)?.trim() ?? '';
        final String version = match.group(2)?.trim() ?? '';

        // Avoid duplicates
        if (!versionDetails.any(
            (v) => v.technology.toLowerCase() == technology.toLowerCase())) {
          versionDetails.add(VersionInfo(
            technology: technology,
            version: version,
            releaseDate: '',
            additionalInfo: '',
          ));
        }
      }
    }

    return TechGuideResponse(
      mainContent: mainContent.trim(),
      sources: sources,
      documentationLinks: documentationLinks,
      versionDetails: versionDetails,
    );
  }
}

// Helper method to extract release date from version string
String _extractReleaseDate(String versionText) {
  final RegExp dateRegex = RegExp(
      r'(?:released|release date|published)(?:\s+on)?\s+([A-Za-z]+\s+\d{1,2},?\s+\d{4}|\d{1,2}\s+[A-Za-z]+\s+\d{4}|\d{1,2}/\d{1,2}/\d{4}|\d{4}-\d{2}-\d{2})',
      caseSensitive: false);

  final Match? dateMatch = dateRegex.firstMatch(versionText);
  if (dateMatch != null) {
    return dateMatch.group(1)?.trim() ?? '';
  }
  return '';
}
