import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class ApiConfig {
  static String get defaultUrl {
    if (kIsWeb) return 'http://localhost:8000';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    } catch (_) {}
    return 'http://127.0.0.1:8000';
  }

  static String? _readEnv(String key) {
    try {
      if (!dotenv.isInitialized) return null;
      return dotenv.env[key]?.trim();
    } catch (_) {
      return null;
    }
  }

  static String get baseUrl {
    final raw = _readEnv('BASE_URL');
    if (raw != null && raw.isNotEmpty && (raw.startsWith('http://') || raw.startsWith('https://'))) {
      final clean = raw.replaceFirst(RegExp(r'/+$'), '');
      debugPrint('[ApiConfig] Using loaded BASE_URL: $clean');
      return clean;
    }
    final fallback = defaultUrl;
    debugPrint('[ApiConfig] Using default fallback BASE_URL: $fallback');
    return fallback;
  }
}
