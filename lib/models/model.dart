// models/super_admin.dart - Updated for your exact response structure

class SuperAdmin {
  final int id;
  final String name;
  final String email;
  final String? mobile;
  final String? token;

  SuperAdmin({
    required this.id,
    required this.name,
    required this.email,
    this.mobile,
    this.token,
  });

  factory SuperAdmin.fromJson(Map<String, dynamic> json) {
    return SuperAdmin(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      mobile: json['mobile'],
      token: json['token'],
    );
  }
}

// Service Request Model (with Hub & HubOwner)
class ServiceRequest {
  final int id;
  final String hubId;
  final String status;
  final String description;
  final DateTime createdAt;
  final Hub? hub;
  final HubOwner? hubOwner;

  ServiceRequest({
    required this.id,
    required this.hubId,
    required this.status,
    required this.description,
    required this.createdAt,
    this.hub,
    this.hubOwner,
  });

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: json['id'],
      hubId: json['hubId'],
      status: json['status'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      hub: json['Hub'] != null ? Hub.fromJson(json['Hub']) : null,
      hubOwner: json['HubOwner'] != null ? HubOwner.fromJson(json['HubOwner']) : null,
    );
  }
}

class Hub {
  final String hubName;
  final String address;
  final String mobile;
  final String? hubOwnerName;

  Hub({
    required this.hubName,
    required this.address,
    required this.mobile,
    this.hubOwnerName,
  });

  factory Hub.fromJson(Map<String, dynamic> json) {
    return Hub(
      hubName: json['hubName'],
      address: json['address'],
      mobile: json['mobile'],
      hubOwnerName: json['hubOwnerName'],
    );
  }
}

class HubOwner {
  final String email;
  final String mobile;

  HubOwner({required this.email, required this.mobile});

  factory HubOwner.fromJson(Map<String, dynamic> json) {
    return HubOwner(
      email: json['email'],
      mobile: json['mobile'],
    );
  }
}

// Revenue Response
class RevenueResponse {
  final bool success;
  final int totalWashes;
  final double totalRevenue;

  RevenueResponse({
    required this.success,
    required this.totalWashes,
    required this.totalRevenue,
  });

  factory RevenueResponse.fromJson(Map<String, dynamic> json) {
    return RevenueResponse(
      success: json['success'],
      totalWashes: json['totalWashes'],
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
    );
  }
}

// Stats Response (30 days)
class StatsResponse {
  final bool success;
  final int totalNewUsers;
  final List<DailyStat> dailyStats;
  final Map<String, String> range;

  StatsResponse({
    required this.success,
    required this.totalNewUsers,
    required this.dailyStats,
    required this.range,
  });

  factory StatsResponse.fromJson(Map<String, dynamic> json) {
    return StatsResponse(
      success: json['success'],
      totalNewUsers: json['totalNewUsers'],
      dailyStats: (json['dailyStats'] as List?)
          ?.map((e) => DailyStat.fromJson(e))
          .toList() ?? [],
      range: Map<String, String>.from(json['range'] ?? {}),
    );
  }
}

class DailyStat {
  final String date;
  final int count;

  DailyStat({required this.date, required this.count});

  factory DailyStat.fromJson(Map<String, dynamic> json) {
    return DailyStat(
      date: json['date'],
      count: json['count'],
    );
  }
}
