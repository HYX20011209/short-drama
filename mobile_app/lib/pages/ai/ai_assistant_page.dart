import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  // 打字机状态
  Timer? _typeTimer;
  Timer? _cursorTimer;
  String _answerFull = '';
  String _typingText = '';
  int _typed = 0;
  bool _cursorVisible = true;

  bool get _isTyping => _typeTimer != null;

  @override
  void initState() {
    super.initState();
    _cursorTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (!mounted) return;
      setState(() => _cursorVisible = !_cursorVisible);
    });
  }

  @override
  void dispose() {
    _typeTimer?.cancel();
    _cursorTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _stopTypewriter() {
    _typeTimer?.cancel();
    _typeTimer = null;
  }

  void _startTypewriter(String text) {
    _stopTypewriter();
    _answerFull = text;
    _typingText = '';
    _typed = 0;

    final len = text.length;
    final step = len > 400 ? 2 : 1; // 长文本更快
    final intervalMs = len > 400 ? 10 : 18; // 间隔更短

    _typeTimer = Timer.periodic(Duration(milliseconds: intervalMs), (t) {
      if (!mounted) return;
      if (_typed >= len) {
        t.cancel();
        _typeTimer = null;
        setState(() {}); // 收尾刷新（隐藏 Skip）
        return;
      }
      final next = (_typed + step).clamp(0, len);
      setState(() {
        _typingText = _answerFull.substring(0, next);
        _typed = next;
      });
    });
  }

  void _skipTyping() {
    _stopTypewriter();
    setState(() {
      _typingText = _answerFull;
    });
  }

  Future<void> _copyAnswer() async {
    final text = _answerFull.isNotEmpty ? _answerFull : _typingText;
    if (text.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Copied')));
  }

  Future<void> _send() async {
    final q = _controller.text.trim();
    if (q.isEmpty || _loading) return;

    setState(() {
      _loading = true;
      _error = null;
      _answerFull = '';
      _typingText = '';
      _typed = 0;
    });

    try {
      final AiResult res = await AiService.ask(
        question: q,
        scene: widget.contextDramaId != null ? 'qa' : 'search',
        topK: 6,
        dramaId: widget.contextDramaId,
      );

      if (!mounted) return;

      // 回答启动打字效果；卡片结果一次性渲染
      _startTypewriter(res.answer);
      setState(() {
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

  Widget _buildAnswer() {
    final showHint =
        _answerFull.isEmpty &&
        _typingText.isEmpty &&
        !_loading &&
        _error == null;
    final content = _typingText.isNotEmpty ? _typingText : _answerFull;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Container(
        key: ValueKey(content.isEmpty && !showHint),
        width: double.infinity,
        padding: const EdgeInsets.all(AppDimensions.spacingLG),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: showHint
            ? Text(
                'Ask for recommendations or plot details...',
                style: AppTextStyles.bodyMedium,
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 打字机 + 闪烁光标
                  Wrap(
                    children: [
                      Text(content, style: AppTextStyles.bodyLarge),
                      if (_isTyping)
                        AnimatedOpacity(
                          opacity: _cursorVisible ? 1 : 0,
                          duration: const Duration(milliseconds: 250),
                          child: Text(
                            ' ▍',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacingSM),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: _copyAnswer,
                        icon: const Icon(Icons.copy_rounded, size: 18),
                        label: const Text('Copy'),
                      ),
                      const SizedBox(width: AppDimensions.spacingXS),
                      if (_isTyping)
                        TextButton.icon(
                          onPressed: _skipTyping,
                          icon: const Icon(
                            Icons.fast_forward_rounded,
                            size: 18,
                          ),
                          label: const Text('Skip'),
                        ),
                    ],
                  ),
                ],
              ),
      ),
    );
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
            _buildAnswer(),
            const SizedBox(height: AppDimensions.spacingMD),
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
                            return TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: 1),
                              duration: Duration(
                                milliseconds: 250 + index * 40,
                              ),
                              builder: (context, v, child) {
                                return Opacity(
                                  opacity: v,
                                  child: Transform.translate(
                                    offset: Offset(0, (1 - v) * 12),
                                    child: child,
                                  ),
                                );
                              },
                              child: SizedBox(
                                height:
                                    cardHeight, // 使用上方 LayoutBuilder 计算得到的高度
                                child: DramaCard(
                                  key: ValueKey(d.id),
                                  drama: d,
                                  onTap: () {
                                    Navigator.of(
                                      context,
                                    ).pushWithScale(DramaDetailPage(drama: d));
                                  },
                                ),
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
