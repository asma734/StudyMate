// ══════════════════════════════════════════════════════════════
// AiTutorScreen — StudyMate AI Companion
// Chat interface for the AI Academic Tutor (Gemini-powered).
// ══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/books_provider.dart';
import '../../services/ai_service.dart';

class AiTutorScreen extends StatefulWidget {
  const AiTutorScreen({super.key});

  @override
  State<AiTutorScreen> createState() => _AiTutorScreenState();
}

class _AiTutorScreenState extends State<AiTutorScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final AiService _aiService = AiService();

  final List<Map<String, String>> _messages = [];
  final List<Map<String, String>> _history = [];
  String _selectedSubject = 'General';
  bool _isTyping = false;

  static const _quickPrompts = [
    '📝 Explain this concept',
    '🧠 Quiz me on this topic',
    '✨ Summarize my notes',
    '🔁 Give me an example',
    '❓ I don\'t understand...',
  ];

  @override
  void initState() {
    super.initState();
    // Welcome message
    _messages.add({
      'role': 'assistant',
      'content': '👋 Bonjour! Je suis **StudyMate AI**, ton tuteur académique intelligent.\n\nJe peux t\'aider à:\n• Comprendre tes cours 📖\n• Générer des quiz 🧠\n• Résumer tes notes ✨\n• Répondre à tes questions en 🇫🇷 🇬🇧 🇩🇿\n\nSélectionne une matière et commence à me parler!',
    });
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _msgCtrl.clear();

    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _isTyping = true;
    });
    _scrollToBottom();

    final response = await _aiService.chat(
      userMessage: text,
      subjectContext: _selectedSubject,
      history: _history,
    );

    _history.add({'role': 'user', 'content': text});
    _history.add({'role': 'model', 'content': response});

    setState(() {
      _messages.add({'role': 'assistant', 'content': response});
      _isTyping = false;
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final subjects = context.watch<BooksProvider>().subjects;
    final subjectNames = ['General', ...subjects.map((s) => s.name)];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('AI Tutor 🤖', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          // Subject selector
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: DropdownButton<String>(
              value: _selectedSubject,
              underline: const SizedBox(),
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13),
              icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
              items: subjectNames.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setState(() => _selectedSubject = v!),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, i) {
                if (i == _messages.length) return _TypingIndicator();
                final msg = _messages[i];
                final isUser = msg['role'] == 'user';
                return _ChatBubble(message: msg['content']!, isUser: isUser);
              },
            ),
          ),

          // Quick prompts
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _quickPrompts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) => GestureDetector(
                onTap: () => _sendMessage(_quickPrompts[i]),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primarySoft.withOpacity(0.4)),
                  ),
                  child: Text(
                    _quickPrompts[i],
                    style: const TextStyle(color: AppColors.primary, fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Input bar
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: AppColors.shadowPurple, blurRadius: 10, offset: const Offset(0, 3))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgCtrl,
                    maxLines: 3,
                    minLines: 1,
                    decoration: const InputDecoration(
                      hintText: 'Ask me anything about your course...',
                      hintStyle: TextStyle(color: AppColors.textLight, fontSize: 13.5),
                      border: InputBorder.none,
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _sendMessage(_msgCtrl.text),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Chat Bubble ────────────────────────────────────────────────
class _ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;

  const _ChatBubble({required this.message, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32, height: 32,
              decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
              child: const Center(child: Text('🤖', style: TextStyle(fontSize: 16))),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primary : Theme.of(context).cardColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                boxShadow: [BoxShadow(color: AppColors.shadowPurple, blurRadius: 6, offset: const Offset(0, 2))],
              ),
              child: Text(
                message,
                style: TextStyle(
                  color: isUser ? Colors.white : AppColors.textMain,
                  fontSize: 13.5,
                  height: 1.5,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32, height: 32,
              decoration: const BoxDecoration(color: AppColors.peach, shape: BoxShape.circle),
              child: const Center(child: Text('👩‍🎓', style: TextStyle(fontSize: 16))),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Typing Indicator ───────────────────────────────────────────
class _TypingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
            child: const Center(child: Text('🤖', style: TextStyle(fontSize: 16))),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18), topRight: Radius.circular(18), bottomRight: Radius.circular(18),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Dot(delay: 0),
                SizedBox(width: 4),
                _Dot(delay: 150),
                SizedBox(width: 4),
                _Dot(delay: 300),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.forward();
    });
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 7, height: 7,
        decoration: const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
      ),
    );
  }
}
