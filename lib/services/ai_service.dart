// ══════════════════════════════════════════════════════════════
// AiService — StudyMate AI Companion
// Communicates with Gemini API for the AI Tutor and quiz features.
// API key stored securely (env variable / flutter_dotenv in production).
// ══════════════════════════════════════════════════════════════

import 'dart:convert';
import 'package:http/http.dart' as http;

class AiService {
  // ⚠️ Replace with your Gemini API key (or load from .env in production)
  static const String _apiKey = 'YOUR_GEMINI_API_KEY';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  // ── CHAT (AI Tutor) ───────────────────────────────────────
  Future<String> chat({
    required String userMessage,
    required String subjectContext,
    required List<Map<String, String>> history,
  }) async {
    final systemPrompt = '''
You are StudyMate, an intelligent academic assistant for a Licence 3 Computer Science student in Algeria.
You are helping the student understand and revise their course: "$subjectContext".
Respond in the same language the student uses (French, English, or Arabic/Darija).
Be concise, educational, and encouraging. Use emojis sparingly.
If the student shares a note or extract, analyze it and answer questions about it.
Never invent exam dates, grades or institutional information.
''';

    final contents = [
      {
        'role': 'user',
        'parts': [{'text': systemPrompt}]
      },
      ...history.map((h) => {
        'role': h['role']!,
        'parts': [{'text': h['content']!}]
      }),
      {
        'role': 'user',
        'parts': [{'text': userMessage}]
      }
    ];

    return _generate(contents);
  }

  // ── QUIZ GENERATION ───────────────────────────────────────
  Future<List<QuizQuestion>> generateQuiz({
    required String subjectName,
    required String noteContent,
    int questionCount = 5,
  }) async {
    final prompt = '''
Based on the following course notes about "$subjectName", generate $questionCount multiple-choice questions (QCM).
Respond ONLY with a valid JSON array in this format:
[
  {
    "question": "What is ...?",
    "options": ["A) ...", "B) ...", "C) ...", "D) ..."],
    "correctIndex": 0,
    "explanation": "Because ..."
  }
]

Course notes:
$noteContent
''';

    final contents = [
      {
        'role': 'user',
        'parts': [{'text': prompt}]
      }
    ];

    final raw = await _generate(contents);

    // Parse JSON from the response
    try {
      final jsonStr = raw.substring(
        raw.indexOf('['),
        raw.lastIndexOf(']') + 1,
      );
      final list = json.decode(jsonStr) as List;
      return list.map((q) => QuizQuestion.fromMap(q)).toList();
    } catch (_) {
      // If parsing fails, return a demo question
      return [
        QuizQuestion(
          question: 'Could not generate quiz. Please try again with more detailed notes.',
          options: ['OK'],
          correctIndex: 0,
          explanation: raw,
        )
      ];
    }
  }

  // ── SUMMARIZE NOTE ────────────────────────────────────────
  Future<String> summarize(String noteContent) async {
    final prompt =
        'Summarize the following academic note in bullet points (max 10 bullets). Be concise and clear:\n\n$noteContent';
    final contents = [
      {
        'role': 'user',
        'parts': [{'text': prompt}]
      }
    ];
    return _generate(contents);
  }

  // ── INTERNAL HTTP CALL ────────────────────────────────────
  Future<String> _generate(List<Map<String, dynamic>> contents) async {
    if (_apiKey == 'YOUR_GEMINI_API_KEY') {
      // Demo mode — return mock response
      await Future.delayed(const Duration(milliseconds: 800));
      return _mockResponse(contents.last['parts'][0]['text'] as String);
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'contents': contents}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'] as String;
      } else {
        return 'Error ${response.statusCode}: ${response.body}';
      }
    } catch (e) {
      return 'Connection error: $e\n\nPlease check your internet connection.';
    }
  }

  String _mockResponse(String input) {
    if (input.toLowerCase().contains('quiz') || input.toLowerCase().contains('qcm')) {
      return '''[
  {"question":"What does OOP stand for?","options":["A) Object-Oriented Programming","B) Open Object Protocol","C) Optional Operation Pattern","D) Object Output Program"],"correctIndex":0,"explanation":"OOP stands for Object-Oriented Programming, a paradigm based on objects."},
  {"question":"Which keyword defines a class in Java?","options":["A) define","B) struct","C) class","D) object"],"correctIndex":2,"explanation":"The 'class' keyword is used to define a class in Java."}
]''';
    }
    return '👋 I\'m StudyMate AI! To activate full AI capabilities, please add your Gemini API key in `lib/services/ai_service.dart`.\n\nFor now, I\'m running in demo mode. I can still help you organize your notes and generate mock quizzes!\n\nYou said: *"$input"*';
  }
}

// ── Quiz Model ────────────────────────────────────────────────
class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      question: map['question'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctIndex: map['correctIndex'] ?? 0,
      explanation: map['explanation'] ?? '',
    );
  }
}
