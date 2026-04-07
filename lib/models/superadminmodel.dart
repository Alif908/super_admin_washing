import 'package:flutter/foundation.dart';

double _toDouble(dynamic v) {
  if (v == null) return 0.0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0.0;
}

double? _toDoubleOrNull(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}

int _toInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}

int? _toIntOrNull(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  final s = v.toString().trim();
  if (s.isEmpty || s == 'null') return null;
  return int.tryParse(s);
}

bool _toBool(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  return v.toString().toLowerCase() == 'true';
}

List<T> _parseList<T>(dynamic raw, T Function(Map<String, dynamic>) fromJson) {
  if (raw == null) return [];
  if (raw is! List) return [];
  return raw.whereType<Map<String, dynamic>>().map(fromJson).toList();
}

DateTime? _parseDate(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  try {
    return DateTime.parse(raw);
  } catch (_) {
    return null;
  }
}

// ── SuperAdmin ──────────────────────────────────
class SuperAdminModel {
  final int? id;
  final String name;
  final String email;
  final String? mobile;
  final String? token;
  final String? createdAt;

  const SuperAdminModel({
    this.id,
    required this.name,
    required this.email,
    this.mobile,
    this.token,
    this.createdAt,
  });

  factory SuperAdminModel.fromJson(Map<String, dynamic> json) =>
      SuperAdminModel(
        id: _toIntOrNull(json['id']),
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        mobile: json['mobile'],
        token: json['token'],
        createdAt: json['createdAt'],
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'mobile': mobile,
    'token': token,
    'createdAt': createdAt,
  };
}

// ── Auth Response ───────────────────────────────
class AuthResponse {
  final bool success;
  final String message;
  final String? token;
  final SuperAdminModel? admin;

  const AuthResponse({
    required this.success,
    required this.message,
    this.token,
    this.admin,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
    success: _toBool(json['success']),
    message: json['message'] ?? '',
    token: json['token'],
    admin: json['admin'] is Map<String, dynamic>
        ? SuperAdminModel.fromJson(json['admin'])
        : null,
  );

  bool get hasToken => success && token != null && token!.isNotEmpty;
}

// ── Package ─────────────────────────────────────
class PackageModel {
  final int id;
  final String packageName;
  final String? description;
  final double price;
  final String? statusCode;
  final String? createdAt;
  final String? updatedAt;

