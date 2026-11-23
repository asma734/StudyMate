class UserModel {
  final String id;
  final String name;
  final String email;
  final String university;
  final String academicLevel;
  final String degree;
  final String fieldOfStudy;
  final String semester;
  final String? avatarUrl;
  final bool hasCompletedOnboarding;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.university = 'Faculty of Sciences',
    this.academicLevel = 'Licence 3',
    this.degree = 'Computer Science',
    this.fieldOfStudy = 'Distributed Systems & Mobile Dev',
    this.semester = 'Semester 5',
    this.avatarUrl,
    this.hasCompletedOnboarding = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'university': university,
      'academicLevel': academicLevel,
      'degree': degree,
      'fieldOfStudy': fieldOfStudy,
      'semester': semester,
      'avatarUrl': avatarUrl,
      'hasCompletedOnboarding': hasCompletedOnboarding,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String docId) {
    return UserModel(
      id: docId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      university: map['university'] ?? '',
      academicLevel: map['academicLevel'] ?? '',
      degree: map['degree'] ?? '',
      fieldOfStudy: map['fieldOfStudy'] ?? '',
      semester: map['semester'] ?? '',
      avatarUrl: map['avatarUrl'],
      hasCompletedOnboarding: map['hasCompletedOnboarding'] ?? false,
    );
  }

  UserModel copyWith({
    String? name,
    String? university,
    String? academicLevel,
    String? degree,
    String? fieldOfStudy,
    String? semester,
    String? avatarUrl,
    bool? hasCompletedOnboarding,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email,
      university: university ?? this.university,
      academicLevel: academicLevel ?? this.academicLevel,
      degree: degree ?? this.degree,
      fieldOfStudy: fieldOfStudy ?? this.fieldOfStudy,
      semester: semester ?? this.semester,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }
}
