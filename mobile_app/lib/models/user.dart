class User {
  final String id;
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
      id: json['id']?.toString() ?? '0',
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

  // 序列化方法，用于本地存储
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userAccount': userAccount,
      'userName': userName,
      'userAvatar': userAvatar,
      'userProfile': userProfile,
      'userRole': userRole,
      'createTime': createTime.toIso8601String(),
    };
  }

  // 用户昵称显示逻辑
  String get displayName {
    if (userName != null && userName!.isNotEmpty) {
      return userName!;
    }
    return userAccount;
  }

  // 是否为管理员
  bool get isAdmin => userRole == 'admin';

  // 复制方法，用于状态更新
  User copyWith({
    String? id,
    String? userAccount,
    String? userName,
    String? userAvatar,
    String? userProfile,
    String? userRole,
    DateTime? createTime,
  }) {
    return User(
      id: id ?? this.id,
      userAccount: userAccount ?? this.userAccount,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      userProfile: userProfile ?? this.userProfile,
      userRole: userRole ?? this.userRole,
      createTime: createTime ?? this.createTime,
    );
  }
}
