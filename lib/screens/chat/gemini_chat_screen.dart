import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/property_provider.dart';
import '../../services/gemini_service.dart';
import '../../theme/theme.dart';

class GeminiChatScreen extends StatefulWidget {
  const GeminiChatScreen({Key? key}) : super(key: key);

  @override
  State<GeminiChatScreen> createState() => _GeminiChatScreenState();
}

class _GeminiChatScreenState extends State<GeminiChatScreen> {
  final GeminiService _gemini = GeminiService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [
    const _ChatMessage(
      role: _ChatRole.assistant,
      text:
          'Ask me about EstateIQ properties, ROI, valuation, neighborhood scores, or market strategy.',
    ),
  ];
  bool _isSending = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final question = _controller.text.trim();
    if (question.isEmpty || _isSending) return;

    final provider = context.read<PropertyProvider>();
    setState(() {
      _messages.add(_ChatMessage(role: _ChatRole.user, text: question));
      _isSending = true;
      _controller.clear();
    });
    _scrollToBottom();

    try {
      final answer = await _gemini.ask(
        question: question,
        properties: provider.allProperties,
      );
      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage(role: _ChatRole.assistant, text: answer));
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _messages.add(
          _ChatMessage(
            role: _ChatRole.assistant,
            text: error.toString(),
            isError: true,
          ),
        );
      });
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final configured = _gemini.isConfigured;
    return Column(
      children: [
        if (!configured)
          Container(
            width: double.infinity,
            color: AppColors.warn.withOpacity(0.12),
            padding: const EdgeInsets.all(12),
            child: const Text(
              'Gemini is not configured. Run with --dart-define=GEMINI_API_KEY=your_key.',
              style: TextStyle(color: AppColors.warn, fontSize: 12),
            ),
          ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            itemCount: _messages.length + (_isSending ? 1 : 0),
            itemBuilder: (context, index) {
              if (_isSending && index == _messages.length) {
                return const _TypingBubble();
              }
              return _MessageBubble(message: _messages[index]);
            },
          ),
        ),
        SafeArea(
          top: false,
          child: Container(
            color: AppColors.bg1,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: const InputDecoration(
                      hintText: 'Ask EstateIQ...',
                      prefixIcon: Icon(Icons.auto_awesome, size: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 48,
                  height: 48,
                  child: IconButton.filled(
                    onPressed: configured && !_isSending ? _sendMessage : null,
                    icon: const Icon(Icons.send_rounded),
                    tooltip: 'Send',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

enum _ChatRole { user, assistant }

class _ChatMessage {
  const _ChatMessage({
    required this.role,
    required this.text,
    this.isError = false,
  });

  final _ChatRole role;
  final String text;
  final bool isError;
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final _ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == _ChatRole.user;
    final color = message.isError
        ? AppColors.bad.withOpacity(0.18)
        : isUser
            ? AppColors.accent.withOpacity(0.24)
            : AppColors.bg1;
    final borderColor = message.isError
        ? AppColors.bad
        : isUser
            ? AppColors.accent
            : AppColors.line;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message.text,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 14,
            height: 1.35,
          ),
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.bg1,
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Thinking...',
          style: TextStyle(color: AppColors.muted, fontSize: 13),
        ),
      ),
    );
  }
}
