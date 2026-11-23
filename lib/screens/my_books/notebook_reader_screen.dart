// ══════════════════════════════════════════════════════════════
// NotebookReaderScreen — StudyMate AI Companion
// Full-Screen Comfortable Lecture Reader (Mode Révision Cahier)
// Allows reading, consulting diagrams, and launching editing.
// ══════════════════════════════════════════════════════════════

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/note_model.dart';
import '../../models/subject_model.dart';
import '../../providers/books_provider.dart';
import '../../widgets/rich_notebook_renderer.dart';
import 'notebook_editor_screen.dart';

class NotebookReaderScreen extends StatelessWidget {
  final SubjectModel subject;
  final NoteModel note;

  const NotebookReaderScreen({
    super.key,
    required this.subject,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F1EA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            Text(
              note.chapter,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF8B72DE)),
            ),
            const SizedBox(width: 8),
            const Text('•', style: TextStyle(color: Colors.black26)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                note.title,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF332C3E)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          // ✏️ Edit Note Button
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => NotebookEditorScreen(subject: subject, existingNote: note),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF3EFFF),
              foregroundColor: const Color(0xFF8B72DE),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.edit_note_rounded, size: 18),
            label: const Text('Modifier la Note ✏️', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
          ),
          const SizedBox(width: 8),

          // Delete Button
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
            onPressed: () {
              context.read<BooksProvider>().deleteNote(note.id);
              Navigator.pop(context);
            },
            tooltip: 'Supprimer cette note',
          ),
          const SizedBox(width: 14),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 880), // Full grand format
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(color: Color(0x15000000), blurRadius: 28, offset: Offset(0, 10)),
              ],
            ),
            child: CustomPaint(
              painter: _NotebookPaperPainter(style: note.paperStyle),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(54, 36, 40, 54),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header tag & date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3EFFF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            note.chapter,
                            style: const TextStyle(color: Color(0xFF8B72DE), fontWeight: FontWeight.w800, fontSize: 12),
                          ),
                        ),
                        Text(
                          '${note.updatedAt.day}/${note.updatedAt.month}/${note.updatedAt.year}',
                          style: const TextStyle(color: Colors.black38, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const Divider(height: 28, thickness: 1.2, color: Color(0xFFE8EEF5)),

                    // Big Title
                    Text(
                      note.title,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2D3436),
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 🖼️ Rendered Images Gallery
                    if (note.images.isNotEmpty) ...[
                      Wrap(
                        spacing: 14,
                        runSpacing: 14,
                        children: note.images.map((imgUrl) {
                          return Container(
                            constraints: const BoxConstraints(maxWidth: 420, maxHeight: 260),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFDDD6EC)),
                              boxShadow: const [
                                BoxShadow(color: Color(0x0C000000), blurRadius: 10, offset: Offset(0, 3)),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: imgUrl.startsWith('data:image')
                                  ? Image.memory(
                                      base64Decode(imgUrl.split(',').last),
                                      fit: BoxFit.cover,
                                    )
                                  : Image.network(
                                      imgUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image_rounded, color: Colors.grey)),
                                    ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Rendered Content with Colors, Highlights & Formatting!
                    RichNotebookRenderer(text: note.content),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Custom Painter for Paper Lines in Reader
// ══════════════════════════════════════════════════════════════
class _NotebookPaperPainter extends CustomPainter {
  final PaperStyle style;

  _NotebookPaperPainter({required this.style});

  @override
  void paint(Canvas canvas, Size size) {
    if (style == PaperStyle.blank) return;

    final linePaint = Paint()
      ..color = const Color(0xFFE8EEF5)
      ..strokeWidth = 1.0;

    final marginPaint = Paint()
      ..color = const Color(0xFFFFCDD2)
      ..strokeWidth = 1.5;

    canvas.drawLine(const Offset(44, 0), Offset(44, size.height), marginPaint);

    if (style == PaperStyle.lined) {
      const lineHeight = 28.0;
      for (double y = 56; y < size.height; y += lineHeight) {
        canvas.drawLine(Offset(44, y), Offset(size.width, y), linePaint);
      }
    } else if (style == PaperStyle.grid) {
      const gridSize = 22.0;
      for (double y = 0; y < size.height; y += gridSize) {
        canvas.drawLine(Offset(44, y), Offset(size.width, y), linePaint);
      }
      for (double x = 44; x < size.width; x += gridSize) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _NotebookPaperPainter oldDelegate) => oldDelegate.style != style;
}
