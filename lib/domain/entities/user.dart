class User {
  final String id;
  final String loginId;
  final String fullName;
  final int appProfileId;
  final String appProfileName;
  final int status;
  final String token;
  final bool appAccess;
  final bool mustChangePassword;

  User({
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
}