class Drama {
  final int id;
  final String title;
  final String? description;
  final String? coverUrl;
  final String? category;
  final int totalEpisodes;
  final int status;
  final int orderNum;
  final DateTime createTime;
  final DateTime updateTime;

  Drama({
    required this.id,
    required this.title,
    this.description,
    this.coverUrl,
    this.category,
    required this.totalEpisodes,
    required this.status,
    required this.orderNum,
    required this.createTime,
    required this.updateTime,
  });

  factory Drama.fromJson(Map<String, dynamic> json) {
    return Drama(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      coverUrl: json['coverUrl'],
      category: json['category'],
      totalEpisodes: json['totalEpisodes'] ?? 0,
      status: json['status'] ?? 1,
      orderNum: json['orderNum'] ?? 0,
      createTime: DateTime.parse(
        json['createTime'] ?? DateTime.now().toIso8601String(),
      ),
      updateTime: DateTime.parse(
        json['updateTime'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'coverUrl': coverUrl,
      'category': category,
      'totalEpisodes': totalEpisodes,
      'status': status,
      'orderNum': orderNum,
      'createTime': createTime.toIso8601String(),
      'updateTime': updateTime.toIso8601String(),
    };
  }
}