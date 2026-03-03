// ═══════════════════════════════════════════════
//  SUPER ADMIN MODELS
//  lib/models/super_admin_models.dart
// ═══════════════════════════════════════════════

// ── 1. SuperAdmin (matches DB: id,name,email,mobile,token) ──
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
        id: json['id'],
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        mobile: json['mobile'],
        token: json['token'],
      );
}

// ── 2. Signup Request → POST /signup ──
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

// ── 3. Login Request → POST /login ──
class LoginRequestModel {
  final String email, password;
  LoginRequestModel({required this.email, required this.password});
  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

// ── 4. Auth Response (signup + login) ──
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

// ── 5. Service Request ──
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
        id: json['id'],
        hubId: json['hubId'],
        status: json['status'] ?? 'pending',
        description: json['description'],
        createdAt: json['createdAt'],
        hub: json['Hub'] != null ? HubSummary.fromJson(json['Hub']) : null,
        hubOwner: json['HubOwner'] != null
            ? HubOwnerSummary.fromJson(json['HubOwner'])
            : null,
      );
}

// ── 6. Service Request Stats ──
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
        total: json['total'] ?? 0,
        pending: json['pending'] ?? 0,
        inProgress: json['inProgress'] ?? 0,
        completed: json['completed'] ?? 0,
      );
}

// ── 7. Wash History ──
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
        id: json['id'],
        userId: json['userId'],
        hubId: json['hubId'],
        finalAmount: json['finalAmount'] != null
            ? double.tryParse(json['finalAmount'].toString())
            : null,
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

// ── 8. Revenue ──
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
    totalWashes: json['totalWashes'] ?? 0,
    totalRevenue: json['totalRevenue'] != null
        ? (json['totalRevenue'] as num).toDouble()
        : 0.0,
    date: json['date'],
    hubId: json['hubId'],
  );
}

// ── 9. User ──
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
    id: json['id'],
    name: json['name'] ?? '',
    mobile: json['mobile'] ?? '',
    createdAt: json['createdAt'],
  );
}

// ── 10. New Users Stats (last 30 days) ──
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
        totalNewUsers: json['totalNewUsers'] ?? 0,
        dailyStats: json['dailyStats'] != null
            ? (json['dailyStats'] as List)
                  .map((e) => DailyStat.fromJson(e))
                  .toList()
            : [],
      );
}

// ── 11. New HubOwners Stats (last 30 days) ──
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
        totalNewHubOwners: json['totalNewHubOwners'] ?? 0,
        dailyStats: json['dailyStats'] != null
            ? (json['dailyStats'] as List)
                  .map((e) => DailyStat.fromJson(e))
                  .toList()
            : [],
      );
}

// ── Helper classes ──
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
  factory DailyStat.fromJson(Map<String, dynamic> json) => DailyStat(
    date: json['date'] ?? '',
    count: int.tryParse(json['count'].toString()) ?? 0,
  );
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
  factory UserSummary.fromJson(Map<String, dynamic> json) =>
      UserSummary(id: json['id'], name: json['name'], mobile: json['mobile']);
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
    price: json['price'] != null ? (json['price'] as num).toDouble() : null,
  );
}
