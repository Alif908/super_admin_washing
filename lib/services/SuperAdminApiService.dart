import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_admin_washing/models/superadminmodel.dart';

// ─────────────────────────────────────────────
//  CONFIG
// ─────────────────────────────────────────────
const String _baseHost = 'https://be.washist.com';

const String _base = '$_baseHost/api/superadmin';
const String _device = '$_baseHost/api/device';
const String _pkg = '$_baseHost/api/hubpackage';
const String _hub = '$_baseHost/api/hub';
const String _coupon = '$_baseHost/api/coupon';

const Duration _timeout = Duration(seconds: 15);

// ─────────────────────────────────────────────
//  TOKEN HELPERS
// ─────────────────────────────────────────────
const _kTokenKey = 'superadmin_token';

Future<void> saveToken(String token) async =>
    (await SharedPreferences.getInstance()).setString(_kTokenKey, token);

Future<String?> getSavedToken() async =>
    (await SharedPreferences.getInstance()).getString(_kTokenKey);

Future<void> clearSavedToken() async =>
    (await SharedPreferences.getInstance()).remove(_kTokenKey);

// ─────────────────────────────────────────────
//  HEADERS
// ─────────────────────────────────────────────
const Map<String, String> _jsonHeaders = {'Content-Type': 'application/json'};

Future<Map<String, String>> _authHeaders() async {
  final token = await getSavedToken();
  return {
    'Content-Type': 'application/json',
    if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
  };
}

// ─────────────────────────────────────────────
//  LOGGER
// ─────────────────────────────────────────────
void _log(String tag, String msg) {
  if (kDebugMode) debugPrint('[$tag] $msg');
}

// ─────────────────────────────────────────────
//  SAFE JSON DECODE
// ─────────────────────────────────────────────
Map<String, dynamic> _safeJson(http.Response res, String tag) {
  try {
    final decoded = jsonDecode(res.body);
    if (decoded is Map<String, dynamic>) return decoded;
    return {'success': false, 'message': 'Unexpected response format'};
  } catch (_) {
    final preview = res.body.length > 150
        ? '${res.body.substring(0, 150)}…'
        : res.body;
    _log(tag, '❌ Non-JSON [${res.statusCode}]: $preview');
    return {
      'success': false,
      'message': switch (res.statusCode) {
        404 => 'Endpoint not found (404). Backend route may be missing.',
        401 => 'Unauthorized. Please login again.',
        403 => 'Forbidden. You do not have permission.',
        500 => 'Server error (500). Check backend logs.',
        _ => 'Backend returned status ${res.statusCode}.',
      },
    };
  }
}

// ─────────────────────────────────────────────
//  CORE HTTP CALLER
// ─────────────────────────────────────────────
Future<Map<String, dynamic>> _call(
  String tag,
  Future<http.Response> Function() request, {
  int expectedStatus = 200,
}) async {
  try {
    _log(tag, '→ sending...');
    final res = await request();
    final preview = res.body.length > 200
        ? '${res.body.substring(0, 200)}…'
        : res.body;
    _log(tag, '← ${res.statusCode} | $preview');
    final body = _safeJson(res, tag);
    final ok =
        res.statusCode == expectedStatus ||
        (expectedStatus == 201 && res.statusCode == 200);
    return {'success': ok, ...body};
  } on SocketException catch (e) {
    _log(tag, '❌ SocketException: $e');
    return {
      'success': false,
      'message': 'Cannot reach server. Check IP/port or Wi-Fi.',
    };
  } on TimeoutException {
    _log(tag, '❌ Timeout after ${_timeout.inSeconds}s');
    return {
      'success': false,
      'message': 'Request timed out. Server may be slow or unreachable.',
    };
  } on HttpException catch (e) {
    _log(tag, '❌ HttpException: $e');
    return {'success': false, 'message': 'HTTP error: $e'};
  } catch (e) {
    _log(tag, '❌ Unexpected: $e');
    return {'success': false, 'message': 'Unexpected error: $e'};
  }
}

// ═══════════════════════════════════════════════════
//  SUPER ADMIN SERVICE
// ═══════════════════════════════════════════════════
class SuperAdminService {
  // ── AUTH ──────────────────────────────────────────

