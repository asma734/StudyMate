// ══════════════════════════════════════════════════════════════
// BookDetailScreen — StudyMate AI Companion
// Spacious, Comfortable Subject Workspace with:
// 1. Digital Student Notebook (Full-Page Writing & Reading)
// 2. Edit & Re-open saved notes
// 3. Integrated PDF Reader & Importer for course materials
// ══════════════════════════════════════════════════════════════

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/subject_model.dart';
import '../../models/note_model.dart';
import '../../providers/books_provider.dart';
import '../../widgets/app_header.dart';
import '../ai_tutor/ai_tutor_screen.dart';
import 'notebook_editor_screen.dart';
import 'notebook_reader_screen.dart';
import 'pdf_viewer_screen.dart';

class BookDetailScreen extends StatefulWidget {
  final SubjectModel subject;

  const BookDetailScreen({super.key, required this.subject});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  NoteSection _activeTab = NoteSection.courseNotes;

  // Integrated PDF Viewer state
  NoteModel? _viewingPdfDoc;
  int _pdfCurrentPage = 1;
  double _pdfZoom = 1.0;

  static const List<(NoteSection, String, IconData)> _tabs = [
    (NoteSection.courseNotes, 'Course Notes', Icons.description_outlined),
    (NoteSection.materials, 'Course Materials & PDFs', Icons.folder_open_rounded),
    (NoteSection.classroomNotes, 'Classroom Notes', Icons.edit_note_rounded),
    (NoteSection.tp, 'Practical Work (TP)', Icons.terminal_rounded),
    (NoteSection.exercises, 'Exercises & Revision', Icons.help_outline_rounded),
    (NoteSection.summaries, 'Personal Summaries', Icons.bookmark_border_rounded),
    (NoteSection.projects, 'Academic Projects', Icons.layers_outlined),
    (NoteSection.overview, 'Book Overview', Icons.bar_chart_rounded),
  ];

