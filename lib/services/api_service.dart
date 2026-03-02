// services/super_admin_service.dart - ✅ 100% Compatible

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:super_admin_washing/models/model.dart';

class SuperAdminService {
  static const String baseUrl = 'http://10.0.2.2:3000'; // Android emulator
  // static const String baseUrl = 'http://192.168.1.100:3000'; // Real device
  static const String path = '/api/superadmin';

  static final Map<String, String> _authHeaders = {
    'Content-Type': 'application/json',
  };

  static Map<String, String> authHeaders(String token) {
    return {..._authHeaders, 'Authorization': 'Bearer $token'};
  }

  // 🔥 AUTH
  static Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$path/login'),
        headers: _authHeaders,
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> signup({
    required String name,
    required String email,
    required String password,
    required String mobile,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$path/signup'),
        headers: _authHeaders,
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'mobile': mobile,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // 🔥 SERVICE REQUESTS
  static Future<Map<String, dynamic>?> getAllServiceRequests(
    String token,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl$path/service-requests'),
      headers: authHeaders(token),
    );
    return response.statusCode == 200 ? jsonDecode(response.body) : null;
  }

  static Future<Map<String, dynamic>?> getServiceRequestsByHub(
    String hubId,
    String token,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl$path/service-requests/hub/$hubId'),
      headers: authHeaders(token),
    );
    return response.statusCode == 200 ? jsonDecode(response.body) : null;
  }

  static Future<Map<String, dynamic>?> updateServiceRequestStatus({
    required String hubId,
    required String requestId,
    required String status,
    required String token,
  }) async {
    final response = await http.put(
      Uri.parse(
        '$baseUrl$path/service-request/$hubId/update-status/$requestId',
      ),
      headers: authHeaders(token),
      body: jsonEncode({'status': status}),
    );
    return response.statusCode == 200 ? jsonDecode(response.body) : null;
  }

  // 🔥 WASH HISTORY
  static Future<Map<String, dynamic>?> getAllWashHistory(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl$path/wash-history'),
      headers: authHeaders(token),
    );
    return response.statusCode == 200 ? jsonDecode(response.body) : null;
  }

  static Future<Map<String, dynamic>?> getWashHistoryByHub(
    String hubId,
    String token,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl$path/wash-history/hub/$hubId'),
      headers: authHeaders(token),
    );
    return response.statusCode == 200 ? jsonDecode(response.body) : null;
  }

  static Future<Map<String, dynamic>?> getWashHistoryByUser(
    String userId,
    String token,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl$path/wash-history/user/$userId'),
      headers: authHeaders(token),
    );
    return response.statusCode == 200 ? jsonDecode(response.body) : null;
  }

  // 🔥 REVENUE
  static Future<RevenueResponse?> getTotalRevenue(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl$path/revenue'),
      headers: authHeaders(token),
    );
    if (response.statusCode == 200) {
      return RevenueResponse.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  static Future<RevenueResponse?> getTodayRevenue(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl$path/revenue/today'),
      headers: authHeaders(token),
    );
    if (response.statusCode == 200) {
      return RevenueResponse.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  // 🔥 STATS
  static Future<StatsResponse?> getNewUsersLast30Days(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl$path/users/new/last-30-days'),
      headers: authHeaders(token),
    );
    if (response.statusCode == 200) {
      return StatsResponse.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  // 🔥 DEVICE ASSIGNMENT
  static Future<Map<String, dynamic>?> assignDeviceToHub({
    required String hubId,
    required String deviceId,
    required String token,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl$path/assign-devices'),
      headers: authHeaders(token),
      body: jsonEncode({'hubId': hubId, 'deviceId': deviceId}),
    );
    return response.statusCode == 200 ? jsonDecode(response.body) : null;
  }
}
