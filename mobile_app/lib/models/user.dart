class User {
  final int id;
  final String userAccount;
  final String? userName;
  final String? userAvatar;
  final String? userProfile;
  final String userRole;
  final DateTime createTime;

  User({
    required this.id,
    required this.userAccount,
    this.userName,
    this.userAvatar,
    this.userProfile,
    required this.userRole,
    required this.createTime,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      userAccount: json['userAccount'] ?? '',
      userName: json['userName'],
      userAvatar: json['userAvatar'],
      userProfile: json['userProfile'],
      userRole: json['userRole'] ?? 'user',
      createTime: DateTime.parse(
        json['createTime'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}