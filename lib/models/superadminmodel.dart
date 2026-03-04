// ═══════════════════════════════════════════════
//  SUPER ADMIN MODELS
//  lib/models/superadminmodel.dart
// ═══════════════════════════════════════════════

// ── Safe parse helpers ──────────────────────────
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
  return int.tryParse(v.toString());
}

// ── 1. SuperAdmin ───────────────────────────────
class SuperAdminModel {
  final int? id;
  final String name;
  final String email;
  final String? mobile;
  final String? token;

  SuperAdminModel({
    this.id,
    required this.name,
    required this.email,
    this.mobile,
    this.token,
  });

  factory SuperAdminModel.fromJson(Map<String, dynamic> json) =>
      SuperAdminModel(
        id: _toIntOrNull(json['id']),
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        mobile: json['mobile'],
        token: json['token'],
      );
}

// ── 2. Signup Request ───────────────────────────
class SignupRequestModel {
  final String name, email, password, mobile;
  SignupRequestModel({
    required this.name,
    required this.email,
    required this.password,
    required this.mobile,
  });
  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'password': password,
    'mobile': mobile,
  };
}

// ── 3. Login Request ────────────────────────────
class LoginRequestModel {
  final String email, password;
  LoginRequestModel({required this.email, required this.password});
  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

// ── 4. Auth Response ────────────────────────────
class AuthResponseModel {
  final bool success;
  final String message;
  final String? token;
  final SuperAdminModel? admin;

  AuthResponseModel({
    required this.success,
    required this.message,
    this.token,
    this.admin,
  });

  factory AuthResponseModel.fromJson(
    Map<String, dynamic> json, {
    required bool success,
  }) => AuthResponseModel(
    success: success,
    message: json['message'] ?? '',
    token: json['token'],
    admin: json['admin'] != null
        ? SuperAdminModel.fromJson(json['admin'])
        : null,
  );
}

// ── 5. Service Request ──────────────────────────
class ServiceRequestModel {
  final int id, hubId;
  final String status;
  final String? description, createdAt;
  final HubSummary? hub;
  final HubOwnerSummary? hubOwner;

  ServiceRequestModel({
    required this.id,
    required this.hubId,
    required this.status,
    this.description,
    this.createdAt,
    this.hub,
    this.hubOwner,
  });

