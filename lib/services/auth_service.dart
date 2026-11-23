import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _userKey = 'current_user_profile';
  static const String _tokenKey = 'auth_session_token';

  // Current session cache
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  // Initialize and check existing persistent session
  Future<UserModel?> initializeSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final userJson = prefs.getString(_userKey);

    if (token != null && userJson != null) {
      try {
        final Map<String, dynamic> data = jsonDecode(userJson);
        _currentUser = UserModel.fromMap(data, data['id'] ?? 'user_1');
        return _currentUser;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Register with Email and Password
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    // In production with Firebase:
    // UserCredential cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(...);
    await Future.delayed(const Duration(milliseconds: 600));

    final newUser = UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      hasCompletedOnboarding: false,
    );

    await _persistSession(newUser, 'mock_token_${newUser.id}');
    _currentUser = newUser;
    return newUser;
  }

  // Login with Email and Password
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    // In production with Firebase:
    // UserCredential cred = await FirebaseAuth.instance.signInWithEmailAndPassword(...);
    await Future.delayed(const Duration(milliseconds: 600));

    final loggedUser = UserModel(
      id: 'usr_default',
      name: email.split('@').first.capitalize(),
      email: email,
      hasCompletedOnboarding: true,
    );

    await _persistSession(loggedUser, 'mock_token_${loggedUser.id}');
    _currentUser = loggedUser;
    return loggedUser;
  }

  // Save Onboarding Data
  Future<UserModel> saveOnboarding({
    required String university,
    required String degree,
    required String academicLevel,
    required String semester,
    required List<Map<String, dynamic>> subjects,
    List<Map<String, dynamic>>? timetable,
  }) async {
    if (_currentUser == null) {
      throw Exception('No active user session');
    }

    final prefs = await SharedPreferences.getInstance();

    // Persist subjects as SubjectModel so BooksProvider immediately sees them!
    if (subjects.isNotEmpty) {
      final List<String> subjectsJson = subjects.map((s) {
        final id = s['id'] ?? 'sub_${DateTime.now().millisecondsSinceEpoch}_${s['name'].hashCode}';
        final map = {
          'id': id,
          'name': s['name'] ?? '',
          'coefficient': (s['coeff'] ?? s['coefficient'] ?? 3.0).toDouble(),
          'description': s['description'] ?? '',
          'colorHex': s['color'] ?? s['colorHex'] ?? '#B8A7EA',
          'iconName': s['iconName'] ?? 'book',
          'weeklySchedule': s['weeklySchedule'] ?? '',
          'estimatedDifficulty': s['difficulty'] ?? 3,
          'progressPercentage': 0.0,
          'savedNotesCount': 0,
        };
        return jsonEncode(map);
      }).toList();
      await prefs.setStringList('sm_subjects', subjectsJson);
    }

    // Persist timetable
    if (timetable != null && timetable.isNotEmpty) {
      await prefs.setString('sm_timetable', jsonEncode(timetable));
    }

    final updated = _currentUser!.copyWith(
      university: university,
      degree: degree,
      academicLevel: academicLevel,
      semester: semester,
      hasCompletedOnboarding: true,
    );

    await _persistSession(updated, 'mock_token_${updated.id}');
    _currentUser = updated;
    return updated;
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_tokenKey);
    _currentUser = null;
  }

  // Helper to persist user to SharedPreferences
  Future<void> _persistSession(UserModel user, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user.toMap()));
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return '';
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