  void _openFullPageEditor([NoteModel? note]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NotebookEditorScreen(subject: widget.subject, existingNote: note),
      ),
    );
  }

  Future<void> _pickAndAddPdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;
        final rawTitle = file.name.replaceAll(RegExp(r'\.pdf$', caseSensitive: false), '');
        final bytes = file.size;
        final sizeStr = bytes > 1024 * 1024
            ? '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB'
            : '${(bytes / 1024).toStringAsFixed(0)} KB';

        String? fileUrl;
        if (file.bytes != null) {
          final base64Data = base64Encode(file.bytes!);
          fileUrl = 'data:application/pdf;base64,$base64Data';
        }

        final newDoc = NoteModel(
          id: 'pdf_${DateTime.now().millisecondsSinceEpoch}',
          subjectId: widget.subject.id,
          title: rawTitle,
          chapter: 'Chapitre 1',
          content: 'Support de cours officiel importé depuis votre PC (${file.name}). Prêt pour consultation et révision.',
          section: _activeTab,
          fileName: file.name,
          fileUrl: fileUrl,
          fileSize: sizeStr,
          fileType: 'pdf',
          pdfPageCount: (bytes ~/ (100 * 1024)).clamp(1, 48),
        );

        if (mounted) {
          context.read<BooksProvider>().addNote(newDoc);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Document PDF importé depuis vos téléchargements : ${file.name} 📑'),
              backgroundColor: const Color(0xFF43A047),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error picking PDF: $e');
    }
  }

  void _showAddPdfDialog() {
    final titleCtrl = TextEditingController();
    final chapterCtrl = TextEditingController(text: 'Chapitre 1');
    final sizeCtrl = TextEditingController(text: '3.4 MB');
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Importer un Document PDF 📑', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 📂 Big Direct Button to pick from PC (Downloads)
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(dialogCtx);
                    _pickAndAddPdf();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B72DE),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 2,
                  ),
                  icon: const Icon(Icons.folder_open_rounded, color: Colors.white, size: 22),
                  label: const Text(
                    'Choisir un PDF depuis mon PC 📂\n(Téléchargements / Documents)',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13, height: 1.3),
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  children: const [
                    Expanded(child: Divider()),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text('OU SAISIR MANUELLEMENT', style: TextStyle(fontSize: 10.5, color: Colors.black38, fontWeight: FontWeight.bold))),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),

                const Text('Titre du document PDF :', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 6),
                TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(
                    hintText: 'ex: Polycopié_Cours_Complet.pdf',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Chapitre :', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: chapterCtrl,
                            decoration: InputDecoration(
                              hintText: 'Chapitre 1',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 110,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Taille :', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: sizeCtrl,
                            decoration: InputDecoration(
                              hintText: '3.4 MB',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text('Description ou résumé :', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 6),
                TextField(
                  controller: descCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Support officiel de cours distribué par le professeur...',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Annuler', style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              onPressed: () {
                final title = titleCtrl.text.trim();
                if (title.isEmpty) return;

                final newDoc = NoteModel(
                  id: 'pdf_${DateTime.now().millisecondsSinceEpoch}',
                  subjectId: widget.subject.id,
                  title: title,
                  chapter: chapterCtrl.text.trim().isEmpty ? 'Chapitre 1' : chapterCtrl.text.trim(),
                  content: descCtrl.text.trim(),
                  section: _activeTab,
                  fileName: title.toLowerCase().endsWith('.pdf') ? title : '$title.pdf',
                  fileSize: sizeCtrl.text.trim(),
                  fileType: 'pdf',
                  pdfPageCount: 18,
                );

                context.read<BooksProvider>().addNote(newDoc);
                Navigator.pop(dialogCtx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B72DE)),
              child: const Text('Ajouter 📑', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final booksProvider = context.watch<BooksProvider>();
    final notes = booksProvider.notesForSubject(widget.subject.id, section: _activeTab);
    final allSubjectNotes = booksProvider.notesForSubject(widget.subject.id);

    final isPdfSection = _activeTab == NoteSection.materials || _activeTab == NoteSection.exercises;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F5),
      body: Column(
        children: [
          // 🔝 Header
          AppHeader(
            title: widget.subject.name,
            subtitle: '${widget.subject.semester} • Prof: ${widget.subject.professorName.isEmpty ? "Enseignant" : widget.subject.professorName}',
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 🌸 Subject Banner with Back Button
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF5F1FD), Color(0xFFEFE8FA)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE7DEF7)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Row(
                                  children: const [
                                    Icon(Icons.arrow_back_rounded, size: 16, color: Color(0xFF8B72DE)),
                                    SizedBox(width: 6),
                                    Text(
                                      'Back to all Books',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF8B72DE),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                widget.subject.name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF332C3E),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.subject.description.isEmpty
                                    ? 'Espace de cours, notes manuscrites, supports PDF et révisions intelligentes.'
                                    : widget.subject.description,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF7E7092),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AiTutorScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B72DE),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 3,
                          ),
                          icon: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                          label: const Text(
                            'Ask Subject AI Tutor',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 📑 Horizontal 8 Tabs Row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _tabs.map((tab) {
                        final isSelected = _activeTab == tab.$1;
                        final count = allSubjectNotes.where((n) => n.section == tab.$1).length;

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _activeTab = tab.$1;
                                _viewingPdfDoc = null;
                              });
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF8B72DE) : const Color(0xFFEDE8F5),
                                  width: isSelected ? 1.5 : 1,
                                ),
                                boxShadow: isSelected
                                    ? const [
                                        BoxShadow(color: Color(0x0C000000), blurRadius: 8, offset: Offset(0, 3)),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    tab.$3,
                                    size: 16,
                                    color: isSelected ? const Color(0xFF8B72DE) : const Color(0xFF7E7092),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    tab.$2,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                      color: isSelected ? const Color(0xFF332C3E) : const Color(0xFF7E7092),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isSelected ? const Color(0xFFF3EFFF) : const Color(0xFFEDE8F5),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '$count',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: isSelected ? const Color(0xFF8B72DE) : Colors.black45,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 📑 IF VIEWING PDF: Show In-App Reader
                  if (_viewingPdfDoc != null) ...[
                    _buildIntegratedPdfViewer(),
                    const SizedBox(height: 24),
                  ],

                  // 📓 ACTION BAR: Clear, Spacious Call-to-Action
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.borderLight),
                      boxShadow: const [
                        BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              isPdfSection ? 'Documents & Polycopiés 📑' : 'Cahier de Cours 📓',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF332C3E)),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '(${notes.length} élément(s))',
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        if (isPdfSection)
                          ElevatedButton.icon(
                            onPressed: _showAddPdfDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8B72DE),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            icon: const Icon(Icons.upload_file_rounded, color: Colors.white, size: 18),
                            label: const Text('Importer un PDF 📤', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          )
                        else
                          ElevatedButton.icon(
                            onPressed: () => _openFullPageEditor(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8B72DE),
                              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            icon: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 20),
                            label: const Text('Ouvrir le Grand Cahier Plein Écran 📓', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5)),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 📚 Notes & PDF Documents Shelf (Full-Width Comfortable Cards)
                  if (notes.isEmpty)
                    _buildEmptyState(isPdfSection)
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: notes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, i) => _buildItemCard(notes[i], isPdfSection),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isPdfSection) {
    return Container(
      padding: const EdgeInsets.all(48),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Text(isPdfSection ? '📑' : '🌸', style: const TextStyle(fontSize: 44)),
          const SizedBox(height: 14),
          Text(
            isPdfSection ? 'Aucun document PDF pour le moment' : 'Aucune note dans cette section',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF332C3E)),
          ),
          const SizedBox(height: 6),
          Text(
            isPdfSection
                ? 'Cliquez sur "Importer un PDF" pour ajouter les polycopiés et fiches de cours.'
                : 'Cliquez sur "Ouvrir le Grand Cahier Plein Écran" pour commencer à rédiger vos cours avec mise en page Word et schémas.',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 📋 Full-Width Note / PDF Card
  Widget _buildItemCard(NoteModel item, bool isPdfSection) {
    final isPdf = item.isPdf;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: const [
          BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: isPdf ? const Color(0xFFFFEBEE) : const Color(0xFFF3EFFF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(isPdf ? '📕' : '📓', style: const TextStyle(fontSize: 24)),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3EFFF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.chapter,
                            style: const TextStyle(color: Color(0xFF8B72DE), fontSize: 11, fontWeight: FontWeight.w800),
                          ),
                        ),
                        if (isPdf && item.fileSize != null) ...[
                          const SizedBox(width: 8),
                          Text(item.fileSize!, style: const TextStyle(color: AppColors.textLight, fontSize: 11)),
                        ],
                        const Spacer(),
                        Text(
                          '${item.updatedAt.day}/${item.updatedAt.month}/${item.updatedAt.year}',
                          style: const TextStyle(color: Colors.black26, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.title,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Color(0xFF332C3E)),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (item.content.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              item.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13.5, color: Color(0xFF685D7B), height: 1.5),
            ),
          ],

          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF5F2FA)),
          const SizedBox(height: 12),

          // Actions row
          Row(
            children: [
              if (isPdf)
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PdfViewerScreen(
                          subject: widget.subject,
                          doc: item,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B72DE),
                    foregroundColor: Colors.white,
                    elevation: 1,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.auto_stories_rounded, size: 16, color: Colors.white),
                  label: const Text('Ouvrir dans le Lecteur PDF 📖', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                )
              else ...[
                // 📖 Read in Full Screen
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NotebookReaderScreen(subject: widget.subject, note: item),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B72DE),
                    foregroundColor: Colors.white,
                    elevation: 1,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.menu_book_rounded, size: 16, color: Colors.white),
                  label: const Text('Lire en Plein Écran 📖', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                ),
                const SizedBox(width: 10),

                // ✏️ Edit Note
                OutlinedButton.icon(
                  onPressed: () => _openFullPageEditor(item),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF8B72DE),
                    side: const BorderSide(color: Color(0xFFE4DBF5)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.edit_note_rounded, size: 16),
                  label: const Text('Modifier ✏️', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                ),
              ],

              const Spacer(),

              // Delete Note
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                onPressed: () => context.read<BooksProvider>().deleteNote(item.id),
                tooltip: 'Supprimer',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 📖 In-App PDF Reader
  Widget _buildIntegratedPdfViewer() {
    final doc = _viewingPdfDoc!;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C2F33),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Color(0x30000000), blurRadius: 24, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          // PDF Toolbar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF23272A),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
            ),
            child: Row(
              children: [
                const Icon(Icons.picture_as_pdf_rounded, color: Colors.redAccent, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    doc.fileName ?? doc.title,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.navigate_before_rounded, color: Colors.white70),
                  onPressed: _pdfCurrentPage > 1 ? () => setState(() => _pdfCurrentPage--) : null,
                ),
                Text(
                  'Page $_pdfCurrentPage / ${doc.pdfPageCount}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                ),
                IconButton(
                  icon: const Icon(Icons.navigate_next_rounded, color: Colors.white70),
                  onPressed: _pdfCurrentPage < doc.pdfPageCount ? () => setState(() => _pdfCurrentPage++) : null,
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.zoom_out_rounded, color: Colors.white70, size: 18),
                  onPressed: () => setState(() => _pdfZoom = (_pdfZoom - 0.1).clamp(0.8, 1.5)),
                ),
                IconButton(
                  icon: const Icon(Icons.zoom_in_rounded, color: Colors.white70, size: 18),
                  onPressed: () => setState(() => _pdfZoom = (_pdfZoom + 0.1).clamp(0.8, 1.5)),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                  onPressed: () => setState(() => _viewingPdfDoc = null),
                  tooltip: 'Fermer le lecteur',
                ),
              ],
            ),
          ),

          // Rendered Document Page
          Container(
            padding: const EdgeInsets.all(28),
            color: const Color(0xFF36393F),
            child: Center(
              child: Transform.scale(
                scale: _pdfZoom,
                child: Container(
                  width: 680,
                  padding: const EdgeInsets.all(36),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(color: Color(0x30000000), blurRadius: 16, offset: Offset(0, 6)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(widget.subject.name.toUpperCase(), style: const TextStyle(color: Colors.black45, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                          Text('${widget.subject.semester} • Support de Cours', style: const TextStyle(color: Colors.black45, fontSize: 10, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const Divider(height: 20),
                      Text(
                        '${doc.chapter} — ${doc.title}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1E272E)),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        doc.content.isEmpty
                            ? 'Ce document PDF constitue le polycopié officiel de cours.\n\nSection 1 — Objectifs fondamentaux :\n• Compréhension théorique approfondie des architectures et composants.\n• Modélisation des flux de données et cycles de vie.\n• Exercices d\'application et questions de révision pour préparer les examens.'
                            : doc.content,
                        style: const TextStyle(fontSize: 13, height: 1.65, color: Color(0xFF2F3542)),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F2F6),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFCED6E0)),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.schema_rounded, color: Color(0xFF57606F), size: 30),
                            SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                'Figure 1 : Schéma d\'architecture et modélisation des flux analysés dans ce document.',
                                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF57606F)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Page $_pdfCurrentPage', style: const TextStyle(fontSize: 11, color: Colors.black38, fontWeight: FontWeight.w700)),
                          const Text('Université • Faculté des Sciences', style: TextStyle(fontSize: 10, color: Colors.black38)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
