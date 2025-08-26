import '../models/ai_result.dart';
import '../utils/network_helper.dart';

class AiService {
  static Future<AiResult> ask({
    required String question,
    String scene = 'search',
    int topK = 6,
    String? dramaId,
  }) async {
    final body = {
      'question': question,
      'scene': scene,
      'topK': topK,
      if (dramaId != null) 'dramaId': int.tryParse(dramaId) ?? dramaId,
    };
    final resp = await NetworkHelper.post('/ai/ask', body);
    if (resp == null) {
      return AiResult(answer: 'No response from server.', dramas: []);
    }
    return AiResult.fromApi(resp);
  }
}
