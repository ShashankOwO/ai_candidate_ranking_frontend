import 'dart:math';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../main.dart';
import '../../data/models/chat_models.dart';

class ChatDialog extends StatefulWidget {
  const ChatDialog({super.key});

  static Future<void> show(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isCompact = size.width < 600;

    if (isCompact) {
      return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: const FractionallySizedBox(
            heightFactor: 0.85,
            child: ChatDialog(),
          ),
        ),
      );
    }

    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => const Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(24),
        child: SizedBox(
          width: 520,
          height: 660,
          child: ChatDialog(),
        ),
      ),
    );
  }

  @override
  State<ChatDialog> createState() => _ChatDialogState();
}

class _ChatDialogState extends State<ChatDialog> {
  final TextEditingController _textCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  late final String _sessionId;
  final List<ChatMessageModel> _messages = [];
  bool _loading = false;

  final List<String> _quickPrompts = [
    'Get all candidates with how many resumes created',
    'Show resume chart for candidates',
    'Overview stats',
  ];

  @override
  void initState() {
    super.initState();
    _sessionId = 'session_';

    // Initial greeting message
    _messages.add(
      ChatMessageModel(
        role: 'assistant',
        content: 'Hello! I am your AI Candidate Assistant powered by MCP live tools.\n\n'
            'Ask me anything about your candidates, their uploaded resumes, or request visual charts of your resume distribution!',
        timestamp: DateTime.now().toIso8601String(),
      ),
    );
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    final query = text.trim();
    if (query.isEmpty || _loading) return;

    _textCtrl.clear();
    setState(() {
      _messages.add(
        ChatMessageModel(
          role: 'user',
          content: query,
          timestamp: DateTime.now().toIso8601String(),
        ),
      );
      _loading = true;
    });
    _scrollToBottom();

    try {
      final response = await chatbotRepository.sendMessage(
        message: query,
        sessionId: _sessionId,
      );

      if (!mounted) return;
      setState(() {
        _messages.add(response);
        _loading = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(
          ChatMessageModel(
            role: 'assistant',
            content: 'Sorry, I encountered an error: ',
            timestamp: DateTime.now().toIso8601String(),
            isError: true,
          ),
        );
        _loading = false;
      });
      _scrollToBottom();
    }
  }

  Future<void> _resetSession() async {
    try {
      await chatbotRepository.resetSession(_sessionId);
    } catch (_) {}

    if (!mounted) return;
    setState(() {
      _messages.clear();
      _messages.add(
        ChatMessageModel(
          role: 'assistant',
          content: 'Session memory cleared. How can I help you now?',
          timestamp: DateTime.now().toIso8601String(),
        ),
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chat memory reset successfully'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildQuickPrompts(),
          const Divider(height: 1),
          Expanded(child: _buildMessagesList()),
          const Divider(height: 1),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'AI Assistant',
                      style: AppTextStyles.label.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.greenAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'MCP Tools',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Text(
                  'Candidate & Resume Intelligence',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
            tooltip: 'Clear Chat Memory',
            onPressed: _resetSession,
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 20),
            tooltip: 'Close',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPrompts() {
    return Container(
      height: 44,
      color: AppColors.surfaceVariant.withValues(alpha: 0.5),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        scrollDirection: Axis.horizontal,
        itemCount: _quickPrompts.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final prompt = _quickPrompts[i];
          return ActionChip(
            label: Text(
              prompt,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: AppColors.primaryLight.withValues(alpha: 0.12),
            side: BorderSide(color: AppColors.primaryLight.withValues(alpha: 0.3)),
            padding: const EdgeInsets.symmetric(horizontal: 6),
            onPressed: () => _sendMessage(prompt),
          );
        },
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length + (_loading ? 1 : 0),
      itemBuilder: (context, i) {
        if (i == _messages.length) {
          return _buildLoadingBubble();
        }
        final msg = _messages[i];
        return _buildMessageItem(msg);
      },
    );
  }

  Widget _buildMessageItem(ChatMessageModel msg) {
    final isUser = msg.isUser;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primaryLight.withValues(alpha: 0.2),
              child: const Icon(Icons.smart_toy, size: 16, color: AppColors.primary),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isUser
                        ? AppColors.primary
                        : (msg.isError ? AppColors.errorLight : AppColors.surfaceVariant),
                    borderRadius: BorderRadius.circular(16).copyWith(
                      bottomRight: isUser ? const Radius.circular(2) : const Radius.circular(16),
                      bottomLeft: !isUser ? const Radius.circular(2) : const Radius.circular(16),
                    ),
                    border: isUser
                        ? null
                        : Border.all(
                            color: msg.isError ? AppColors.error.withValues(alpha: 0.3) : AppColors.border,
                          ),
                  ),
                  child: Text(
                    msg.content,
                    style: AppTextStyles.body.copyWith(
                      color: isUser
                          ? Colors.white
                          : (msg.isError ? AppColors.error : AppColors.textPrimary),
                    ),
                  ),
                ),
                if (msg.chartData != null) ...[
                  const SizedBox(height: 8),
                  _buildChartCard(msg.chartData!),
                ],
              ],
            ),
          ),
          if (isUser) const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildChartCard(ChartDataModel chart) {
    final maxVal = max(
      chart.summary?.maxResumes ?? 0,
      chart.items.isEmpty ? 1 : chart.items.map((i) => i.value).reduce(max),
    );
    final safeMax = max(maxVal, 1);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart, size: 18, color: AppColors.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  chart.title,
                  style: AppTextStyles.label.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              if (chart.summary != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    ' Resumes',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // High-level summary metrics
          if (chart.summary != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  _buildMetricBadge('Candidates', '', AppColors.info),
                  const SizedBox(width: 8),
                  _buildMetricBadge('Resumes', '', AppColors.success),
                  const SizedBox(width: 8),
                  _buildMetricBadge('Avg / Cand', '', AppColors.warning),
                ],
              ),
            ),

          // Candidate items bars
          if (chart.items.isEmpty)
            Text(
              'No candidate resume metrics to display.',
              style: AppTextStyles.caption,
            )
          else
            ...chart.items.map((item) {
              final ratio = (item.value / safeMax).clamp(0.0, 1.0);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.label,
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: item.value > 0
                                ? AppColors.primary.withValues(alpha: 0.15)
                                : Colors.grey.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            ' resume',
                            style: AppTextStyles.caption.copyWith(
                              fontWeight: FontWeight.bold,
                              color: item.value > 0 ? AppColors.primary : AppColors.textTertiary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: ratio,
                        minHeight: 8,
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          item.value > 0 ? AppColors.primary : Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildMetricBadge(String title, String val, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(
              val,
              style: AppTextStyles.label.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: AppTextStyles.caption.copyWith(
                fontSize: 10,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingBubble() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primaryLight.withValues(alpha: 0.2),
            child: const Icon(Icons.smart_toy, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(16).copyWith(
                bottomLeft: const Radius.circular(2),
              ),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                ),
                const SizedBox(width: 10),
                Text(
                  'Querying MCP candidate tools...',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: AppColors.surface,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textCtrl,
              textInputAction: TextInputAction.send,
              onSubmitted: _sendMessage,
              decoration: InputDecoration(
                hintText: 'Ask about candidates, resumes, charts...',
                hintStyle: AppTextStyles.bodySecondary.copyWith(fontSize: 13),
                isDense: true,
                filled: true,
                fillColor: AppColors.surfaceVariant,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            icon: _loading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.send, size: 18),
            onPressed: _loading ? null : () => _sendMessage(_textCtrl.text),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
