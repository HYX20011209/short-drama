/// 类型转换辅助类
class TypeHelper {
  /// 安全地将String转换为int
  static int? safeParseInt(String? value) {
    if (value == null || value.isEmpty) return null;
    return int.tryParse(value);
  }

  /// 安全地将String转换为int，如果失败返回默认值
  static int parseIntWithDefault(String? value, int defaultValue) {
    if (value == null || value.isEmpty) return defaultValue;
    return int.tryParse(value) ?? defaultValue;
  }

  /// 验证并转换ID，如果转换失败会抛出异常
  static int parseId(String id, String context) {
    final result = int.tryParse(id);
    if (result == null) {
      throw ArgumentError('Invalid $context ID: $id');
    }
    return result;
  }

  /// 安全地转换Drama ID为int类型
  static int? parseDramaId(String? dramaId) {
    return safeParseInt(dramaId);
  }

  /// 安全地转换Video ID为int类型
  static int? parseVideoId(String? videoId) {
    return safeParseInt(videoId);
  }
}
