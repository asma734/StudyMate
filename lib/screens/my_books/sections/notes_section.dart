// ══════════════════════════════════════════════════════════════
// NotesSectionWidget — StudyMate AI Companion
// Reusable section widget used inside BookDetailScreen tabs.
// Displays notes list for a given subject + section.
// ══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/note_model.dart';
import '../../../models/subject_model.dart';
import '../../../providers/books_provider.dart';

class NotesSectionWidget extends StatelessWidget {
  final SubjectModel subject;
  final NoteSection section;

  const NotesSectionWidget({
    super.key,
    required this.subject,
    required this.section,
  });

  @override
  Widget build(BuildContext context) {
    final booksProvider = context.watch<BooksProvider>();
    final notes = booksProvider.notesForSubject(subject.id, section: section);

    if (notes.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: notes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) => _NoteCard(note: notes[i], subject: subject),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _sectionEmoji(section),
              style: const TextStyle(fontSize: 56),
            ),
            const SizedBox(height: 20),
            Text(
              'No ${NoteModel.sectionLabel(section)} yet',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to add your first note in this section.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, fontSize: 13.5, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  String _sectionEmoji(NoteSection s) {
    switch (s) {
      case NoteSection.courseNotes: return '📖';
      case NoteSection.tp: return '🔬';
      case NoteSection.exercises: return '📝';
      case NoteSection.summaries: return '✨';
      case NoteSection.materials: return '📎';
      case NoteSection.classroomNotes: return '🏫';
      case NoteSection.projects: return '🚀';
      case NoteSection.overview: return '🗺️';
    }
  }
}

// ── Note Card ──────────────────────────────────────────────────
class _NoteCard extends StatelessWidget {
  final NoteModel note;
  final SubjectModel subject;

  const _NoteCard({required this.note, required this.subject});

  @override
  Widget build(BuildContext context) {
    final booksProvider = context.read<BooksProvider>();

    return Dismissible(
      key: Key(note.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 26),
      ),
      onDismissed: (_) => booksProvider.deleteNote(note.id),
      child: GestureDetector(
        onTap: () => _showNoteDetail(context),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: AppColors.shadowPurple, blurRadius: 8, offset: const Offset(0, 3)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => booksProvider.togglePin(note.id),
                    child: Icon(
                      note.isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                      color: note.isPinned ? AppColors.primary : AppColors.textLight,
                      size: 18,
                    ),
                  ),
                ],
              ),
              if (note.content.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  note.content,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12.5, height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.access_time_rounded, size: 12, color: AppColors.textLight),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(note.updatedAt),
                    style: TextStyle(color: AppColors.textLight, fontSize: 11),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      NoteModel.sectionLabel(note.section).split(' ')[0],
                      style: const TextStyle(color: AppColors.primary, fontSize: 10.5, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  void _showNoteDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NoteDetailSheet(note: note),
    );
  }
}

// ── Note Detail Sheet ──────────────────────────────────────────
class _NoteDetailSheet extends StatelessWidget {
  final NoteModel note;
  const _NoteDetailSheet({required this.note});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.borderLight, borderRadius: BorderRadius.circular(2)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    note.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textMain),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    NoteModel.sectionLabel(note.section),
                    style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 24, indent: 24, endIndent: 24),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Text(
                note.content.isEmpty ? '_No content yet._' : note.content,
                style: TextStyle(
                  color: note.content.isEmpty ? AppColors.textLight : AppColors.textMain,
                  fontSize: 14,
                  height: 1.65,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
