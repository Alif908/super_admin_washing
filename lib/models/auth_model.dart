class AuthModel {
  final int? id;
  final String name;
  final String email;
  final String mobile;
  final String? token;

  AuthModel({
    this.id,
    required this.name,
    required this.email,
    required this.mobile,
    this.token,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? json['phone'] ?? '',
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'mobile': mobile,
      };
}

class SignUpRequestModel {
  final String name;
  final String email;
  final String password;
  final String mobile;

  SignUpRequestModel({
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

class AuthResponse {
  final bool success;
  final String message;
  final AuthModel? admin;
  final String? token;

  AuthResponse({
    required this.success,
    required this.message,
    this.admin,
    this.token,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json, {bool success = true}) {
    return AuthResponse(
      success: success,
      message: json['message'] ?? '',
      token: json['token'],
      admin: json['data'] != null
          ? AuthModel.fromJson(json['data'])
          : json['admin'] != null
              ? AuthModel.fromJson(json['admin'])
              : null,
    );
  }
}