import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class ApiConfig {
  static const String defaultUrl = 'https://coil-these-preamble.ngrok-free.dev';

  static String get baseUrl {
    final raw = dotenv.env['BASE_URL']?.trim();
    if (raw != null && raw.isNotEmpty && (raw.startsWith('http://') || raw.startsWith('https://'))) {
      final clean = raw.replaceFirst(RegExp(r'/+$'), '');
      debugPrint('[ApiConfig] Using loaded BASE_URL: $clean');
      return clean;
    }
    debugPrint('[ApiConfig] Using default fallback BASE_URL: $defaultUrl');
    return defaultUrl;
  }
}
