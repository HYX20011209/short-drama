import 'package:flutter/material.dart';

import '../../models/ai_result.dart';
import '../../models/drama.dart';
import '../../services/ai_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/custom_page_transitions.dart';
import '../../widgets/drama_card.dart';
import '../drama_detail/drama_detail_page.dart';

class AiAssistantPage extends StatefulWidget {
  final String? contextDramaId;
  final String? contextDramaTitle;

  const AiAssistantPage({Key? key, this.contextDramaId, this.contextDramaTitle})
    : super(key: key);

  @override
  State<AiAssistantPage> createState() => _AiAssistantPageState();
}

class _AiAssistantPageState extends State<AiAssistantPage> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;
  String? _answer;
  List<Drama> _dramas = [];
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final q = _controller.text.trim();
    if (q.isEmpty || _loading) return;

    // 单次 setState 开始 loading
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final AiResult res = await AiService.ask(
        question: q,
        scene: widget.contextDramaId != null ? 'qa' : 'search',
        topK: 6,
        dramaId: widget.contextDramaId,
      );

      if (!mounted) return;

      // 统一一次性更新所有状态，避免多次 setState 抖动语义树
      setState(() {
        _answer = res.answer;
        _dramas = res.dramas;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'Request failed: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.contextDramaTitle != null
        ? 'Ask about ${widget.contextDramaTitle}'
        : 'AI Assistant';

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: AppTextStyles.headingSM),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInput(),
            const SizedBox(height: AppDimensions.spacingMD),
            if (_loading) const LinearProgressIndicator(),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: AppDimensions.spacingSM),
                child: Text(
                  _error!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
            if (_answer != null && _answer!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppDimensions.spacingMD),
                child: Text(_answer!, style: AppTextStyles.bodyLarge),
              ),
            const SizedBox(height: AppDimensions.spacingMD),
            Expanded(
              child: _dramas.isEmpty
                  ? Center(
                      child: Text(
                        _loading
                            ? ''
                            : 'No results yet. Try a query like "funny time travel".',
                        style: AppTextStyles.bodyMedium,
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        // 依据当前内容宽度动态计算高度（与首页网格视觉接近）
                        final contentWidth = constraints.maxWidth;
                        final cardHeight = (contentWidth / 1.6).clamp(
                          180.0,
                          300.0,
                        );

                        return ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: _dramas.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: AppDimensions.spacingSM),
                          itemBuilder: (context, index) {
                            final d = _dramas[index];
                            return SizedBox(
                              height: cardHeight,
                              child: DramaCard(
                                key: ValueKey(d.id),
                                drama: d,
                                onTap: () {
                                  Navigator.of(
                                    context,
                                  ).pushWithScale(DramaDetailPage(drama: d));
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: widget.contextDramaId != null
                  ? 'Ask about this drama...'
                  : 'What do you want to watch?',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingMD,
                vertical: AppDimensions.spacingSM,
              ),
            ),
            onSubmitted: (_) => _send(),
          ),
        ),
        const SizedBox(width: AppDimensions.spacingSM),
        ElevatedButton(
          onPressed: _loading ? null : _send,
          child: const Text('Send'),
        ),
      ],
    );
  }
}
