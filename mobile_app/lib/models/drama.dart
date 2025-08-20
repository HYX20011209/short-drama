class Drama {
  final String id;
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
    // 安全的整数解析函数
    int? parseIntOrNull(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) {
        if (value.isEmpty) return null;
        return int.tryParse(value);
      }
      return null;
    }

    return Drama(
      id: json['id']?.toString() ?? '0',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      coverUrl: json['coverUrl']?.toString(),
      category: json['category']?.toString(),
      totalEpisodes: parseIntOrNull(json['totalEpisodes']) ?? 0,
      status: parseIntOrNull(json['status']) ?? 1,
      orderNum: parseIntOrNull(json['orderNum']) ?? 0,
      createTime: DateTime.parse(
        json['createTime']?.toString() ?? DateTime.now().toIso8601String(),
      ),
      updateTime: DateTime.parse(
        json['updateTime']?.toString() ?? DateTime.now().toIso8601String(),
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
