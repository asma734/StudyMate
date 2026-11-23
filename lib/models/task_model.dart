// ══════════════════════════════════════════════════════════════
// TaskModel — StudyMate AI Companion
// Represents a student academic task with smart priority score.
// Priority Score = (C×0.35) + (U×0.35) + (D×0.20) + (E×0.10)
//   C = Coefficient importance (1-5)
//   U = Urgency based on deadline proximity (1-5)
//   D = Difficulty (1-5)
//   E = Effort already invested (1-5, reversed)
// ══════════════════════════════════════════════════════════════

enum TaskStatus { todo, inProgress, done }

enum TaskType { homework, revision, project, exam, tp, lab, reading, other }

class TaskModel {
  final String id;
  final String title;
  final String description;
  final String subjectId;
  final String subjectName;
  final String subjectColorHex;
  final DateTime deadline;
  final TaskStatus status;
  final TaskType type;

  // Priority scoring inputs
  final int coefficientImportance; // 1-5
  final int urgency; // 1-5 (computed from deadline, can be overridden)
  final int difficulty; // 1-5
  final int effortInvested; // 1-5

  final DateTime createdAt;

  TaskModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.subjectId,
    required this.subjectName,
    this.subjectColorHex = '#B8A7EA',
    required this.deadline,
    this.status = TaskStatus.todo,
    this.type = TaskType.homework,
    this.coefficientImportance = 3,
    this.urgency = 3,
    this.difficulty = 3,
    this.effortInvested = 1,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Computed priority score (higher = more urgent to do)
  double get priorityScore {
    return (coefficientImportance * 0.35) +
        (urgency * 0.35) +
        (difficulty * 0.20) +
        ((6 - effortInvested) * 0.10); // reversed: less effort done = higher priority
  }

  // Auto-compute urgency from deadline (days remaining)
  static int computeUrgency(DateTime deadline) {
    final daysLeft = deadline.difference(DateTime.now()).inDays;
    if (daysLeft <= 1) return 5;
    if (daysLeft <= 3) return 4;
    if (daysLeft <= 7) return 3;
    if (daysLeft <= 14) return 2;
    return 1;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'subjectId': subjectId,
      'subjectName': subjectName,
      'subjectColorHex': subjectColorHex,
      'deadline': deadline.toIso8601String(),
      'status': status.name,
      'type': type.name,
      'coefficientImportance': coefficientImportance,
      'urgency': urgency,
      'difficulty': difficulty,
      'effortInvested': effortInvested,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map, String docId) {
    return TaskModel(
      id: docId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      subjectId: map['subjectId'] ?? '',
      subjectName: map['subjectName'] ?? '',
      subjectColorHex: map['subjectColorHex'] ?? '#B8A7EA',
      deadline: DateTime.parse(map['deadline'] ?? DateTime.now().toIso8601String()),
      status: TaskStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => TaskStatus.todo,
      ),
      type: TaskType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => TaskType.homework,
      ),
      coefficientImportance: map['coefficientImportance'] ?? 3,
      urgency: map['urgency'] ?? 3,
      difficulty: map['difficulty'] ?? 3,
      effortInvested: map['effortInvested'] ?? 1,
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  TaskModel copyWith({
    String? title,
    String? description,
    String? subjectId,
    String? subjectName,
    String? subjectColorHex,
    DateTime? deadline,
    TaskStatus? status,
    TaskType? type,
    int? coefficientImportance,
    int? urgency,
    int? difficulty,
    int? effortInvested,
  }) {
    return TaskModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      subjectColorHex: subjectColorHex ?? this.subjectColorHex,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      type: type ?? this.type,
      coefficientImportance: coefficientImportance ?? this.coefficientImportance,
      urgency: urgency ?? this.urgency,
      difficulty: difficulty ?? this.difficulty,
      effortInvested: effortInvested ?? this.effortInvested,
      createdAt: createdAt,
    );
  }
}