  const PackageModel({
    required this.id,
    required this.packageName,
    this.description,
    required this.price,
    this.statusCode,
    this.createdAt,
    this.updatedAt,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) => PackageModel(
    id: _toInt(json['id']),
    packageName: json['packageName'] ?? json['name'] ?? '',
    description: json['description'],
    price: _toDouble(json['price']),
    statusCode: json['statusCode']?.toString(),
    createdAt: json['createdAt'],
    updatedAt: json['updatedAt'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'packageName': packageName,
    'price': price,
    if (description != null) 'description': description,
    if (statusCode != null) 'statusCode': statusCode,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}

class PackageListResponse {
  final bool success;
  final List<PackageModel> packages;
  final String? message;

  const PackageListResponse({
    required this.success,
    required this.packages,
    this.message,
  });

  factory PackageListResponse.fromJson(Map<String, dynamic> json) =>
      PackageListResponse(
        success: _toBool(json['success']),
        message: json['message'],
        packages: _parseList(json['data'], PackageModel.fromJson),
      );
}

class PackageCreateResponse {
  final bool success;
  final String? message;
  final PackageModel? package;

  const PackageCreateResponse({
    required this.success,
    this.message,
    this.package,
  });

  factory PackageCreateResponse.fromJson(Map<String, dynamic> json) {
    PackageModel? pkg;
    if (json['data'] is Map<String, dynamic>) {
      pkg = PackageModel.fromJson(json['data']);
    } else if (json['package'] is Map<String, dynamic>) {
      pkg = PackageModel.fromJson(json['package']);
    }
    return PackageCreateResponse(
      success: _toBool(json['success']),
      message: json['message'],
      package: pkg,
    );
  }
}

// ── Hub ─────────────────────────────────────────
class HubModel {
  final int id;
  final String hubName;
  final String? hubCode;
  final double? latitude;
  final double? longitude;
  final String? hubOwnerName;
  final int? hubOwnerId;
  final String? email;
  final String? mobile;
  final String? address;
  final String? bankName;
  final String? accountNumber;
  final String? ifscCode;
  final String? operatorName;
  final String? operatorMobile;
  final int? deviceCount;
  final String? createdAt;
  final String? updatedAt;

  const HubModel({
    required this.id,
    required this.hubName,
    this.hubCode,
    this.latitude,
    this.longitude,
    this.hubOwnerName,
    this.hubOwnerId,
    this.email,
    this.mobile,
    this.address,
    this.bankName,
    this.accountNumber,
    this.ifscCode,
    this.operatorName,
    this.operatorMobile,
    this.deviceCount,
    this.createdAt,
    this.updatedAt,
  });

  factory HubModel.fromJson(Map<String, dynamic> json) => HubModel(
    id: _toInt(json['id']),
    hubName: json['hubName'] ?? json['name'] ?? '',
    hubCode: json['hubId']?.toString() ?? json['hubCode']?.toString(),
    latitude: _toDoubleOrNull(json['latitude']),
    longitude: _toDoubleOrNull(json['longitude']),
    hubOwnerName: json['hubOwnerName'],
    hubOwnerId: _toIntOrNull(json['ownerId'] ?? json['hubOwnerId']),
    email: json['email'],
    mobile: json['mobile'],
    address: json['address'],
    bankName: json['bankName'],
    accountNumber:
        json['acNumber']?.toString() ?? json['accountNumber']?.toString(),
    ifscCode: json['ifscCode'],
    operatorName: json['operatorName'],
    operatorMobile: json['operatorMobile'],
    deviceCount: _toIntOrNull(json['deviceCount']),
    createdAt: json['createdAt'],
    updatedAt: json['updatedAt'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'hubName': hubName,
    if (hubCode != null) 'hubId': hubCode,
    if (latitude != null) 'latitude': latitude,
    if (longitude != null) 'longitude': longitude,
    if (hubOwnerName != null) 'hubOwnerName': hubOwnerName,
    if (hubOwnerId != null) 'ownerId': hubOwnerId,
    if (email != null) 'email': email,
    if (mobile != null) 'mobile': mobile,
    if (address != null) 'address': address,
    if (bankName != null) 'bankName': bankName,
    if (accountNumber != null) 'acNumber': accountNumber,
    if (ifscCode != null) 'ifscCode': ifscCode,
    if (operatorName != null) 'operatorName': operatorName,
    if (operatorMobile != null) 'operatorMobile': operatorMobile,
    if (deviceCount != null) 'deviceCount': deviceCount,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}

class HubListResponse {
  final bool success;
  final List<HubModel> hubs;
  final String? message;

  const HubListResponse({
    required this.success,
    required this.hubs,
    this.message,
  });

  factory HubListResponse.fromJson(Map<String, dynamic> json) =>
      HubListResponse(
        success: _toBool(json['success']),
        message: json['message'],
        hubs: _parseList(json['data'], HubModel.fromJson),
      );
}

// ── Coupon ──────────────────────────────────────
class CouponModel {
  final int id;
  final String couponCode;
  final double discountPercentage;
  final int maxUsagePerUser;
  final String? expiryDate;
  final DateTime? expiryDateTime;
  final bool? isActive;
  final String? createdAt;
  final String? updatedAt;

  const CouponModel({
    required this.id,
    required this.couponCode,
    required this.discountPercentage,
    required this.maxUsagePerUser,
    this.expiryDate,
    this.expiryDateTime,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    final rawExpiry = json['expiryDate']?.toString();
    return CouponModel(
      id: _toInt(json['id']),
      couponCode: json['couponCode'] ?? json['code'] ?? '',
      discountPercentage: _toDouble(
        json['discountPercentage'] ?? json['discount'],
      ),
      maxUsagePerUser: _toInt(json['maxUsagePerUser'] ?? json['maxUsage']),
      expiryDate: rawExpiry,
      expiryDateTime: _parseDate(rawExpiry),
      isActive: json['isActive'] != null ? _toBool(json['isActive']) : null,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  bool get isExpired {
    if (expiryDateTime != null) {
      return expiryDateTime!.isBefore(DateTime.now());
    }
    if (isActive != null) return !isActive!;
    return false;
  }

  String get expiryDateDisplay {
    if (expiryDateTime != null) {
      return '${expiryDateTime!.year}-'
          '${expiryDateTime!.month.toString().padLeft(2, '0')}-'
          '${expiryDateTime!.day.toString().padLeft(2, '0')}';
    }
    return expiryDate ?? '—';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'couponCode': couponCode,
    'discountPercentage': discountPercentage,
    'maxUsagePerUser': maxUsagePerUser,
    if (expiryDate != null) 'expiryDate': expiryDate,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}

class CouponListResponse {
  final bool success;
  final List<CouponModel> coupons;
  final String? message;

  const CouponListResponse({
    required this.success,
    required this.coupons,
    this.message,
  });

  factory CouponListResponse.fromJson(Map<String, dynamic> json) =>
      CouponListResponse(
        success: _toBool(json['success']),
        message: json['message'],
        coupons: _parseList(json['data'], CouponModel.fromJson),
      );
}

// ── IoT Status Code Reference ───────────────────
//   0         → Idle       (ready, button enabled)
//   1001      → Washing    (started)
//   1002      → Washing    (in progress)
//   1003      → Washing    (finishing)
//   2000      → Completed  (wash done, back to idle soon)
//   null/other→ Unknown    (button disabled)

// ── Device ──────────────────────────────────────
class DeviceModel {
  final int id;
  final String deviceId;
  final String? deviceName;
  final String? condition;
  final int? hubId;
  final String? hubName;
  final bool? isActive;
  final int? iotStatusCode;
  final String? createdAt;
  final String? updatedAt;

  const DeviceModel({
    required this.id,
    required this.deviceId,
    this.deviceName,
    this.condition,
    this.hubId,
    this.hubName,
    this.isActive,
    this.iotStatusCode,
    this.createdAt,
    this.updatedAt,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    if (kDebugMode) {
      debugPrint('──────────────────────────────────────────');
      debugPrint('[DeviceModel] 🔍 raw keys    : ${json.keys.toList()}');
      debugPrint('[DeviceModel] 🔍 id          : ${json['id']}');
      debugPrint(
        '[DeviceModel] 🔍 deviceId    : ${json['deviceId'] ?? json['device_id']}',
      );
      debugPrint(
        '[DeviceModel] 🔍 deviceName  : ${json['deviceName'] ?? json['name']}',
      );
      debugPrint(
        '[DeviceModel] 🔍 hubId (top) : ${json['hubId'] ?? json['hub_id']}',
      );
      debugPrint('[DeviceModel] 🔍 Hubs[]      : ${json['Hubs']}');
      debugPrint('[DeviceModel] 🔍 Hub{}       : ${json['Hub']}');
      debugPrint('[DeviceModel] 🔍 HubDevices[]: ${json['HubDevices']}');
    }

    // ── Hub ID resolution ─────────────────────────────────────────
    int? resolvedHubId = _toIntOrNull(json['hubId'] ?? json['hub_id']);
    if (kDebugMode) {
      debugPrint(
        '[DeviceModel] 📍 step-1 direct hubId/hub_id → $resolvedHubId',
      );
    }

    if (resolvedHubId == null) {
      final hubsList = json['Hubs'];
      if (hubsList is List && hubsList.isNotEmpty) {
        final firstHub = hubsList.first;
        if (firstHub is Map<String, dynamic>) {
          resolvedHubId = _toIntOrNull(firstHub['id']);
          if (kDebugMode) {
            debugPrint(
              '[DeviceModel] 📍 step-2 from Hubs[0].id → $resolvedHubId',
            );
          }
        }
      }
    }

    if (resolvedHubId == null) {
      final hubObj = json['Hub'];
      if (hubObj is Map<String, dynamic>) {
        resolvedHubId = _toIntOrNull(hubObj['id']);
        if (kDebugMode) {
          debugPrint('[DeviceModel] 📍 step-3 from Hub{}.id → $resolvedHubId');
        }
      }
    }

    if (resolvedHubId == null) {
      final hubDevices = json['HubDevices'];
      if (hubDevices is List && hubDevices.isNotEmpty) {
        final first = hubDevices.first;
        if (first is Map<String, dynamic>) {
          resolvedHubId = _toIntOrNull(first['hubId'] ?? first['hub_id']);
          if (kDebugMode) {
            debugPrint(
              '[DeviceModel] 📍 step-4 from HubDevices[0].hubId → $resolvedHubId',
            );
          }
        }
      }
    }

    if (kDebugMode) {
      debugPrint(
        resolvedHubId != null
            ? '[DeviceModel] ✅ FINAL resolvedHubId : $resolvedHubId'
            : '[DeviceModel] ⚠️  FINAL resolvedHubId : NULL — no hub association found',
      );
    }

    // ── Hub Name resolution ───────────────────────────────────────
    String? resolvedHubName = json['hubName'];
    if (resolvedHubName == null) {
      final hubsList = json['Hubs'];
      if (hubsList is List && hubsList.isNotEmpty) {
        final firstHub = hubsList.first;
        if (firstHub is Map<String, dynamic>) {
          resolvedHubName = firstHub['hubName']?.toString();
        }
      }
    }
    if (resolvedHubName == null) {
      final hubObj = json['Hub'];
      if (hubObj is Map<String, dynamic>) {
        resolvedHubName = hubObj['hubName']?.toString();
      }
    }
    if (kDebugMode) {
      debugPrint('[DeviceModel] 🏷️  resolvedHubName : $resolvedHubName');
    }

    // ── IoT Status resolution ─────────────────────────────────────
    int? resolvedIotStatus = _toIntOrNull(json['iotStatusCode']);

    if (resolvedIotStatus == null) {
      final hubsList = json['Hubs'];
      if (hubsList is List && hubsList.isNotEmpty) {
        final firstHub = hubsList.first;
        if (firstHub is Map<String, dynamic>) {
          final hubDevice = firstHub['HubDevice'];
          if (hubDevice is Map<String, dynamic>) {
            resolvedIotStatus = _toIntOrNull(hubDevice['iotStatusCode']);
          }
        }
      }
    }

    if (kDebugMode) {
      debugPrint('[DeviceModel] 📡 iotStatusCode : $resolvedIotStatus');
    }

    final device = DeviceModel(
      id: _toInt(json['id']),
      deviceId: json['deviceId'] ?? json['device_id'] ?? '',
      deviceName: json['deviceName'] ?? json['name'],
      condition: json['condition'],
      hubId: resolvedHubId,
      hubName: resolvedHubName,
      isActive: json['isActive'] != null ? _toBool(json['isActive']) : null,
      iotStatusCode: resolvedIotStatus,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );

    if (kDebugMode) {
      debugPrint(
        '[DeviceModel] ✅ built → id: ${device.id} | deviceId: "${device.deviceId}" '
        '| hubId: ${device.hubId} | iotStatusCode: ${device.iotStatusCode} '
        '| statusLabel: "${device.statusLabel}"',
      );
      debugPrint('──────────────────────────────────────────');
    }

    return device;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'deviceId': deviceId,
    if (deviceName != null) 'deviceName': deviceName,
    if (condition != null) 'condition': condition,
    if (hubId != null) 'hubId': hubId,
    if (hubName != null) 'hubName': hubName,
    if (isActive != null) 'isActive': isActive,
    if (iotStatusCode != null) 'iotStatusCode': iotStatusCode,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  // ── Status getters ────────────────────────────

  /// 0 → Idle (ready for use)
  bool get isIdle => iotStatusCode == 0;

  /// 1001, 1002, 1003 → Washing (in progress)
  bool get isWashing =>
      iotStatusCode == 1001 || iotStatusCode == 1002 || iotStatusCode == 1003;

  /// 2000 → Completed (wash finished)
  bool get isCompleted => iotStatusCode == 2000;

  /// Green indicator: only when Idle
  bool get isGoodCondition => isIdle;

  /// Button enabled only when Idle
  bool get isButtonEnabled => isIdle;

  /// Human-readable label for UI display
  String get statusLabel {
    if (isIdle) return 'Idle';
    if (isWashing) return 'Washing';
    if (isCompleted) return 'Completed';
    return 'Unknown';
  }

  bool matchesHub(int targetHubId) =>
      hubId != null && hubId.toString() == targetHubId.toString();

  DeviceModel withHub(int newHubId) => DeviceModel(
    id: id,
    deviceId: deviceId,
    deviceName: deviceName,
    condition: condition,
    hubId: newHubId,
    hubName: hubName,
    isActive: isActive,
    iotStatusCode: iotStatusCode,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  DeviceModel copyWith({
    String? deviceName,
    String? condition,
    int? hubId,
    String? hubName,
    int? iotStatusCode,
  }) => DeviceModel(
    id: id,
    deviceId: deviceId,
    deviceName: deviceName ?? this.deviceName,
    condition: condition ?? this.condition,
    hubId: hubId ?? this.hubId,
    hubName: hubName ?? this.hubName,
    isActive: isActive,
    iotStatusCode: iotStatusCode ?? this.iotStatusCode,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

class DeviceListResponse {
  final bool success;
  final int totalDevices;
  final List<DeviceModel> devices;
  final String? message;

  const DeviceListResponse({
    required this.success,
    required this.totalDevices,
    required this.devices,
    this.message,
  });

  factory DeviceListResponse.fromJson(Map<String, dynamic> json) =>
      DeviceListResponse(
        success: _toBool(json['success']),
        message: json['message'],
        totalDevices: _toInt(json['totalDevices']),
        devices: _parseList(json['data'], DeviceModel.fromJson),
      );
}

// ── Assign Device Response ──────────────────────
class AssignDeviceResponse {
  final bool success;
  final String? message;
  final Map<String, dynamic>? hubDevice;

  const AssignDeviceResponse({
    required this.success,
    this.message,
    this.hubDevice,
  });

  factory AssignDeviceResponse.fromJson(Map<String, dynamic> json) =>
      AssignDeviceResponse(
        success: _toBool(json['success']),
        message: json['message'],
        hubDevice: json['hubDevice'] is Map<String, dynamic>
            ? json['hubDevice']
            : null,
      );
}

// ── Service Request ─────────────────────────────
class ServiceRequestModel {
  final int id;
  final int hubId;
  final int? ownerId;
  final String status;
  final String? description;
  final String? issueCategory;
  final String? createdAt;
  final String? updatedAt;
  final HubSummary? hub;
  final HubOwnerSummary? hubOwner;

  const ServiceRequestModel({
    required this.id,
    required this.hubId,
    this.ownerId,
    required this.status,
    this.description,
    this.issueCategory,
    this.createdAt,
    this.updatedAt,
    this.hub,
    this.hubOwner,
  });

  factory ServiceRequestModel.fromJson(Map<String, dynamic> json) =>
      ServiceRequestModel(
        id: _toInt(json['id']),
        hubId: _toInt(json['hubId']),
        ownerId: _toIntOrNull(json['ownerId']),
        status: json['status'] ?? 'pending',
        description: json['description'],
        issueCategory: json['issueCategory'] ?? json['issueType'],
        createdAt: json['createdAt'],
        updatedAt: json['updatedAt'],
        hub: json['Hub'] is Map<String, dynamic>
            ? HubSummary.fromJson(json['Hub'])
            : null,
        hubOwner: json['HubOwner'] is Map<String, dynamic>
            ? HubOwnerSummary.fromJson(json['HubOwner'])
            : null,
      );

  ServiceRequestModel withStatus(String newStatus) => ServiceRequestModel(
    id: id,
    hubId: hubId,
    ownerId: ownerId,
    status: newStatus,
    description: description,
    issueCategory: issueCategory,
    createdAt: createdAt,
    updatedAt: updatedAt,
    hub: hub,
    hubOwner: hubOwner,
  );

  bool get isPending => status == 'pending';
  bool get isInProgress => status == 'in_progress' || status == 'inProgress';
  bool get isCompleted => status == 'completed';
}

// ── Service Request Stats ───────────────────────
class ServiceRequestStats {
  final int total;
  final int pending;
  final int inProgress;
  final int completed;

  const ServiceRequestStats({
    required this.total,
    required this.pending,
    required this.inProgress,
    required this.completed,
  });

  factory ServiceRequestStats.fromJson(Map<String, dynamic> json) =>
      ServiceRequestStats(
        total: _toInt(json['total']),
        pending: _toInt(json['pending']),
        inProgress: _toInt(json['inProgress']),
        completed: _toInt(json['completed']),
      );

  int get openCount => pending + inProgress;
}

class ServiceRequestListResponse {
  final bool success;
  final ServiceRequestStats stats;
  final List<ServiceRequestModel> requests;
  final String? message;

  const ServiceRequestListResponse({
    required this.success,
    required this.stats,
    required this.requests,
    this.message,
  });

  factory ServiceRequestListResponse.fromJson(Map<String, dynamic> json) =>
      ServiceRequestListResponse(
        success: _toBool(json['success']),
        message: json['message'],
        stats: json['stats'] is Map<String, dynamic>
            ? ServiceRequestStats.fromJson(json['stats'])
            : const ServiceRequestStats(
                total: 0,
                pending: 0,
                inProgress: 0,
                completed: 0,
              ),
        requests: _parseList(json['data'], ServiceRequestModel.fromJson),
      );
}

// ── Wash History ────────────────────────────────
class WashHistoryModel {
  final int id;
  final int? orderId;
  final int? userId;
  final int? hubId;
  final int? deviceId;
  final int? packageId;
  final String? packageName;
  final double? amount;
  final double? finalAmount;
  final String? couponCode;
  final int? couponDiscountPercentage;
  final String? razorpayOrderId;
  final String? razorpayPaymentId;
  final String? washStartTime;
  final String? washEndTime;
  final String? createdAt;
  final UserSummary? user;
  final HubSummary? hub;
  final DeviceSummary? device;
  final PackageSummary? hubPackage;

  const WashHistoryModel({
    required this.id,
    this.orderId,
    this.userId,
    this.hubId,
    this.deviceId,
    this.packageId,
    this.packageName,
    this.amount,
    this.finalAmount,
    this.couponCode,
    this.couponDiscountPercentage,
    this.razorpayOrderId,
    this.razorpayPaymentId,
    this.washStartTime,
    this.washEndTime,
    this.createdAt,
    this.user,
    this.hub,
    this.device,
    this.hubPackage,
  });

  factory WashHistoryModel.fromJson(Map<String, dynamic> json) =>
      WashHistoryModel(
        id: _toInt(json['id']),
        orderId: _toIntOrNull(json['orderId']),
        userId: _toIntOrNull(json['userId']),
        hubId: _toIntOrNull(json['hubId']),
        deviceId: _toIntOrNull(json['deviceId']),
        packageId: _toIntOrNull(json['packageId']),
        packageName: json['packageName'],
        amount: _toDoubleOrNull(json['amount']),
        finalAmount: _toDoubleOrNull(json['finalAmount']),
        couponCode: json['couponCode'],
        couponDiscountPercentage: _toIntOrNull(
          json['couponDiscountPercentage'],
        ),
        razorpayOrderId: json['razorpayOrderId'],
        razorpayPaymentId: json['razorpayPaymentId'],
        washStartTime: json['washStartTime'],
        washEndTime: json['washEndTime'],
        createdAt: json['createdAt'],
        user: json['User'] is Map<String, dynamic>
            ? UserSummary.fromJson(json['User'])
            : null,
        hub: json['Hub'] is Map<String, dynamic>
            ? HubSummary.fromJson(json['Hub'])
            : null,
        device: json['Device'] is Map<String, dynamic>
            ? DeviceSummary.fromJson(json['Device'])
            : null,
        hubPackage: json['HubPackage'] is Map<String, dynamic>
            ? PackageSummary.fromJson(json['HubPackage'])
            : null,
      );

  bool get hasCoupon => couponCode != null && couponCode!.isNotEmpty;
  double get discountAmount => (amount ?? 0) - (finalAmount ?? amount ?? 0);
  double get displayAmount => finalAmount ?? amount ?? 0;
  String get displayOrderId => orderId != null ? '$orderId' : '$id';
}

class WashHistoryListResponse {
  final bool success;
  final int total;
  final List<WashHistoryModel> history;
  final String? message;

  const WashHistoryListResponse({
    required this.success,
    required this.total,
    required this.history,
    this.message,
  });

  factory WashHistoryListResponse.fromJson(Map<String, dynamic> json) =>
      WashHistoryListResponse(
        success: _toBool(json['success']),
        message: json['message'],
        total: _toInt(json['total']),
        history: _parseList(json['data'], WashHistoryModel.fromJson),
      );
}

// ── Revenue ─────────────────────────────────────
class RevenueModel {
  final bool success;
  final int totalWashes;
  final double totalRevenue;
  final String? date;
  final int? hubId;

  const RevenueModel({
    required this.success,
    required this.totalWashes,
    required this.totalRevenue,
    this.date,
    this.hubId,
  });

  factory RevenueModel.fromJson(Map<String, dynamic> json) => RevenueModel(
    success: _toBool(json['success']),
    totalWashes: _toInt(json['totalWashes']),
    totalRevenue: _toDouble(json['totalRevenue']),
    date: json['date'],
    hubId: _toIntOrNull(json['hubId']),
  );

  double get avgPerWash => totalWashes > 0 ? totalRevenue / totalWashes : 0.0;
}

// ── User ────────────────────────────────────────
class UserModel {
  final int id;
  final String name;
  final String mobile;
  final String? createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.mobile,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: _toInt(json['id']),
    name: json['name'] ?? '',
    mobile: json['mobile'] ?? '',
    createdAt: json['createdAt'],
  );
}

class UserListResponse {
  final bool success;
  final int totalUsers;
  final List<UserModel> users;
  final String? message;

  const UserListResponse({
    required this.success,
    required this.totalUsers,
    required this.users,
    this.message,
  });

  factory UserListResponse.fromJson(Map<String, dynamic> json) =>
      UserListResponse(
        success: _toBool(json['success']),
        message: json['message'],
        totalUsers: _toInt(json['totalUsers']),
        users: _parseList(json['users'], UserModel.fromJson),
      );
}

// ── Daily Stat / Date Range ─────────────────────
class DailyStat {
  final String date;
  final int count;

  const DailyStat({required this.date, required this.count});

  factory DailyStat.fromJson(Map<String, dynamic> json) => DailyStat(
    date: json['date']?.toString() ?? '',
    count: _toInt(json['count']),
  );
}

class DateRange {
  final String from;
  final String to;

  const DateRange({required this.from, required this.to});

  factory DateRange.fromJson(Map<String, dynamic> json) => DateRange(
    from: json['from']?.toString() ?? '',
    to: json['to']?.toString() ?? '',
  );
}

// ── Growth Stats ────────────────────────────────
class GrowthStatsResponse {
  final bool success;
  final DateRange range;
  final int total;
  final List<DailyStat> dailyStats;
  final String? message;

  const GrowthStatsResponse({
    required this.success,
    required this.range,
    required this.total,
    required this.dailyStats,
    this.message,
  });

  factory GrowthStatsResponse.fromJson(Map<String, dynamic> json) =>
      GrowthStatsResponse(
        success: _toBool(json['success']),
        message: json['message'],
        range: json['range'] is Map<String, dynamic>
            ? DateRange.fromJson(json['range'])
            : const DateRange(from: '', to: ''),
        total: _toInt(json['totalNewUsers'] ?? json['totalNewHubOwners'] ?? 0),
        dailyStats: _parseList(json['dailyStats'], DailyStat.fromJson),
      );
}

// ══════════════════════════════════════════════════════
//  SUMMARY / NESTED OBJECTS
// ══════════════════════════════════════════════════════
class HubSummary {
  final String? hubName;
  final String? address;
  final String? mobile;
  final String? hubOwnerName;

  const HubSummary({
    this.hubName,
    this.address,
    this.mobile,
    this.hubOwnerName,
  });

  factory HubSummary.fromJson(Map<String, dynamic> json) => HubSummary(
    hubName: json['hubName'],
    address: json['address'],
    mobile: json['mobile'],
    hubOwnerName: json['hubOwnerName'],
  );
}

class HubOwnerSummary {
  final String? email;
  final String? mobile;

  const HubOwnerSummary({this.email, this.mobile});

  factory HubOwnerSummary.fromJson(Map<String, dynamic> json) =>
      HubOwnerSummary(email: json['email'], mobile: json['mobile']);
}

class UserSummary {
  final int? id;
  final String? name;
  final String? mobile;

  const UserSummary({this.id, this.name, this.mobile});

  factory UserSummary.fromJson(Map<String, dynamic> json) => UserSummary(
    id: _toIntOrNull(json['id']),
    name: json['name'],
    mobile: json['mobile'],
  );
}

class DeviceSummary {
  final String? deviceName;
  final String? deviceId;

  const DeviceSummary({this.deviceName, this.deviceId});

  factory DeviceSummary.fromJson(Map<String, dynamic> json) =>
      DeviceSummary(deviceName: json['deviceName'], deviceId: json['deviceId']);
}

class PackageSummary {
  final String? packageName;
  final double? price;

  const PackageSummary({this.packageName, this.price});

  factory PackageSummary.fromJson(Map<String, dynamic> json) => PackageSummary(
    packageName: json['packageName'],
    price: _toDoubleOrNull(json['price']),
  );
}
