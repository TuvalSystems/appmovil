import 'package:tuvalapp/domain/entities/user.dart';

class UserModel {
  final int id;
  final String userId;
  final String fullName;
  final int appProfileId;
  final String appProfileName;
  final int status;
  final String token;
  final bool appAccess;
  final bool mustChangePassword;

  UserModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.appProfileId,
    required this.appProfileName,
    required this.status,
    required this.token,
    required this.appAccess,
    required this.mustChangePassword,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> userJson = _extractUserJson(json);

    final String token = _extractToken(json, userJson);

    return UserModel(
      id: _toInt(userJson['id']),
      userId: userJson['USERID']?.toString() ?? '',
      fullName: userJson['USERNAME']?.toString() ?? '',
      appProfileId: _toInt(userJson['perfil_app_id']),
      appProfileName: userJson['perfil_app_name']?.toString() ?? '',
      status: _toInt(userJson['status']),
      appAccess: _toBool(userJson['app_access']),
      mustChangePassword: _toBool(userJson['must_change_password']),
      token: token,
    );
  }

  User toEntity() => User(
        id: id.toString(),
        loginId: userId,
        fullName: fullName,
        appProfileId: appProfileId,
        appProfileName: appProfileName,
        status: status,
        token: token,
        appAccess: appAccess,
        mustChangePassword: mustChangePassword,
      );

  static Map<String, dynamic> _extractUserJson(Map<String, dynamic> json) {
    final data = json['data'];

    // Caso login:
    // { data: { user: {...}, token: "..." } }
    if (data is Map && data['user'] is Map) {
      return Map<String, dynamic>.from(data['user']);
    }

    // Caso currentUser:
    // { data: { id, USERID, USERNAME, ... } }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    // Caso alternativo:
    // { user: {...} }
    if (json['user'] is Map) {
      return Map<String, dynamic>.from(json['user']);
    }

    // Caso usuario directo:
    // { id, USERID, USERNAME, ... }
    return json;
  }

  static String _extractToken(
    Map<String, dynamic> json,
    Map<String, dynamic> userJson,
  ) {
    final data = json['data'];

    if (json['token'] != null) {
      return json['token'].toString();
    }

    if (data is Map && data['token'] != null) {
      return data['token'].toString();
    }

    if (userJson['token'] != null) {
      return userJson['token'].toString();
    }

    return '';
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is bool) return value ? 1 : 0;

    return int.tryParse(value.toString()) ?? 0;
  }

  static bool _toBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;

    final text = value.toString().toLowerCase().trim();

    return text == '1' || text == 'true';
  }
}