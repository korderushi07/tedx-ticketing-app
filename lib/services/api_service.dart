import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/app_models.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? _authToken;
  CounterInfo? assignedCounter;
  String? assignedVolunteerName;
  String? assignedVolunteerCode;

  Future<void> initToken() async {
    try {
      _authToken = await _storage.read(key: 'jwt_token');
      debugPrint(
        '[ApiService] Restored token from secure storage: ${_authToken != null ? "Token present" : "None"}',
      );
    } catch (e) {
      debugPrint('[ApiService] Failed to read secure storage: $e');
    }
  }

  Future<void> setAuthToken(String? token) async {
    _authToken = token;
    if (token == null) {
      assignedCounter = null;
      assignedVolunteerName = null;
      assignedVolunteerCode = null;
    }
    try {
      if (token != null) {
        await _storage.write(key: 'jwt_token', value: token);
      } else {
        await _storage.delete(key: 'jwt_token');
      }
    } catch (e) {
      debugPrint('[ApiService] Secure storage write error: $e');
    }
    debugPrint('[ApiService] Auth token updated in secure storage');
  }

  Map<String, String> _getHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  /// Check backend API health endpoint
  Future<bool> checkHealth() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/');
    debugPrint('[API REQUEST] GET $url');
    try {
      final response = await http
          .get(url, headers: _getHeaders())
          .timeout(const Duration(seconds: 5));
      debugPrint(
        '[API RESPONSE] Status ${response.statusCode}: ${response.body}',
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('[API ERROR] GET $url failed: $e');
      return false;
    }
  }

  Future<void> setSelectedCounter(CounterInfo? counter) async {
    assignedCounter = counter;
    try {
      if (counter?.id != null) {
        await _storage.write(
          key: 'selected_counter_id',
          value: counter!.id.toString(),
        );
      } else {
        await _storage.delete(key: 'selected_counter_id');
      }
    } catch (e) {
      debugPrint('[ApiService] Error saving selected counter: $e');
    }
  }

  /// Restore user session on startup
  Future<bool> restoreSession() async {
    try {
      await initToken();
      if (_authToken == null || _authToken!.isEmpty) {
        return false;
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/auth/me');
      debugPrint('[ApiService] Checking saved session: GET $url');
      final response = await http
          .get(url, headers: _getHeaders())
          .timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        assignedVolunteerName = data['name']?.toString() ?? 'Volunteer';
        assignedVolunteerCode = data['volunteer_code']?.toString() ?? '';

        List<CounterInfo> counters = [];
        try {
          counters = await getCounters();
        } catch (error) {
          debugPrint(
            '[ApiService] Counters unavailable while restoring session: $error',
          );
        }

        // Restore previously selected counter if saved
        final savedCounterIdStr = await _storage.read(
          key: 'selected_counter_id',
        );
        if (savedCounterIdStr != null && counters.isNotEmpty) {
          final savedId = int.tryParse(savedCounterIdStr);
          final matched = counters.where((c) => c.id == savedId);
          if (matched.isNotEmpty) {
            assignedCounter = matched.first;
          }
        }

        // Counter selection is local operational context, not a volunteer assignment.
        if (assignedCounter == null && counters.isNotEmpty) {
          assignedCounter ??= counters.first;
        }

        debugPrint(
          '[ApiService] Session restored successfully for $assignedVolunteerName. Active counter: ${assignedCounter?.name}',
        );
        return true;
      } else {
        debugPrint(
          '[ApiService] Session expired or invalid (HTTP ${response.statusCode}). Clearing credentials.',
        );
        await setAuthToken(null);
        return false;
      }
    } catch (e) {
      debugPrint('[ApiService] restoreSession exception: $e');
      return false;
    }
  }

  /// Explicit Logout
  Future<void> logout() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/auth/logout');
    debugPrint('[ApiService] Logging out: POST $url');
    try {
      if (_authToken != null) {
        await http
            .post(url, headers: _getHeaders())
            .timeout(const Duration(seconds: 4));
      }
    } catch (e) {
      debugPrint('[ApiService] Remote logout call error (ignoring): $e');
    } finally {
      await setAuthToken(null);
      await setSelectedCounter(null);
      assignedVolunteerName = null;
      assignedVolunteerCode = null;
      debugPrint('[ApiService] Authenticated state cleared on logout.');
    }
  }

  /// Fetch All Available Counters
  Future<List<CounterInfo>> getCounters() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/counters');
    debugPrint('[API REQUEST] GET $url');

    try {
      final response = await http
          .get(url, headers: _getHeaders())
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List<dynamic>;
        return list
            .map(
              (item) =>
                  CounterInfo.fromJson(Map<String, dynamic>.from(item as Map)),
            )
            .toList(growable: false);
      }
      throw http.ClientException(
        'Counter request failed with HTTP ${response.statusCode}.',
        url,
      );
    } catch (e) {
      debugPrint('[API ERROR] GET $url failed: $e');
      rethrow;
    }
  }

  /// Volunteer Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/auth/login');
    debugPrint('[API REQUEST] POST $url');

    try {
      final response = await http
          .post(
            url,
            headers: _getHeaders(),
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 8));

      debugPrint('[API RESPONSE] Login status ${response.statusCode}');
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data.containsKey('access_token')) {
        await setAuthToken(data['access_token'] as String);

        if (data.containsKey('volunteer') && data['volunteer'] is Map) {
          final vol = data['volunteer'] as Map<String, dynamic>;
          assignedVolunteerName = vol['name']?.toString();
          assignedVolunteerCode = vol['volunteer_code']?.toString();
        }
      }

      return data;
    } catch (e) {
      debugPrint('[API ERROR] POST $url failed: $e');
      rethrow;
    }
  }

  /// Verify Attendee QR Code
  Future<Map<String, dynamic>> verifyQR(
    String qrToken, {
    int? counterId,
  }) async {
    final encodedToken = Uri.encodeComponent(qrToken);
    final query = counterId != null ? '?counter_id=$counterId' : '';
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/api/v1/attendees/qr/$encodedToken$query',
    );
    debugPrint('[API REQUEST] GET $url');

    try {
      final response = await http
          .get(url, headers: _getHeaders())
          .timeout(const Duration(seconds: 8));

      debugPrint(
        '[API RESPONSE] Status ${response.statusCode}: ${response.body}',
      );
      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 404) {
        final detail = body['detail'];
        final error = detail is Map ? detail['error'] : body['error'];
        final message = detail is Map ? detail['message'] : body['message'];
        return {
          'error': error ?? 'VERIFICATION_FAILED',
          'message':
              message?.toString() ??
              (error == 'INVALID_QR'
                  ? 'This QR code is not registered with TEDx.'
                  : 'Ticket verification failed.'),
        };
      }

      if (response.statusCode != 200) {
        final detail = body['detail'];
        final error = detail is Map ? detail['error'] : body['error'];
        final message = detail is Map ? detail['message'] : body['message'];
        return {
          'error': error ?? 'VERIFICATION_FAILED',
          'message':
              message?.toString() ??
              'Ticket verification failed with HTTP ${response.statusCode}.',
        };
      }
      return body;
    } catch (e) {
      debugPrint('[API ERROR] GET $url failed: $e');
      rethrow;
    }
  }

  /// Create Redemption Claim
  Future<Map<String, dynamic>> claimRedemption({
    required int attendeeId,
    required int addonId,
    required int counterId,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/redemptions');
    final payload = {
      'attendee_id': attendeeId,
      'addon_id': addonId,
      'counter_id': counterId,
    };
    debugPrint('[API REQUEST] POST $url | Body: ${jsonEncode(payload)}');

    try {
      final response = await http
          .post(url, headers: _getHeaders(), body: jsonEncode(payload))
          .timeout(const Duration(seconds: 8));

      debugPrint(
        '[API RESPONSE] Status ${response.statusCode}: ${response.body}',
      );
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('[API ERROR] POST $url failed: $e');
      rethrow;
    }
  }

  /// Get Volunteer's Redemption History
  Future<List<dynamic>> getMyHistory() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/redemptions/my-history');
    debugPrint('[API REQUEST] GET $url');

    try {
      final response = await http
          .get(url, headers: _getHeaders())
          .timeout(const Duration(seconds: 8));

      debugPrint(
        '[API RESPONSE] Status ${response.statusCode}: ${response.body}',
      );
      return jsonDecode(response.body) as List<dynamic>;
    } catch (e) {
      debugPrint('[API ERROR] GET $url failed: $e');
      rethrow;
    }
  }

  /// Get the attendee's current entitlement and redemption details.
  Future<List<dynamic>> getAttendeeEntitlements(int attendeeId) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/api/v1/attendees/$attendeeId/entitlements',
    );
    debugPrint('[API REQUEST] GET $url');

    try {
      final response = await http
          .get(url, headers: _getHeaders())
          .timeout(const Duration(seconds: 8));

      debugPrint(
        '[API RESPONSE] Status ${response.statusCode}: ${response.body}',
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      throw http.ClientException(
        'Attendee entitlements request failed with HTTP ${response.statusCode}.',
        url,
      );
    } catch (e) {
      debugPrint('[API ERROR] GET $url failed: $e');
      rethrow;
    }
  }

  /// Get Counter Statistics from Database
  Future<Map<String, dynamic>> getCounterStats(int counterId) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/api/v1/counters/$counterId/stats',
    );
    debugPrint('[API REQUEST] GET $url');

    try {
      final response = await http
          .get(url, headers: _getHeaders())
          .timeout(const Duration(seconds: 8));

      debugPrint(
        '[API RESPONSE] Status ${response.statusCode}: ${response.body}',
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw http.ClientException(
        'Counter stats request failed with HTTP ${response.statusCode}.',
        url,
      );
    } catch (e) {
      debugPrint('[API ERROR] GET $url failed: $e');
      rethrow;
    }
  }
}
