import 'dart:convert';

import 'package:firebaseproject/modals/tech_guide_response.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DocLink {
  final String name;
  final String url;

  DocLink({required this.name, required this.url});
}