  factory ServiceRequestModel.fromJson(Map<String, dynamic> json) =>
      ServiceRequestModel(
        id: _toInt(json['id']),
        hubId: _toInt(json['hubId']),
        status: json['status'] ?? 'pending',
        description: json['description'],
        createdAt: json['createdAt'],
        hub: json['Hub'] != null ? HubSummary.fromJson(json['Hub']) : null,
        hubOwner: json['HubOwner'] != null
            ? HubOwnerSummary.fromJson(json['HubOwner'])
            : null,
      );
}

// ── 6. Service Request Stats ────────────────────
class ServiceRequestStats {
  final int total, pending, inProgress, completed;
  ServiceRequestStats({
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
}

// ── 7. Wash History ─────────────────────────────
class WashHistoryModel {
  final int id;
  final int? userId, hubId;
  final double? finalAmount;
  final String? washEndTime, createdAt;
  final UserSummary? user;
  final HubSummary? hub;
  final DeviceSummary? device;
  final PackageSummary? hubPackage;

  WashHistoryModel({
    required this.id,
    this.userId,
    this.hubId,
    this.finalAmount,
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
        userId: _toIntOrNull(json['userId']),
        hubId: _toIntOrNull(json['hubId']),
        finalAmount: _toDoubleOrNull(json['finalAmount']),
        washEndTime: json['washEndTime'],
        createdAt: json['createdAt'],
        user: json['User'] != null ? UserSummary.fromJson(json['User']) : null,
        hub: json['Hub'] != null ? HubSummary.fromJson(json['Hub']) : null,
        device: json['Device'] != null
            ? DeviceSummary.fromJson(json['Device'])
            : null,
        hubPackage: json['HubPackage'] != null
            ? PackageSummary.fromJson(json['HubPackage'])
            : null,
      );
}

// ── 8. Revenue ──────────────────────────────────
class RevenueModel {
  final bool success;
  final int totalWashes;
  final double totalRevenue;
  final String? date;
  final int? hubId;

  RevenueModel({
    required this.success,
    required this.totalWashes,
    required this.totalRevenue,
    this.date,
    this.hubId,
  });

  factory RevenueModel.fromJson(Map<String, dynamic> json) => RevenueModel(
    success: json['success'] ?? false,
    totalWashes: _toInt(json['totalWashes']),
    totalRevenue: _toDouble(json['totalRevenue']),
    date: json['date'],
    hubId: _toIntOrNull(json['hubId']),
  );
}

// ── 9. User ─────────────────────────────────────
class UserModel {
  final int id;
  final String name, mobile;
  final String? createdAt;

  UserModel({
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

// ── 10. New Users Stats (last 30 days) ──────────
class NewUsersStatsModel {
  final bool success;
  final DateRange range;
  final int totalNewUsers;
  final List<DailyStat> dailyStats;

  NewUsersStatsModel({
    required this.success,
    required this.range,
    required this.totalNewUsers,
    required this.dailyStats,
  });

  factory NewUsersStatsModel.fromJson(Map<String, dynamic> json) =>
      NewUsersStatsModel(
        success: json['success'] ?? false,
        range: DateRange.fromJson(json['range'] ?? {}),
        totalNewUsers: _toInt(json['totalNewUsers']),
        dailyStats: (json['dailyStats'] as List? ?? [])
            .map((e) => DailyStat.fromJson(e))
            .toList(),
      );
}

// ── 11. New HubOwners Stats (last 30 days) ──────
class NewHubOwnersStatsModel {
  final bool success;
  final DateRange range;
  final int totalNewHubOwners;
  final List<DailyStat> dailyStats;

  NewHubOwnersStatsModel({
    required this.success,
    required this.range,
    required this.totalNewHubOwners,
    required this.dailyStats,
  });

  factory NewHubOwnersStatsModel.fromJson(Map<String, dynamic> json) =>
      NewHubOwnersStatsModel(
        success: json['success'] ?? false,
        range: DateRange.fromJson(json['range'] ?? {}),
        totalNewHubOwners: _toInt(json['totalNewHubOwners']),
        dailyStats: (json['dailyStats'] as List? ?? [])
            .map((e) => DailyStat.fromJson(e))
            .toList(),
      );
}

// ── 12. Package ─────────────────────────────────
class PackageModel {
  final int id;
  final String packageName;
  final String? description;
  final double price;
  final String? statusCode;
  final String? createdAt;
  final String? updatedAt;

  PackageModel({
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
    'description': description,
    'price': price,
    'statusCode': statusCode,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}

class AddPackageRequest {
  final String packageName;
  final String? description;
  final double price;
  final String? statusCode;

  AddPackageRequest({
    required this.packageName,
    this.description,
    required this.price,
    this.statusCode,
  });

  Map<String, dynamic> toJson() => {
    'packageName': packageName,
    'price': price,
    if (description != null && description!.isNotEmpty)
      'description': description,
    if (statusCode != null && statusCode!.isNotEmpty) 'statusCode': statusCode,
  };
}

class PackageResponseModel {
  final bool success;
  final String message;
  final PackageModel? package;
  final List<PackageModel> packages;

  PackageResponseModel({
    required this.success,
    required this.message,
    this.package,
    this.packages = const [],
  });

  factory PackageResponseModel.fromJson(Map<String, dynamic> json) {
    PackageModel? single;
    if (json['package'] != null && json['package'] is Map) {
      single = PackageModel.fromJson(json['package']);
    } else if (json['data'] != null && json['data'] is Map) {
      single = PackageModel.fromJson(json['data']);
    }

    List<PackageModel> list = [];
    if (json['packages'] != null && json['packages'] is List) {
      list = (json['packages'] as List)
          .map((e) => PackageModel.fromJson(e))
          .toList();
    } else if (json['data'] != null && json['data'] is List) {
      list = (json['data'] as List)
          .map((e) => PackageModel.fromJson(e))
          .toList();
    }

    return PackageResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      package: single,
      packages: list,
    );
  }
}

// ── 13. Hub ─────────────────────────────────────
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
  final String? createdAt;
  final String? updatedAt;

  HubModel({
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
    this.createdAt,
    this.updatedAt,
  });

  factory HubModel.fromJson(Map<String, dynamic> json) => HubModel(
    id: _toInt(json['id']),
    hubName: json['hubName'] ?? json['name'] ?? '',
    hubCode: json['hubCode']?.toString(),
    latitude: _toDoubleOrNull(json['latitude']),
    longitude: _toDoubleOrNull(json['longitude']),
    hubOwnerName: json['hubOwnerName'],
    hubOwnerId: _toIntOrNull(json['hubOwnerId']),
    email: json['email'],
    mobile: json['mobile'],
    address: json['address'],
    bankName: json['bankName'],
    accountNumber: json['accountNumber']?.toString(),
    ifscCode: json['ifscCode'],
    operatorName: json['operatorName'],
    operatorMobile: json['operatorMobile'],
    createdAt: json['createdAt'],
    updatedAt: json['updatedAt'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'hubName': hubName,
    'hubCode': hubCode,
    'latitude': latitude,
    'longitude': longitude,
    'hubOwnerName': hubOwnerName,
    'hubOwnerId': hubOwnerId,
    'email': email,
    'mobile': mobile,
    'address': address,
    'bankName': bankName,
    'accountNumber': accountNumber,
    'ifscCode': ifscCode,
    'operatorName': operatorName,
    'operatorMobile': operatorMobile,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}

// ── 14. Coupon ──────────────────────────────────
class CouponModel {
  final int id;
  final String couponCode;
  final double discountPercentage;
  final int maxUsagePerUser;
  final String? expiryDate;
  final String? createdAt;
  final String? updatedAt;

  CouponModel({
    required this.id,
    required this.couponCode,
    required this.discountPercentage,
    required this.maxUsagePerUser,
    this.expiryDate,
    this.createdAt,
    this.updatedAt,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) => CouponModel(
    id: _toInt(json['id']),
    couponCode: json['couponCode'] ?? json['code'] ?? '',
    discountPercentage: _toDouble(
      json['discountPercentage'] ?? json['discount'],
    ),
    maxUsagePerUser: _toInt(json['maxUsagePerUser'] ?? json['maxUsage']),
    expiryDate: json['expiryDate']?.toString(),
    createdAt: json['createdAt'],
    updatedAt: json['updatedAt'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'couponCode': couponCode,
    'discountPercentage': discountPercentage,
    'maxUsagePerUser': maxUsagePerUser,
    'expiryDate': expiryDate,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}

// ── 15. Device ──────────────────────────────────

/// Full device object returned from GET /devices or POST /devices
class DeviceModel {
  final int id;
  final String deviceId; // unique string ID e.g. "DEV001"
  final String? deviceName;
  final String? condition; // "Good" | "Fair" | "Poor" etc.
  final int? hubId;
  final String? createdAt;
  final String? updatedAt;

  DeviceModel({
    required this.id,
    required this.deviceId,
    this.deviceName,
    this.condition,
    this.hubId,
    this.createdAt,
    this.updatedAt,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) => DeviceModel(
    id: _toInt(json['id']),
    deviceId: json['deviceId'] ?? json['device_id'] ?? '',
    deviceName: json['deviceName'] ?? json['name'],
    condition: json['condition'],
    hubId: _toIntOrNull(json['hubId']),
    createdAt: json['createdAt'],
    updatedAt: json['updatedAt'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'deviceId': deviceId,
    'deviceName': deviceName,
    'condition': condition,
    'hubId': hubId,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}

// ── Helper classes ───────────────────────────────
class DateRange {
  final String from, to;
  DateRange({required this.from, required this.to});
  factory DateRange.fromJson(Map<String, dynamic> json) =>
      DateRange(from: json['from'] ?? '', to: json['to'] ?? '');
}

class DailyStat {
  final String date;
  final int count;
  DailyStat({required this.date, required this.count});
  factory DailyStat.fromJson(Map<String, dynamic> json) =>
      DailyStat(date: json['date'] ?? '', count: _toInt(json['count']));
}

class HubSummary {
  final String? hubName, address, mobile, hubOwnerName;
  HubSummary({this.hubName, this.address, this.mobile, this.hubOwnerName});
  factory HubSummary.fromJson(Map<String, dynamic> json) => HubSummary(
    hubName: json['hubName'],
    address: json['address'],
    mobile: json['mobile'],
    hubOwnerName: json['hubOwnerName'],
  );
}

class HubOwnerSummary {
  final String? email, mobile;
  HubOwnerSummary({this.email, this.mobile});
  factory HubOwnerSummary.fromJson(Map<String, dynamic> json) =>
      HubOwnerSummary(email: json['email'], mobile: json['mobile']);
}

class UserSummary {
  final int? id;
  final String? name, mobile;
  UserSummary({this.id, this.name, this.mobile});
  factory UserSummary.fromJson(Map<String, dynamic> json) => UserSummary(
    id: _toIntOrNull(json['id']),
    name: json['name'],
    mobile: json['mobile'],
  );
}

class DeviceSummary {
  final String? deviceName, deviceId;
  DeviceSummary({this.deviceName, this.deviceId});
  factory DeviceSummary.fromJson(Map<String, dynamic> json) =>
      DeviceSummary(deviceName: json['deviceName'], deviceId: json['deviceId']);
}

class PackageSummary {
  final String? packageName;
  final double? price;
  PackageSummary({this.packageName, this.price});
  factory PackageSummary.fromJson(Map<String, dynamic> json) => PackageSummary(
    packageName: json['packageName'],
    price: _toDoubleOrNull(json['price']),
  );
}
