class SubjectModel {
  final String id;
  final String name;
  final double coefficient;
  final String description;
  final String colorHex;
  final String iconName;
  final String weeklySchedule;
  final int estimatedDifficulty; // 1 (Easy) to 5 (Hard)
  final double progressPercentage; // 0.0 to 100.0
  final int savedNotesCount;
  final String semester;
  final String professorName;
  final int tpsCount;
  final int completedTpsCount;
  final int materialsCount;

  SubjectModel({
    required this.id,
    required this.name,
    this.coefficient = 3.0,
    this.description = '',
    this.colorHex = '#B8A7EA',
    this.iconName = 'book',
    this.weeklySchedule = 'Mon 08:30 - 11:30',
    this.estimatedDifficulty = 3,
    this.progressPercentage = 65.0,
    this.savedNotesCount = 0,
    this.semester = 'Semester 5',
    this.professorName = '',
    this.tpsCount = 0,
    this.completedTpsCount = 0,
    this.materialsCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'coefficient': coefficient,
      'description': description,
      'colorHex': colorHex,
      'iconName': iconName,
      'weeklySchedule': weeklySchedule,
      'estimatedDifficulty': estimatedDifficulty,
      'progressPercentage': progressPercentage,
      'savedNotesCount': savedNotesCount,
      'semester': semester,
      'professorName': professorName,
      'tpsCount': tpsCount,
      'completedTpsCount': completedTpsCount,
      'materialsCount': materialsCount,
    };
  }

  factory SubjectModel.fromMap(Map<String, dynamic> map, String docId) {
    return SubjectModel(
      id: docId,
      name: map['name'] ?? '',
      coefficient: (map['coefficient'] ?? 3.0).toDouble(),
      description: map['description'] ?? '',
      colorHex: map['colorHex'] ?? '#B8A7EA',
      iconName: map['iconName'] ?? 'book',
      weeklySchedule: map['weeklySchedule'] ?? '',
      estimatedDifficulty: map['estimatedDifficulty'] ?? 3,
      progressPercentage: (map['progressPercentage'] ?? 65.0).toDouble(),
      savedNotesCount: map['savedNotesCount'] ?? 0,
      semester: map['semester'] ?? 'Semester 5',
      professorName: map['professorName'] ?? '',
      tpsCount: map['tpsCount'] ?? 0,
      completedTpsCount: map['completedTpsCount'] ?? 0,
      materialsCount: map['materialsCount'] ?? 0,
    );
  }

  SubjectModel copyWith({
    String? name,
    double? coefficient,
    String? description,
    String? colorHex,
    String? iconName,
    String? weeklySchedule,
    int? estimatedDifficulty,
    double? progressPercentage,
    int? savedNotesCount,
    String? semester,
    String? professorName,
    int? tpsCount,
    int? completedTpsCount,
    int? materialsCount,
  }) {
    return SubjectModel(
      id: id,
      name: name ?? this.name,
      coefficient: coefficient ?? this.coefficient,
      description: description ?? this.description,
      colorHex: colorHex ?? this.colorHex,
      iconName: iconName ?? this.iconName,
      weeklySchedule: weeklySchedule ?? this.weeklySchedule,
      estimatedDifficulty: estimatedDifficulty ?? this.estimatedDifficulty,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      savedNotesCount: savedNotesCount ?? this.savedNotesCount,
      semester: semester ?? this.semester,
      professorName: professorName ?? this.professorName,
      tpsCount: tpsCount ?? this.tpsCount,
      completedTpsCount: completedTpsCount ?? this.completedTpsCount,
      materialsCount: materialsCount ?? this.materialsCount,
    );
  }
}
