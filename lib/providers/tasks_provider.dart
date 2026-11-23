// ══════════════════════════════════════════════════════════════
// TasksProvider — StudyMate AI Companion
// Manages tasks with smart priority sorting.
// ══════════════════════════════════════════════════════════════

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';

class TasksProvider with ChangeNotifier {
  List<TaskModel> _tasks = [];
  bool _isLoading = false;

  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;

  // Filtered getters
  List<TaskModel> get todoTasks =>
      _tasks.where((t) => t.status == TaskStatus.todo).toList()
        ..sort((a, b) => b.priorityScore.compareTo(a.priorityScore));

  List<TaskModel> get inProgressTasks =>
      _tasks.where((t) => t.status == TaskStatus.inProgress).toList()
        ..sort((a, b) => b.priorityScore.compareTo(a.priorityScore));

  List<TaskModel> get doneTasks =>
      _tasks.where((t) => t.status == TaskStatus.done).toList()
        ..sort((a, b) => b.deadline.compareTo(a.deadline));

  List<TaskModel> get allSorted =>
      List<TaskModel>.from(_tasks)
        ..sort((a, b) => b.priorityScore.compareTo(a.priorityScore));

  int get overdueCount => _tasks
      .where((t) =>
          t.status != TaskStatus.done &&
          t.deadline.isBefore(DateTime.now()))
      .length;

  int get dueTodayCount => _tasks
      .where((t) =>
          t.status != TaskStatus.done &&
          t.deadline.difference(DateTime.now()).inDays == 0)
      .length;

  // ── LOAD ──────────────────────────────────────────────────
  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getStringList('sm_tasks') ?? [];
    _tasks = tasksJson
        .map((t) => TaskModel.fromMap(json.decode(t), json.decode(t)['id'] ?? ''))
        .toList();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'sm_tasks',
      _tasks.map((t) => json.encode(t.toMap())).toList(),
    );
  }

  // ── CRUD ──────────────────────────────────────────────────
  Future<void> addTask(TaskModel task) async {
    _tasks.add(task);
    await _save();
    notifyListeners();
  }

  Future<void> updateTask(TaskModel updated) async {
    final idx = _tasks.indexWhere((t) => t.id == updated.id);
    if (idx != -1) {
      _tasks[idx] = updated;
      await _save();
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((t) => t.id == taskId);
    await _save();
    notifyListeners();
  }

  Future<void> markStatus(String taskId, TaskStatus status) async {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      _tasks[idx] = _tasks[idx].copyWith(status: status);
      await _save();
      notifyListeners();
    }
  }
}
