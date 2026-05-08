class User {
  final String id;
  final String loginId; // Esto será lo que viene como USERID
  final String fullName; // Esto será lo que viene como USERNAME
  final int profileId; // perfil_id
  final int status;
  final bool appAccess;
  final String token;

  User({
    required this.id,
    required this.loginId,
    required this.fullName,
    required this.profileId,
    required this.status,
    required this.appAccess,
    required this.token,
  });
}
