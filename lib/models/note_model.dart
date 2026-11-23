// ══════════════════════════════════════════════════════════════
// NoteModel — StudyMate AI Companion
// Represents digital notebook notes, rich text, embedded images,
// and PDF course documents with integrated viewer support.
// ══════════════════════════════════════════════════════════════

enum NoteSection {
  courseNotes,    // Notes de cours (CM)
  materials,      // Supports de cours & PDFs
  classroomNotes, // Notes de classe / TD
  tp,             // Travaux Pratiques
  exercises,      // Exercices & Révision (PDFs énoncés & corrigés)
  summaries,      // Résumés personnels
  projects,       // Projets académiques
  overview,       // Vue d'ensemble du Book
}

enum PaperStyle {
  lined, // Lignes de cahier
  grid,  // Petits carreaux
  blank, // Feuille blanche
}

class NoteModel {
  final String id;
  final String subjectId;
  final String title;
  final String content; // Markdown or rich formatted text
  final String chapter;
  final NoteSection section;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPinned;

  // 📓 Real Notebook Styling properties
  final PaperStyle paperStyle;
  final String textColor;      // e.g. '#2D3436' (Black ink), '#6C5CE7' (Lavender)
  final String? highlightColor; // e.g. '#FFF59D' (Yellow), '#E1BEE7' (Lavender)
  final List<String> images;   // Embedded diagram/image URLs

  // 📕 PDF Document Attachment & Reader properties
  final String? fileName;
  final String? fileUrl;
  final String? fileSize;
  final String? fileType; // 'pdf', 'doc', 'link', 'code'
  final int pdfPageCount;

  bool get isPdf =>
      fileType == 'pdf' || (fileName != null && fileName!.toLowerCase().endsWith('.pdf'));

  NoteModel({
    required this.id,
    required this.subjectId,
    required this.title,
    this.content = '',
    this.chapter = 'Chapter 1',
    this.section = NoteSection.courseNotes,
    this.tags = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isPinned = false,
    this.paperStyle = PaperStyle.lined,
    this.textColor = '#2D3436',
    this.highlightColor,
    this.images = const [],
    this.fileName,
    this.fileUrl,
    this.fileSize,
    this.fileType,
    this.pdfPageCount = 12,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subjectId': subjectId,
      'title': title,
      'content': content,
      'chapter': chapter,
      'section': section.name,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isPinned': isPinned,
      'paperStyle': paperStyle.name,
      'textColor': textColor,
      'highlightColor': highlightColor,
      'images': images,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'fileSize': fileSize,
      'fileType': fileType,
      'pdfPageCount': pdfPageCount,
    };
  }

  factory NoteModel.fromMap(Map<String, dynamic> map, String docId) {
    return NoteModel(
      id: docId,
      subjectId: map['subjectId'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      chapter: map['chapter'] ?? 'Chapter 1',
      section: NoteSection.values.firstWhere(
        (s) => s.name == map['section'],
        orElse: () => NoteSection.courseNotes,
      ),
      tags: List<String>.from(map['tags'] ?? []),
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
      isPinned: map['isPinned'] ?? false,
      paperStyle: PaperStyle.values.firstWhere(
        (p) => p.name == map['paperStyle'],
        orElse: () => PaperStyle.lined,
      ),
      textColor: map['textColor'] ?? '#2D3436',
      highlightColor: map['highlightColor'],
      images: List<String>.from(map['images'] ?? []),
      fileName: map['fileName'],
      fileUrl: map['fileUrl'],
      fileSize: map['fileSize'],
      fileType: map['fileType'],
      pdfPageCount: map['pdfPageCount'] ?? 12,
    );
  }

  NoteModel copyWith({
    String? title,
    String? content,
    String? chapter,
    NoteSection? section,
    List<String>? tags,
    bool? isPinned,
    PaperStyle? paperStyle,
    String? textColor,
    String? highlightColor,
    List<String>? images,
    String? fileName,
    String? fileUrl,
    String? fileSize,
    String? fileType,
    int? pdfPageCount,
  }) {
    return NoteModel(
      id: id,
      subjectId: subjectId,
      title: title ?? this.title,
      content: content ?? this.content,
      chapter: chapter ?? this.chapter,
      section: section ?? this.section,
      tags: tags ?? this.tags,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      isPinned: isPinned ?? this.isPinned,
      paperStyle: paperStyle ?? this.paperStyle,
      textColor: textColor ?? this.textColor,
      highlightColor: highlightColor ?? this.highlightColor,
      images: images ?? this.images,
      fileName: fileName ?? this.fileName,
      fileUrl: fileUrl ?? this.fileUrl,
      fileSize: fileSize ?? this.fileSize,
      fileType: fileType ?? this.fileType,
      pdfPageCount: pdfPageCount ?? this.pdfPageCount,
    );
  }

  static String sectionLabel(NoteSection section) {
    switch (section) {
      case NoteSection.courseNotes:
        return 'Course Notes';
      case NoteSection.materials:
        return 'Course Materials & PDFs';
      case NoteSection.classroomNotes:
        return 'Classroom Notes';
      case NoteSection.tp:
        return 'Practical Work (TP)';
      case NoteSection.exercises:
        return 'Exercises & Revision';
      case NoteSection.summaries:
        return 'Personal Summaries';
      case NoteSection.projects:
        return 'Academic Projects';
      case NoteSection.overview:
        return 'Book Overview';
    }
  }
}
