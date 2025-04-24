class UserEntity {
  final String uid;
  final String? email;
  final String? displayName;
  final String? username;
  final bool isEmailVerified;

  UserEntity({
    required this.uid,
    this.email,
    this.displayName,
    this.username,
    this.isEmailVerified = false,
  });
}
