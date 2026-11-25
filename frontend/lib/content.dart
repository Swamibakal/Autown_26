import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// All website text lives in assets/content.json (no backend server).
/// Edit that file to update the site, including the Zoho Backstage links.
Future<Map<String, dynamic>> loadSiteContent() async {
  final raw = await rootBundle.loadString('assets/content.json');
  return jsonDecode(raw) as Map<String, dynamic>;
}