  static Future<AuthResponse> signup({
    required String name,
    required String email,
    required String password,
    required String mobile,
  }) async {
    final raw = await _call(
      'SIGNUP',
      () => http
          .post(
            Uri.parse('$_base/signup'),
            headers: _jsonHeaders,
            body: jsonEncode({
              'name': name,
              'email': email,
              'password': password,
              'mobile': mobile,
            }),
          )
          .timeout(_timeout),
      expectedStatus: 201,
    );
    return AuthResponse.fromJson(raw);
  }

  static Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final raw = await _call(
      'LOGIN',
      () => http
          .post(
            Uri.parse('$_base/login'),
            headers: _jsonHeaders,
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(_timeout),
    );
    final res = AuthResponse.fromJson(raw);
    if (res.hasToken) {
      await saveToken(res.token!);
      _log('LOGIN', '✅ Token saved');
    }
    return res;
  }

  static Future<void> logout() async {
    await clearSavedToken();
    _log('LOGOUT', '✅ Token cleared');
  }

  // ── PACKAGES ─────────────────────────────────────

  static Future<PackageListResponse> getAllPackages() async {
    final raw = await _call(
      'GET_PACKAGES',
      () async => http
          .get(Uri.parse('$_pkg/all-packages'), headers: await _authHeaders())
          .timeout(_timeout),
    );
    return PackageListResponse.fromJson(raw);
  }

  static Future<PackageCreateResponse> addPackage({
    required String packageName,
    String? description,
    required double price,
    String? statusCode,
  }) async {
    final raw = await _call(
      'ADD_PACKAGE',
      () async => http
          .post(
            Uri.parse('$_pkg/add'),
            headers: await _authHeaders(),
            body: jsonEncode({
              'packageName': packageName,
              'price': price,
              if (description != null && description.isNotEmpty)
                'description': description,
              if (statusCode != null && statusCode.isNotEmpty)
                'statusCode': statusCode,
            }),
          )
          .timeout(_timeout),
      expectedStatus: 201,
    );
    return PackageCreateResponse.fromJson(raw);
  }

  static Future<Map<String, dynamic>> updatePackage({
    required int packageId,
    required Map<String, dynamic> fields,
  }) => _call(
    'UPDATE_PACKAGE',
    () async => http
        .put(
          Uri.parse('$_pkg/edit/$packageId'),
          headers: await _authHeaders(),
          body: jsonEncode(fields),
        )
        .timeout(_timeout),
  );

  static Future<Map<String, dynamic>> deletePackage(int packageId) => _call(
    'DELETE_PACKAGE',
    () async => http
        .delete(
          Uri.parse('$_pkg/delete/$packageId'),
          headers: await _authHeaders(),
        )
        .timeout(_timeout),
  );

  // ── HUBS ─────────────────────────────────────────

