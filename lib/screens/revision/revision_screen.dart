// ══════════════════════════════════════════════════════════════
// RevisionScreen — StudyMate AI Companion
// AI-generated MCQ quizzes from your subject notes.
// ══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/books_provider.dart';
import '../../services/ai_service.dart';

class RevisionScreen extends StatefulWidget {
  const RevisionScreen({super.key});

  @override
  State<RevisionScreen> createState() => _RevisionScreenState();
}

class _RevisionScreenState extends State<RevisionScreen> {
  final AiService _aiService = AiService();

  String _selectedSubject = '';
  List<QuizQuestion> _questions = [];
  int _currentQ = 0;
  int? _selectedAnswer;
  bool _answered = false;
  int _score = 0;
  bool _isLoading = false;
  bool _quizDone = false;

  void _startQuiz(BuildContext context) async {
    if (_selectedSubject.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a subject first')),
      );
      return;
    }

    setState(() { _isLoading = true; });

    final booksProvider = context.read<BooksProvider>();
    final notes = booksProvider.notesForSubject(_selectedSubject);
    final noteContent = notes.map((n) => '${n.title}\n${n.content}').join('\n\n');

    final questions = await _aiService.generateQuiz(
      subjectName: booksProvider.subjectById(_selectedSubject)?.name ?? 'Unknown',
      noteContent: noteContent.isEmpty
          ? 'Generate general questions about computer science and programming.'
          : noteContent,
    );

    setState(() {
      _questions = questions;
      _currentQ = 0;
      _selectedAnswer = null;
      _answered = false;
      _score = 0;
      _isLoading = false;
      _quizDone = false;
    });
  }

  void _selectAnswer(int index) {
    if (_answered) return;
    setState(() {
      _selectedAnswer = index;
      _answered = true;
      if (index == _questions[_currentQ].correctIndex) _score++;
    });
  }

  void _nextQuestion() {
    if (_currentQ < _questions.length - 1) {
      setState(() {
        _currentQ++;
        _selectedAnswer = null;
        _answered = false;
      });
    } else {
      setState(() { _quizDone = true; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final subjects = context.watch<BooksProvider>().subjects;

    if (subjects.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Revision 🧠', style: TextStyle(fontWeight: FontWeight.w800))),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🧠', style: TextStyle(fontSize: 60)),
                SizedBox(height: 20),
                Text('Create subject books first!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center),
                SizedBox(height: 10),
                Text('Go to My Books and add your subjects, then come back to generate quizzes.',
                  style: TextStyle(color: AppColors.textMuted), textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      );
    }

    if (_selectedSubject.isEmpty) _selectedSubject = subjects.first.id;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Revision 🧠', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subject selector card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: AppColors.shadowPurple, blurRadius: 8, offset: const Offset(0, 3))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Quiz Subject', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _selectedSubject,
                    decoration: InputDecoration(
                      filled: true, fillColor: AppColors.bgLight,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    items: subjects.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                    onChanged: (v) => setState(() { _selectedSubject = v!; _questions = []; _quizDone = false; }),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : () => _startQuiz(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: _isLoading
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.play_arrow_rounded),
                      label: Text(_isLoading ? 'Generating quiz...' : 'Generate Quiz ✨',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Quiz content
            if (_questions.isNotEmpty && !_quizDone) ...[
              _buildProgressBar(),
              const SizedBox(height: 20),
              _buildQuestion(),
            ],
            if (_quizDone) _buildResults(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Question ${_currentQ + 1} of ${_questions.length}',
              style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
            Text('Score: $_score/${_currentQ + (_answered ? 1 : 0)}',
              style: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: (_currentQ + 1) / _questions.length,
            backgroundColor: AppColors.primaryLight,
            color: AppColors.primary,
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestion() {
    final q = _questions[_currentQ];
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: AppColors.shadowPurple, blurRadius: 8, offset: const Offset(0, 3))],
              ),
              child: Text(q.question,
                style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700, height: 1.5)),
            ),
            const SizedBox(height: 16),
            ...q.options.asMap().entries.map((e) => _buildOption(e.key, e.value, q)),
            if (_answered) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.mint.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('💡 ', style: TextStyle(fontSize: 16)),
                    Expanded(
                      child: Text(q.explanation,
                        style: const TextStyle(fontSize: 13, height: 1.5, color: AppColors.textMain)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    _currentQ < _questions.length - 1 ? 'Next Question →' : 'See Results 🏆',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOption(int index, String option, QuizQuestion q) {
    Color bg = Theme.of(context).cardColor;
    Color border = AppColors.borderLight;
    if (_answered) {
      if (index == q.correctIndex) { bg = AppColors.mint; border = AppColors.mintDark; }
      else if (index == _selectedAnswer) { bg = AppColors.softPink; border = AppColors.peachDark; }
    } else if (_selectedAnswer == index) {
      bg = AppColors.primaryLight; border = AppColors.primary;
    }

    return GestureDetector(
      onTap: () => _selectAnswer(index),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: border.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + index),
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: border),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(option, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600))),
            if (_answered && index == q.correctIndex)
              const Icon(Icons.check_circle_rounded, color: AppColors.mintDark, size: 20),
            if (_answered && index == _selectedAnswer && index != q.correctIndex)
              const Icon(Icons.cancel_rounded, color: AppColors.peachDark, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    final pct = (_score / _questions.length * 100).round();
    final emoji = pct >= 80 ? '🏆' : pct >= 60 ? '👍' : pct >= 40 ? '📚' : '💪';

    return Expanded(
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: AppColors.shadowPurple, blurRadius: 16, offset: const Offset(0, 6))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 60)),
              const SizedBox(height: 16),
              Text('Quiz Complete!',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textMain)),
              const SizedBox(height: 10),
              Text(
                '$_score / ${_questions.length} correct ($pct%)',
                style: const TextStyle(fontSize: 16, color: AppColors.primary, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                pct >= 80 ? 'Excellent work! 🌟' : pct >= 60 ? 'Good job! Keep revising 📖' : 'Keep practicing, you\'ll get there! 💪',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted, fontSize: 13.5),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _startQuiz(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
