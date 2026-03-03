import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_admin_washing/models/auth_model.dart';

class AuthService {
  // ── Change port to match your process.env.PORT ──
  static const String _baseUrl = 'http://192.168.1.3:3000/api/superadmin';

  static const Map<String, String> _jsonHeaders = {
    'Content-Type': 'application/json',
  };

  // ── Token helpers ─────────────────────────────

  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('superadmin_token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('superadmin_token');
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('superadmin_token');
  }

  // ── POST /api/superadmin/register ─────────────

  static Future<AuthResponse> signUp({
    required String name,
    required String email,
    required String password,
    required String mobile,
  }) async {
    try {
      final request = SignUpRequestModel(
        name: name,
        email: email,
        password: password,
        mobile: mobile,
      );

      final response = await http
          .post(
            Uri.parse('$_baseUrl/register'),
            headers: _jsonHeaders,
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 15));

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final isSuccess =
          response.statusCode == 200 || response.statusCode == 201;

      if (isSuccess && body['token'] != null) {
        await _saveToken(body['token']);
      }

      return AuthResponse.fromJson(body, success: isSuccess);
    } on Exception catch (e) {
      return AuthResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // ── POST /api/superadmin/login ─────────────────

  static Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/login'),
            headers: _jsonHeaders,
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 15));

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final isSuccess = response.statusCode == 200;

      if (isSuccess && body['token'] != null) {
        await _saveToken(body['token']);
      }

      return AuthResponse.fromJson(body, success: isSuccess);
    } on Exception catch (e) {
      return AuthResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }
}
