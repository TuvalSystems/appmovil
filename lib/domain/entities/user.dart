class User {
  final int id;
  final String loginId;
  final String fullName;
  final int appProfileId;
  final String appProfileName;
  final bool status;
  final String token;
  final bool appAccess;
  final bool mustChangePassword;

  const User({
    required this.id,
    required this.loginId,
    required this.fullName,
    required this.appProfileId,
    required this.appProfileName,
    required this.status,
    required this.token,
    required this.appAccess,
    required this.mustChangePassword,
  });

  User copyWith({
    int? id,
    String? loginId,
    String? fullName,
    int? appProfileId,
    String? appProfileName,
    bool? status,
    String? token,
    bool? appAccess,
    bool? mustChangePassword,
  }) {
    return User(
      id: id ?? this.id,
      loginId: loginId ?? this.loginId,
      fullName: fullName ?? this.fullName,
      appProfileId: appProfileId ?? this.appProfileId,
      appProfileName: appProfileName ?? this.appProfileName,
      status: status ?? this.status,
      token: token ?? this.token,
      appAccess: appAccess ?? this.appAccess,
      mustChangePassword: mustChangePassword ?? this.mustChangePassword,
    );
  }
}
