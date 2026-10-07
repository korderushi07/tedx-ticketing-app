import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _authToken;
  int? assignedCounterId;

  void setAuthToken(String? token) {
    _authToken = token;
    debugPrint('[ApiService] Auth token updated: ${_authToken != null ? "Token set" : "No token"}');
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
      final response = await http.get(url, headers: _getHeaders()).timeout(const Duration(seconds: 5));
      debugPrint('[API RESPONSE] Status ${response.statusCode}: ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('[API ERROR] GET $url failed: $e');
      return false;
    }
  }

  /// Volunteer Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/auth/login');
    debugPrint('[API REQUEST] POST $url | Body: {"email": "$email"}');
    
    try {
      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 8));

      debugPrint('[API RESPONSE] Status ${response.statusCode}: ${response.body}');
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode == 200 && data.containsKey('access_token')) {
        setAuthToken(data['access_token'] as String);
        if (data.containsKey('volunteer') && data['volunteer'] is Map) {
          final vol = data['volunteer'] as Map<String, dynamic>;
          assignedCounterId = vol['counter_id'] as int?;
          debugPrint('[ApiService] Assigned Counter ID: $assignedCounterId');
        }
      }
      
      return data;
    } catch (e) {
      debugPrint('[API ERROR] POST $url failed: $e');
      rethrow;
    }
  }

  /// Verify Attendee QR Code
  Future<Map<String, dynamic>> verifyQR(String qrToken) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/attendees/qr/$qrToken');
    debugPrint('[API REQUEST] GET $url');

    try {
      final response = await http.get(
        url,
        headers: _getHeaders(),
      ).timeout(const Duration(seconds: 8));

      debugPrint('[API RESPONSE] Status ${response.statusCode}: ${response.body}');
      return jsonDecode(response.body) as Map<String, dynamic>;
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
      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 8));

      debugPrint('[API RESPONSE] Status ${response.statusCode}: ${response.body}');
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
      final response = await http.get(
        url,
        headers: _getHeaders(),
      ).timeout(const Duration(seconds: 8));

      debugPrint('[API RESPONSE] Status ${response.statusCode}: ${response.body}');
      return jsonDecode(response.body) as List<dynamic>;
    } catch (e) {
      debugPrint('[API ERROR] GET $url failed: $e');
      rethrow;
    }
  }
}
