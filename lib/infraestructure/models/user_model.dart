import 'package:tuvalapp/domain/entities/user.dart';

class UserModel {
  final int id;
  final String userId;
  final String fullName;
  final int perfilId;
  final int status;
  final String token;
  final bool appAccess;
  UserModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.perfilId,
    required this.status,
    required this.token,
    required this.appAccess
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> userJson;

    if (json['data'] != null && json['data']['user'] != null) {
      userJson = Map<String, dynamic>.from(json['data']['user']);
    } else if (json['user'] != null) {
      userJson = Map<String, dynamic>.from(json['user']);
    } else {
      userJson = json;
    }

    final String token =
        json['token']?.toString() ??
        json['data']?['token']?.toString() ??
        userJson['token']?.toString() ??
        '';

    return UserModel(
      id            : _toInt(userJson['id']),
      userId        : userJson['USERID']?.toString() ?? '',
      fullName      : userJson['USERNAME']?.toString() ?? '',
      perfilId      : _toInt(userJson['perfil_id']),
      status        : _toInt(userJson['status']),
      appAccess     : _toBool(userJson['app_access']),
      token         : token,
    );
  }

  User toEntity() => User(
    id        : id.toString(),
    loginId   : userId,
    fullName  : fullName,
    profileId : perfilId,
    status    : status,
    token     : token,
    appAccess : appAccess
  );

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static bool _toBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    return value.toString() == '1' || value.toString().toLowerCase() == 'true';
  }
}
