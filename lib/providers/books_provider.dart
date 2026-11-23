// ══════════════════════════════════════════════════════════════
// BooksProvider — StudyMate AI Companion
// Manages subject books and notes with local SharedPreferences storage.
// Firebase-compatible architecture (swap storage layer for Firestore).
// ══════════════════════════════════════════════════════════════

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/subject_model.dart';
import '../models/note_model.dart';

class BooksProvider with ChangeNotifier {
  List<SubjectModel> _subjects = [];
  List<NoteModel> _notes = [];
  bool _isLoading = false;

  List<SubjectModel> get subjects => _subjects;
  List<NoteModel> get notes => _notes;
  bool get isLoading => _isLoading;

  // Notes filtered by subject and optionally by section
  List<NoteModel> notesForSubject(String subjectId, {NoteSection? section}) {
    return _notes.where((n) {
      final matchSubject = n.subjectId == subjectId;
      final matchSection = section == null || n.section == section;
      return matchSubject && matchSection;
    }).toList()
      ..sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return b.updatedAt.compareTo(a.updatedAt);
      });
  }

  // ── LOAD ──────────────────────────────────────────────────
  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();

    // Load subjects
    final subjectsJson = prefs.getStringList('sm_subjects') ?? [];
    _subjects = subjectsJson
        .map((s) => SubjectModel.fromMap(json.decode(s), json.decode(s)['id'] ?? ''))
        .toList();

    // Load notes
    final notesJson = prefs.getStringList('sm_notes') ?? [];
    _notes = notesJson
        .map((n) => NoteModel.fromMap(json.decode(n), json.decode(n)['id'] ?? ''))
        .toList();

    _isLoading = false;
    notifyListeners();
  }

  // ── SAVE ──────────────────────────────────────────────────
  Future<void> _saveSubjects() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'sm_subjects',
      _subjects.map((s) => json.encode(s.toMap())).toList(),
    );
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'sm_notes',
      _notes.map((n) => json.encode(n.toMap())).toList(),
    );
  }

  // ── SUBJECTS ─────────────────────────────────────────────
  Future<void> addSubject(SubjectModel subject) async {
    _subjects.add(subject);
    await _saveSubjects();
    notifyListeners();
  }

  Future<void> updateSubject(SubjectModel updated) async {
    final idx = _subjects.indexWhere((s) => s.id == updated.id);
    if (idx != -1) {
      _subjects[idx] = updated;
      await _saveSubjects();
      notifyListeners();
    }
  }

  Future<void> deleteSubject(String subjectId) async {
    _subjects.removeWhere((s) => s.id == subjectId);
    _notes.removeWhere((n) => n.subjectId == subjectId);
    await _saveSubjects();
    await _saveNotes();
    notifyListeners();
  }

  SubjectModel? subjectById(String id) {
    try {
      return _subjects.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  // ── NOTES ─────────────────────────────────────────────────
  Future<void> addNote(NoteModel note) async {
    _notes.add(note);
    // Update savedNotesCount on the subject
    final subject = subjectById(note.subjectId);
    if (subject != null) {
      final count = notesForSubject(note.subjectId).length;
      await updateSubject(SubjectModel(
        id: subject.id,
        name: subject.name,
        coefficient: subject.coefficient,
        description: subject.description,
        colorHex: subject.colorHex,
        iconName: subject.iconName,
        weeklySchedule: subject.weeklySchedule,
        estimatedDifficulty: subject.estimatedDifficulty,
        progressPercentage: subject.progressPercentage,
        savedNotesCount: count,
      ));
    }
    await _saveNotes();
    notifyListeners();
  }

  Future<void> updateNote(NoteModel updated) async {
    final idx = _notes.indexWhere((n) => n.id == updated.id);
    if (idx != -1) {
      _notes[idx] = updated;
      await _saveNotes();
      notifyListeners();
    }
  }

  Future<void> deleteNote(String noteId) async {
    _notes.removeWhere((n) => n.id == noteId);
    await _saveNotes();
    notifyListeners();
  }

  Future<void> togglePin(String noteId) async {
    final idx = _notes.indexWhere((n) => n.id == noteId);
    if (idx != -1) {
      _notes[idx] = _notes[idx].copyWith(isPinned: !_notes[idx].isPinned);
      await _saveNotes();
      notifyListeners();
    }
  }
}
