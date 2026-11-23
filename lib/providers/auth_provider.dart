
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isLoading = true;
  String? _errorMessage;

  // Getters
  UserModel? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get hasCompletedOnboarding =>
      _user?.hasCompletedOnboarding ?? false;

  // Constructor
  AuthProvider() {
    _checkInitialSession();
  }

  // Update loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Check existing session when app starts
  Future<void> _checkInitialSession() async {
    _setLoading(true);

    try {
      _user = await _authService.initializeSession();
      _errorMessage = null;

      debugPrint('Initial session loaded successfully');
      debugPrint('User: $_user');
    } catch (e) {
      _user = null;
      _errorMessage = e.toString();

      debugPrint('Session initialization error: $e');
    } finally {
      _isLoading = false;
      debugPrint('Initial loading: $_isLoading');
      notifyListeners();
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    _errorMessage = null;
    _setLoading(true);

    try {
      _user = await _authService.login(
        email: email,
        password: password,
      );

      debugPrint('Login successful: $_user');
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Login error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register
  Future<bool> register(
      String name,
      String email,
      String password,
      ) async {
    _errorMessage = null;
    _setLoading(true);

    try {
      _user = await _authService.register(
        name: name,
        email: email,
        password: password,
      );

      debugPrint('Registration successful: $_user');
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Registration error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Complete onboarding
  Future<bool> completeOnboarding({
    required String university,
    required String degree,
    required String academicLevel,
    required String semester,
    required List<Map<String, dynamic>> subjects,
    List<Map<String, dynamic>>? timetable,
  }) async {
    _errorMessage = null;
    _setLoading(true);

    try {
      _user = await _authService.saveOnboarding(
        university: university,
        degree: degree,
        academicLevel: academicLevel,
        semester: semester,
        subjects: subjects,
        timetable: timetable,
      );

      debugPrint('Onboarding completed successfully');
      debugPrint('Updated user: $_user');

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Onboarding error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      _setLoading(true);

      await _authService.logout();

      _user = null;
      _errorMessage = null;

      debugPrint('Logout successful');
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Logout error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