  static Future<HubListResponse> getAllHubs() async {
    final raw = await _call(
      'GET_HUBS',
      () async => http
          .get(Uri.parse('$_hub/all-hubs'), headers: await _authHeaders())
          .timeout(_timeout),
    );
    return HubListResponse.fromJson(raw);
  }

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
  }) => _call(
    'REGISTER_HUB',
    () async => http
        .post(
          Uri.parse('$_hub/add-hub'),
          headers: await _authHeaders(),
          body: jsonEncode({
            'hubName': hubName,
            'ownerId': hubOwnerId,
            'hubOwnerName': hubOwnerName,
            'email': email,
            'mobile': mobile,
            if (hubCode != null && hubCode.isNotEmpty) 'hubId': hubCode,
            if (latitude != null) 'latitude': latitude,
            if (longitude != null) 'longitude': longitude,
            if (address != null && address.isNotEmpty) 'address': address,
            if (bankName != null && bankName.isNotEmpty) 'bankName': bankName,
            if (accountNumber != null && accountNumber.isNotEmpty)
              'acNumber': accountNumber,
            if (ifscCode != null && ifscCode.isNotEmpty) 'ifscCode': ifscCode,
            if (operatorName != null && operatorName.isNotEmpty)
              'operatorName': operatorName,
            if (operatorMobile != null && operatorMobile.isNotEmpty)
              'operatorMobile': operatorMobile,
          }),
        )
        .timeout(_timeout),
    expectedStatus: 201,
  );

  static Future<Map<String, dynamic>> getHubById(int hubId) => _call(
    'GET_HUB_BY_ID',
    () async => http
        .get(Uri.parse('$_hub/hub/$hubId'), headers: await _authHeaders())
        .timeout(_timeout),
  );

  static Future<Map<String, dynamic>> updateHub({
    required int hubId,
    required Map<String, dynamic> fields,
  }) => _call(
    'UPDATE_HUB',
    () async => http
        .put(
          Uri.parse('$_hub/update-hub/$hubId'),
          headers: await _authHeaders(),
          body: jsonEncode(fields),
        )
        .timeout(_timeout),
  );

  static Future<Map<String, dynamic>> deleteHub(int hubId) => _call(
    'DELETE_HUB',
    () async => http
        .delete(
          Uri.parse('$_hub/delete-hub/$hubId'),
          headers: await _authHeaders(),
        )
        .timeout(_timeout),
  );

  // ── COUPONS ──────────────────────────────────────

  static Future<CouponListResponse> getAllCoupons() async {
    final raw = await _call(
      'GET_COUPONS',
      () async => http
          .get(Uri.parse('$_coupon/all-coupons'), headers: await _authHeaders())
          .timeout(_timeout),
    );
    return CouponListResponse.fromJson(raw);
  }

  static Future<Map<String, dynamic>> addCoupon({
    required String couponCode,
    required double discountPercentage,
    required int maxUsagePerUser,
    required DateTime expiryDate,
  }) => _call(
    'ADD_COUPON',
    () async => http
        .post(
          Uri.parse('$_coupon/add-coupon'),
          headers: await _authHeaders(),
          body: jsonEncode({
            'code': couponCode.trim().toUpperCase(),
            'discountPercentage': discountPercentage,
            'maxUsagePerUser': maxUsagePerUser,
            'expiryDate':
                '${expiryDate.year}-'
                '${expiryDate.month.toString().padLeft(2, '0')}-'
                '${expiryDate.day.toString().padLeft(2, '0')}',
          }),
        )
        .timeout(_timeout),
    expectedStatus: 201,
  );

  static Future<Map<String, dynamic>> deleteCoupon(int couponId) => _call(
    'DELETE_COUPON',
    () async => http
        .delete(
          Uri.parse('$_coupon/delete-coupon/$couponId'),
          headers: await _authHeaders(),
        )
        .timeout(_timeout),
  );

  static Future<Map<String, dynamic>> verifyCoupon({
    required String couponCode,
    required double amount,
  }) => _call(
    'VERIFY_COUPON',
    () async => http
        .post(
          Uri.parse('$_coupon/verify-coupon'),
          headers: await _authHeaders(),
          body: jsonEncode({
            'couponCode': couponCode.trim().toUpperCase(),
            'amount': amount,
          }),
        )
        .timeout(_timeout),
  );

  // ── DEVICES ──────────────────────────────────────

  static Future<DeviceListResponse> getAllDevices() async {
    if (kDebugMode) {
      debugPrint('══════════════════════════════════════════');
      debugPrint('[GET_DEVICES] 🚀 Fetching all devices...');
    }

    final raw = await _call(
      'GET_DEVICES',
      () async => http
          .get(Uri.parse('$_device/all-devices'), headers: await _authHeaders())
          .timeout(_timeout),
    );

    if (kDebugMode) {
      debugPrint('[GET_DEVICES] 📦 raw success : ${raw['success']}');
      debugPrint('[GET_DEVICES] 📦 totalDevices: ${raw['totalDevices']}');
      final dataList = raw['data'];
      if (dataList is List) {
        debugPrint('[GET_DEVICES] 📦 data count  : ${dataList.length}');
        for (int i = 0; i < dataList.length; i++) {
          final item = dataList[i];
          if (item is Map<String, dynamic>) {
            debugPrint(
              '[GET_DEVICES] 📦 device[$i] → id: ${item['id']} | deviceId: "${item['deviceId'] ?? item['device_id']}" | hubId: ${item['hubId'] ?? item['hub_id']} | Hubs: ${item['Hubs']} | Hub: ${item['Hub']}',
            );
          }
        }
      } else {
        debugPrint('[GET_DEVICES] ⚠️  data field is not a List: $dataList');
      }
      debugPrint('══════════════════════════════════════════');
    }

    final response = DeviceListResponse.fromJson(raw);

    if (kDebugMode) {
      debugPrint('[GET_DEVICES] ✅ parsed ${response.devices.length} devices');
      for (final d in response.devices) {
        debugPrint(
          '[GET_DEVICES] ✅ → id: ${d.id} | deviceId: "${d.deviceId}" | hubId: ${d.hubId} | hubName: "${d.hubName}"',
        );
      }
    }

    return response;
  }

  static Future<Map<String, dynamic>> addDevice({required String deviceId}) {
    if (kDebugMode) {
      debugPrint('[ADD_DEVICE] 🔍 deviceId to add: "$deviceId"');
    }
    return _call(
      'ADD_DEVICE',
      () async => http
          .post(
            Uri.parse('$_device/add-device'),
            headers: await _authHeaders(),
            body: jsonEncode({'deviceId': deviceId}),
          )
          .timeout(_timeout),
      expectedStatus: 201,
    );
  }

  /// ✅ Update device name and condition — persists to backend
  /// URL follows same pattern as delete: $_device/update-device/:id
  /// If your backend uses a different path (e.g. edit-device), update the Uri below.
  static Future<Map<String, dynamic>> updateDevice({
    required int deviceId,
    required String deviceName,
    required String condition,
  }) {
    if (kDebugMode) {
      debugPrint(
        '[UPDATE_DEVICE] 🔍 id: $deviceId | name: "$deviceName" | condition: "$condition"',
      );
    }
    return _call(
      'UPDATE_DEVICE',
      () async => http
          .put(
            Uri.parse('$_device/update-device/$deviceId'),
            headers: await _authHeaders(),
            body: jsonEncode({
              'deviceName': deviceName,
              if (condition.isNotEmpty) 'condition': condition,
            }),
          )
          .timeout(_timeout),
    );
  }

  static Future<Map<String, dynamic>> deleteDevice(int id) {
    if (kDebugMode) {
      debugPrint('[DELETE_DEVICE] 🔍 deleting device with numeric id: $id');
    }
    return _call(
      'DELETE_DEVICE',
      () async => http
          .delete(
            Uri.parse('$_device/delete-device/$id'),
            headers: await _authHeaders(),
          )
          .timeout(_timeout),
    );
  }

  // ── ASSIGN DEVICE ────────────────────────────────

  static Future<AssignDeviceResponse> assignDeviceToHub({
    required int hubId,
    required String deviceId,
  }) async {
    if (kDebugMode) {
      debugPrint('══════════════════════════════════════════');
      debugPrint('[ASSIGN_DEVICE] 🔍 Attempting assignment...');
      debugPrint('[ASSIGN_DEVICE] 🔍 hubId    : $hubId');
      debugPrint('[ASSIGN_DEVICE] 🔍 deviceId : "$deviceId"');
      debugPrint(
        '[ASSIGN_DEVICE] 🔍 payload  : ${jsonEncode({'hubId': hubId, 'deviceId': deviceId})}',
      );
    }

    final raw = await _call(
      'ASSIGN_DEVICE',
      () async => http
          .post(
            Uri.parse('$_base/assign-devices'),
            headers: await _authHeaders(),
            body: jsonEncode({'hubId': hubId, 'deviceId': deviceId}),
          )
          .timeout(_timeout),
    );

    if (kDebugMode) {
      debugPrint('[ASSIGN_DEVICE] 📦 raw response keys: ${raw.keys.toList()}');
      debugPrint('[ASSIGN_DEVICE] 📦 success   : ${raw['success']}');
      debugPrint('[ASSIGN_DEVICE] 📦 message   : ${raw['message']}');
      debugPrint('[ASSIGN_DEVICE] 📦 hubDevice : ${raw['hubDevice']}');
    }

    final res = AssignDeviceResponse.fromJson(raw);

    if (kDebugMode) {
      debugPrint(
        '[ASSIGN_DEVICE] ✅ parsed → success: ${res.success} | message: "${res.message}"',
      );
      debugPrint('[ASSIGN_DEVICE] ✅ hubDevice payload: ${res.hubDevice}');
      debugPrint('══════════════════════════════════════════');
    }

    return res;
  }

  // ── SERVICE REQUESTS ─────────────────────────────

  static Future<ServiceRequestListResponse> getAllServiceRequests() async {
    final raw = await _call(
      'SERVICE_REQUESTS',
      () async => http
          .get(
            Uri.parse('$_base/service-requests'),
            headers: await _authHeaders(),
          )
          .timeout(_timeout),
    );
    return ServiceRequestListResponse.fromJson(raw);
  }

  static Future<ServiceRequestListResponse> getServiceRequestsByHub(
    int hubId,
  ) async {
    final raw = await _call(
      'SERVICE_REQUESTS_HUB',
      () async => http
          .get(
            Uri.parse('$_base/service-requests/hub/$hubId'),
            headers: await _authHeaders(),
          )
          .timeout(_timeout),
    );
    return ServiceRequestListResponse.fromJson(raw);
  }

  static Future<Map<String, dynamic>> updateServiceRequestStatus({
    required int hubId,
    required int requestId,
    required String status,
  }) => _call(
    'UPDATE_SERVICE_STATUS',
    () async => http
        .put(
          Uri.parse('$_base/service-request/$hubId/update-status/$requestId'),
          headers: await _authHeaders(),
          body: jsonEncode({'status': status}),
        )
        .timeout(_timeout),
  );

  // ── WASH HISTORY ─────────────────────────────────

  static Future<WashHistoryListResponse> getAllWashHistory() async {
    final raw = await _call(
      'WASH_HISTORY',
      () async => http
          .get(Uri.parse('$_base/wash-history'), headers: await _authHeaders())
          .timeout(_timeout),
    );
    return WashHistoryListResponse.fromJson(raw);
  }

  static Future<WashHistoryListResponse> getWashHistoryByHub(int hubId) async {
    final raw = await _call(
      'WASH_HISTORY_HUB',
      () async => http
          .get(
            Uri.parse('$_base/wash-history/hub/$hubId'),
            headers: await _authHeaders(),
          )
          .timeout(_timeout),
    );
    return WashHistoryListResponse.fromJson(raw);
  }

  static Future<WashHistoryListResponse> getWashHistoryByUser(
    int userId,
  ) async {
    final raw = await _call(
      'WASH_HISTORY_USER',
      () async => http
          .get(
            Uri.parse('$_base/wash-history/user/$userId'),
            headers: await _authHeaders(),
          )
          .timeout(_timeout),
    );
    return WashHistoryListResponse.fromJson(raw);
  }

  // ── REVENUE ──────────────────────────────────────

  static Future<RevenueModel> getTotalRevenue() async {
    final raw = await _call(
      'REVENUE_TOTAL',
      () async => http
          .get(Uri.parse('$_base/revenue'), headers: await _authHeaders())
          .timeout(_timeout),
    );
    return RevenueModel.fromJson(raw);
  }

  static Future<RevenueModel> getTodayRevenue() async {
    final raw = await _call(
      'REVENUE_TODAY',
      () async => http
          .get(Uri.parse('$_base/revenue/today'), headers: await _authHeaders())
          .timeout(_timeout),
    );
    return RevenueModel.fromJson(raw);
  }

  static Future<RevenueModel> getHubRevenue(int hubId) async {
    final raw = await _call(
      'REVENUE_HUB',
      () async => http
          .get(
            Uri.parse('$_base/revenue/hub/$hubId'),
            headers: await _authHeaders(),
          )
          .timeout(_timeout),
    );
    return RevenueModel.fromJson(raw);
  }

  // ── USERS ─────────────────────────────────────────

  static Future<UserListResponse> getAllUsers() async {
    final raw = await _call(
      'USERS',
      () async => http
          .get(Uri.parse('$_base/users'), headers: await _authHeaders())
          .timeout(_timeout),
    );
    return UserListResponse.fromJson(raw);
  }

  static Future<GrowthStatsResponse> getNewUsersLast30Days() async {
    final raw = await _call(
      'USERS_NEW_30D',
      () async => http
          .get(
            Uri.parse('$_base/users/new/last-30-days'),
            headers: await _authHeaders(),
          )
          .timeout(_timeout),
    );
    return GrowthStatsResponse.fromJson(raw);
  }

  // ── HUB OWNERS ────────────────────────────────────

  static Future<GrowthStatsResponse> getNewHubOwnersLast30Days() async {
    final raw = await _call(
      'HUBOWNERS_NEW_30D',
      () async => http
          .get(
            Uri.parse('$_base/hubowners/new/last-30-days'),
            headers: await _authHeaders(),
          )
          .timeout(_timeout),
    );
    return GrowthStatsResponse.fromJson(raw);
  }
}
