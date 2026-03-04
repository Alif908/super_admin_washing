import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ═══════════════════════════════════════════════
//  BASE URL
//  Physical device  → your PC Wi-Fi IP + PORT
//  Android Emulator → replace with 10.0.2.2:5000
// ═══════════════════════════════════════════════
const String _base = 'http://192.168.1.3:5000/api/superadmin';

// ═══════════════════════════════════════════════
//  TOKEN HELPERS
// ═══════════════════════════════════════════════
Future<void> _saveToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('superadmin_token', token);
}

Future<String?> getSavedToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('superadmin_token');
}

Future<void> clearSavedToken() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('superadmin_token');
}

// ═══════════════════════════════════════════════
//  HEADERS
// ═══════════════════════════════════════════════
const Map<String, String> _jsonHeader = {
  'Content-Type': 'application/json',
};

Future<Map<String, String>> _authHeader() async {
  final token = await getSavedToken();
  return {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };
}

// ═══════════════════════════════════════════════
//  SUPER ADMIN SERVICE
// ═══════════════════════════════════════════════
class SuperAdminService {

  // ─────────────────────────────────────────────
  //  AUTH
  // ─────────────────────────────────────────────

  /// POST /api/superadmin/signup
  static Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
    required String mobile,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/signup'),
        headers: _jsonHeader,
        body: jsonEncode({
          'name':     name,
          'email':    email,
          'password': password,
          'mobile':   mobile,
        }),
      ).timeout(const Duration(seconds: 15));

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return {'success': res.statusCode == 201, ...body};
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// POST /api/superadmin/login
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/login'),
        headers: _jsonHeader,
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 15));

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && body['token'] != null) {
        await _saveToken(body['token']);
      }
      return {'success': res.statusCode == 200, ...body};
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ─────────────────────────────────────────────
  //  PACKAGES
  // ─────────────────────────────────────────────

  /// POST /api/superadmin/packages
  static Future<Map<String, dynamic>> addPackage({
    required String packageName,
    String? description,
    required double price,
    String? statusCode,
  }) async {
    try {
      final body = <String, dynamic>{
        'packageName': packageName,
        'price': price,
      };
      if (description != null && description.isNotEmpty) body['description'] = description;
      if (statusCode != null && statusCode.isNotEmpty)   body['statusCode']   = statusCode;

      final res = await http.post(
        Uri.parse('$_base/packages'),
        headers: await _authHeader(),
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      final resBody = jsonDecode(res.body) as Map<String, dynamic>;
      return {
        'success': res.statusCode == 200 || res.statusCode == 201,
        ...resBody,
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// GET /api/superadmin/packages
  static Future<Map<String, dynamic>> getAllPackages() async {
    try {
      final res = await http.get(
        Uri.parse('$_base/packages'),
        headers: await _authHeader(),
      ).timeout(const Duration(seconds: 15));

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return {'success': res.statusCode == 200, ...body};
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ─────────────────────────────────────────────
  //  HUBS
  // ─────────────────────────────────────────────

  /// POST /api/superadmin/hubs
  static Future<Map<String, dynamic>> registerHub({
    required String hubName,
    String? hubCode,
    double? latitude,
    double? longitude,
    required String hubOwnerName,
    required int hubOwnerId,
    required String email,
    required String mobile,
    String? address,
    String? bankName,
    String? accountNumber,
    String? ifscCode,
    String? operatorName,
    String? operatorMobile,
  }) async {
    try {
      final body = <String, dynamic>{
        'hubName':      hubName,
        'hubOwnerId':   hubOwnerId,
        'hubOwnerName': hubOwnerName,
        'email':        email,
        'mobile':       mobile,
      };
      if (hubCode != null && hubCode.isNotEmpty)               body['hubCode']        = hubCode;
      if (latitude != null)                                    body['latitude']       = latitude;
      if (longitude != null)                                   body['longitude']      = longitude;
      if (address != null && address.isNotEmpty)               body['address']        = address;
      if (bankName != null && bankName.isNotEmpty)             body['bankName']       = bankName;
      if (accountNumber != null && accountNumber.isNotEmpty)   body['accountNumber']  = accountNumber;
      if (ifscCode != null && ifscCode.isNotEmpty)             body['ifscCode']       = ifscCode;
      if (operatorName != null && operatorName.isNotEmpty)     body['operatorName']   = operatorName;
      if (operatorMobile != null && operatorMobile.isNotEmpty) body['operatorMobile'] = operatorMobile;

      final res = await http.post(
        Uri.parse('$_base/hubs'),
        headers: await _authHeader(),
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      final resBody = jsonDecode(res.body) as Map<String, dynamic>;
      return {
        'success': res.statusCode == 200 || res.statusCode == 201,
        ...resBody,
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// GET /api/superadmin/hubs
  static Future<Map<String, dynamic>> getAllHubs() async {
    try {
      final res = await http.get(
        Uri.parse('$_base/hubs'),
        headers: await _authHeader(),
      ).timeout(const Duration(seconds: 15));

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return {'success': res.statusCode == 200, ...body};
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ─────────────────────────────────────────────
  //  COUPONS
  // ─────────────────────────────────────────────

  /// POST /api/superadmin/coupons
  static Future<Map<String, dynamic>> addCoupon({
    required String couponCode,
    required double discountPercentage,
    required int maxUsagePerUser,
    required DateTime expiryDate,
  }) async {
    try {
      final body = <String, dynamic>{
        'couponCode':         couponCode,
        'discountPercentage': discountPercentage,
        'maxUsagePerUser':    maxUsagePerUser,
        'expiryDate': '${expiryDate.year}-'
            '${expiryDate.month.toString().padLeft(2, '0')}-'
            '${expiryDate.day.toString().padLeft(2, '0')}',
      };

      final res = await http.post(
        Uri.parse('$_base/coupons'),
        headers: await _authHeader(),
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      final resBody = jsonDecode(res.body) as Map<String, dynamic>;
      return {
        'success': res.statusCode == 200 || res.statusCode == 201,
        ...resBody,
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// GET /api/superadmin/coupons
  static Future<Map<String, dynamic>> getAllCoupons() async {
    try {
      final res = await http.get(
        Uri.parse('$_base/coupons'),
        headers: await _authHeader(),
      ).timeout(const Duration(seconds: 15));

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return {'success': res.statusCode == 200, ...body};
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ─────────────────────────────────────────────
  //  DEVICES
  // ─────────────────────────────────────────────

  /// POST /api/superadmin/devices
  /// Registers a new device by its deviceId string.
  static Future<Map<String, dynamic>> addDevice({
    required String deviceId,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/devices'),
        headers: await _authHeader(),
        body: jsonEncode({'deviceId': deviceId}),
      ).timeout(const Duration(seconds: 15));

      final resBody = jsonDecode(res.body) as Map<String, dynamic>;
      return {
        'success': res.statusCode == 200 || res.statusCode == 201,
        ...resBody,
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// GET /api/superadmin/devices
  static Future<Map<String, dynamic>> getAllDevices() async {
    try {
      final res = await http.get(
        Uri.parse('$_base/devices'),
        headers: await _authHeader(),
      ).timeout(const Duration(seconds: 15));

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return {'success': res.statusCode == 200, ...body};
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ─────────────────────────────────────────────
  //  ASSIGN DEVICE TO HUB
  // ─────────────────────────────────────────────

  /// POST /api/superadmin/assign-devices
  static Future<Map<String, dynamic>> assignDeviceToHub({
    required int hubId,
    required String deviceId,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/assign-devices'),
        headers: await _authHeader(),
        body: jsonEncode({'hubId': hubId, 'deviceId': deviceId}),
      ).timeout(const Duration(seconds: 15));

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return {'success': res.statusCode == 200, ...body};
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ─────────────────────────────────────────────
  //  SERVICE REQUESTS
  // ─────────────────────────────────────────────

  /// GET /api/superadmin/service-requests
  static Future<Map<String, dynamic>> getAllServiceRequests() async {
    try {
      final res = await http.get(
        Uri.parse('$_base/service-requests'),
        headers: await _authHeader(),
      ).timeout(const Duration(seconds: 15));

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return {'success': res.statusCode == 200, ...body};
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// GET /api/superadmin/service-requests/hub/:hubId
  static Future<Map<String, dynamic>> getServiceRequestsByHub(int hubId) async {
    try {
      final res = await http.get(
        Uri.parse('$_base/service-requests/hub/$hubId'),
        headers: await _authHeader(),
      ).timeout(const Duration(seconds: 15));

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return {'success': res.statusCode == 200, ...body};
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// PUT /api/superadmin/service-request/:hubId/update-status/:requestId
  static Future<Map<String, dynamic>> updateServiceRequestStatus({
    required int hubId,
    required int requestId,
    required String status,
  }) async {
    try {
      final res = await http.put(
        Uri.parse('$_base/service-request/$hubId/update-status/$requestId'),
        headers: await _authHeader(),
        body: jsonEncode({'status': status}),
      ).timeout(const Duration(seconds: 15));

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return {'success': res.statusCode == 200, ...body};
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ─────────────────────────────────────────────
  //  WASH HISTORY
  // ─────────────────────────────────────────────

  /// GET /api/superadmin/wash-history
  static Future<Map<String, dynamic>> getAllWashHistory() async {
    try {
      final res = await http.get(
        Uri.parse('$_base/wash-history'),
        headers: await _authHeader(),
      ).timeout(const Duration(seconds: 15));

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return {'success': res.statusCode == 200, ...body};
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// GET /api/superadmin/wash-history/hub/:hubId
  static Future<Map<String, dynamic>> getWashHistoryByHub(int hubId) async {
    try {
      final res = await http.get(
        Uri.parse('$_base/wash-history/hub/$hubId'),
        headers: await _authHeader(),
      ).timeout(const Duration(seconds: 15));

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return {'success': res.statusCode == 200, ...body};
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// GET /api/superadmin/wash-history/user/:userId
  static Future<Map<String, dynamic>> getWashHistoryByUser(int userId) async {
    try {
      final res = await http.get(
        Uri.parse('$_base/wash-history/user/$userId'),
        headers: await _authHeader(),
      ).timeout(const Duration(seconds: 15));

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return {'success': res.statusCode == 200, ...body};
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ─────────────────────────────────────────────
  //  REVENUE
  // ─────────────────────────────────────────────

  /// GET /api/superadmin/revenue
  static Future<Map<String, dynamic>> getTotalRevenue() async {
    try {
      final res = await http.get(
        Uri.parse('$_base/revenue'),
        headers: await _authHeader(),
      ).timeout(const Duration(seconds: 15));

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return {'success': res.statusCode == 200, ...body};
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// GET /api/superadmin/revenue/today
  static Future<Map<String, dynamic>> getTodayRevenue() async {
    try {
      final res = await http.get(
        Uri.parse('$_base/revenue/today'),
        headers: await _authHeader(),
      ).timeout(const Duration(seconds: 15));

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return {'success': res.statusCode == 200, ...body};
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// GET /api/superadmin/revenue/hub/:hubId
  static Future<Map<String, dynamic>> getHubRevenue(int hubId) async {
    try {
      final res = await http.get(
        Uri.parse('$_base/revenue/hub/$hubId'),
        headers: await _authHeader(),
      ).timeout(const Duration(seconds: 15));

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return {'success': res.statusCode == 200, ...body};
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ─────────────────────────────────────────────
  //  USERS
  // ─────────────────────────────────────────────

  /// GET /api/superadmin/users
  static Future<Map<String, dynamic>> getAllUsers() async {
    try {
      final res = await http.get(
        Uri.parse('$_base/users'),
        headers: await _authHeader(),
      ).timeout(const Duration(seconds: 15));

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return {'success': res.statusCode == 200, ...body};
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// GET /api/superadmin/users/new/last-30-days
  static Future<Map<String, dynamic>> getNewUsersLast30Days() async {
    try {
      final res = await http.get(
        Uri.parse('$_base/users/new/last-30-days'),
        headers: await _authHeader(),
      ).timeout(const Duration(seconds: 15));

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return {'success': res.statusCode == 200, ...body};
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ─────────────────────────────────────────────
  //  HUB OWNERS
  // ─────────────────────────────────────────────

  /// GET /api/superadmin/hubowners/new/last-30-days
  static Future<Map<String, dynamic>> getNewHubOwnersLast30Days() async {
    try {
      final res = await http.get(
        Uri.parse('$_base/hubowners/new/last-30-days'),
        headers: await _authHeader(),
      ).timeout(const Duration(seconds: 15));

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return {'success': res.statusCode == 200, ...body};
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}