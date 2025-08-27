import 'drama.dart';

class AiResult {
  final String answer;
  final List<Drama> dramas;

  AiResult({required this.answer, required this.dramas});

  factory AiResult.fromApi(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    final String answer = (data['answer'] ?? '').toString();
    final List list = data['relatedDramas'] ?? [];
    final dramas = list
        .map((e) => Drama.fromJson(e as Map<String, dynamic>))
        .toList()
        .cast<Drama>();
    return AiResult(answer: answer, dramas: dramas);
  }
}
