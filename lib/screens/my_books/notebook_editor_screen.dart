// ══════════════════════════════════════════════════════════════
// NotebookEditorScreen — StudyMate AI Companion
// Full-Screen Grand Cahier d'Étudiant Workspace
// Features:
// - Real-time Microsoft Word-style selective text coloring & highlighting (NO raw tags!)
// - Visual image insertion from PC (Downloads) or URL/presets directly on paper
// - Custom paper types (Lined, Grid, Blank)
// - Seamless save and re-edit
// ══════════════════════════════════════════════════════════════

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/note_model.dart';
import '../../models/subject_model.dart';
import '../../providers/books_provider.dart';
import '../../widgets/rich_notebook_controller.dart';
import '../../widgets/rich_notebook_renderer.dart';

class NotebookEditorScreen extends StatefulWidget {
  final SubjectModel subject;
  final NoteModel? existingNote;

  const NotebookEditorScreen({
    super.key,
    required this.subject,
    this.existingNote,
  });

  @override
  State<NotebookEditorScreen> createState() => _NotebookEditorScreenState();
}

class _NotebookEditorScreenState extends State<NotebookEditorScreen> {
  late TextEditingController _titleCtrl;
  late TextEditingController _chapterCtrl;
  late RichNotebookController _contentCtrl;
  final List<String> _images = [];

  late PaperStyle _paperStyle;
  bool _isPreviewMode = false;

  static const List<(String, Color, String)> _inkColors = [
    ('Encre Noire', Color(0xFF2D3436), '#2D3436'),
    ('Violet Lavande', Color(0xFF6C5CE7), '#6C5CE7'),
    ('Bleu Université', Color(0xFF0984E3), '#0984E3'),
    ('Rose Pastel', Color(0xFFE84393), '#E84393'),
    ('Vert Émeraude', Color(0xFF00B894), '#00B894'),
  ];

  static const List<(String, Color, String)> _highlighters = [
    ('Jaune', Color(0xFFFFF59D), '#FFF59D'),
    ('Lavande', Color(0xFFE1BEE7), '#E1BEE7'),
    ('Menthe', Color(0xFFC8E6C9), '#C8E6C9'),
    ('Pêche', Color(0xFFFFE0B2), '#FFE0B2'),
  ];

  @override
  void initState() {
    super.initState();
    final note = widget.existingNote;
    _titleCtrl = TextEditingController(text: note?.title ?? '');
    _chapterCtrl = TextEditingController(text: note?.chapter ?? 'Chapitre 1');

    if (note?.images != null) {
      _images.addAll(note!.images);
    }

    _contentCtrl = RichNotebookController.fromMarkup(
      note?.content ?? '',
      onImagesExtracted: (extracted) {
        for (final img in extracted) {
          if (!_images.contains(img)) _images.add(img);
        }
      },
    );

    _paperStyle = note?.paperStyle ?? PaperStyle.lined;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _chapterCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════════
  // 🖼️ Pick Image from PC or URL
  // ══════════════════════════════════════════════════════════════
  Future<void> _pickImageFromPC() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;
        if (file.bytes != null) {
          // Convert to Base64 Data URL for instant in-app rendering
          final base64String = base64Encode(file.bytes!);
          final extension = file.extension ?? 'png';
          final dataUri = 'data:image/$extension;base64,$base64String';
          setState(() {
            _images.add(dataUri);
          });
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _showInsertImageDialog() {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        final urlCtrl = TextEditingController();

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Insérer une Image / Schéma 🖼️', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Intégrez un schéma, graphique ou capture d\'écran directement dans votre cahier :', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                const SizedBox(height: 18),

                // Button: Choose from PC
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(dialogCtx);
                    _pickImageFromPC();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B72DE),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.folder_open_rounded, color: Colors.white, size: 20),
                  label: const Text('Choisir une image depuis mon PC 💻', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                ),
                const SizedBox(height: 18),

                Row(
                  children: const [
                    Expanded(child: Divider()),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text('OU LIEN URL', style: TextStyle(fontSize: 11, color: Colors.black38, fontWeight: FontWeight.bold))),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 14),

                TextField(
                  controller: urlCtrl,
                  decoration: InputDecoration(
                    hintText: 'https://example.com/schema.png',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),

                const Text('Schémas prédéfinis recommandés :', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _presetChip(dialogCtx, 'Architecture Système', 'https://images.unsplash.com/photo-1558494949-ef010cbdcc31?w=800'),
                    _presetChip(dialogCtx, 'Algorithme & Flux', 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=800'),
                    _presetChip(dialogCtx, 'Base de données & Modèle', 'https://images.unsplash.com/photo-1544383835-bda2bc66a55d?w=800'),
                  ],
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
                final url = urlCtrl.text.trim();
                if (url.isNotEmpty) {
                  setState(() => _images.add(url));
                }
                Navigator.pop(dialogCtx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B72DE)),
              child: const Text('Insérer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _presetChip(BuildContext ctx, String label, String url) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
      backgroundColor: const Color(0xFFF3EFFF),
      onPressed: () {
        setState(() => _images.add(url));
        Navigator.pop(ctx);
      },
    );
  }

  // ══════════════════════════════════════════════════════════════
  // 💾 Save Note
  // ══════════════════════════════════════════════════════════════
  void _saveNote() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez donner un titre à votre note')),
      );
      return;
    }

    final booksProvider = context.read<BooksProvider>();
    final exportedContent = _contentCtrl.exportToMarkup();

    if (widget.existingNote != null) {
      final updated = widget.existingNote!.copyWith(
        title: title,
        chapter: _chapterCtrl.text.trim().isEmpty ? 'Chapitre 1' : _chapterCtrl.text.trim(),
        content: exportedContent,
        paperStyle: _paperStyle,
        images: _images,
      );
      booksProvider.updateNote(updated);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Note mise à jour avec succès dans le cahier 📓'),
          backgroundColor: Color(0xFF43A047),
        ),
      );
    } else {
      final newNote = NoteModel(
        id: 'note_${DateTime.now().millisecondsSinceEpoch}',
        subjectId: widget.subject.id,
        title: title,
        chapter: _chapterCtrl.text.trim().isEmpty ? 'Chapitre 1' : _chapterCtrl.text.trim(),
        content: exportedContent,
        section: NoteSection.courseNotes,
        paperStyle: _paperStyle,
        images: _images,
      );
      booksProvider.addNote(newNote);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Note ajoutée à votre cahier 📓'),
          backgroundColor: Color(0xFF8B72DE),
        ),
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F1EA), // Cozy notebook desk background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            Text(
              widget.existingNote != null ? 'Modifier la Note ✏️' : 'Grand Cahier de Cours 📓',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: Color(0xFF332C3E)),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFF3EFFF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                widget.subject.name,
                style: const TextStyle(color: Color(0xFF8B72DE), fontSize: 11.5, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        actions: [
          // Toggle Preview Mode
          TextButton.icon(
            onPressed: () => setState(() => _isPreviewMode = !_isPreviewMode),
            icon: Icon(_isPreviewMode ? Icons.edit_note_rounded : Icons.menu_book_rounded, color: const Color(0xFF8B72DE), size: 18),
            label: Text(
              _isPreviewMode ? 'Mode Écriture ✏️' : 'Aperçu Cahier 📖',
              style: const TextStyle(color: Color(0xFF8B72DE), fontWeight: FontWeight.w800, fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),

          // Save Button
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: _saveNote,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B72DE),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
              label: Text(
                widget.existingNote != null ? 'Mettre à jour' : 'Enregistrer',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13.5),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 🛠️ Microsoft Word-Style Stationery Floating Toolbar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFEDE8F5))),
              boxShadow: [
                BoxShadow(color: Color(0x06000000), blurRadius: 6, offset: Offset(0, 2)),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Paper Style Selector
                  _toolChip('📏 Ligné', _paperStyle == PaperStyle.lined, () => setState(() => _paperStyle = PaperStyle.lined)),
                  const SizedBox(width: 6),
                  _toolChip('📐 Quadrillé', _paperStyle == PaperStyle.grid, () => setState(() => _paperStyle = PaperStyle.grid)),
                  const SizedBox(width: 6),
                  _toolChip('📄 Vierge', _paperStyle == PaperStyle.blank, () => setState(() => _paperStyle = PaperStyle.blank)),
                  const VerticalDivider(width: 24, thickness: 1, indent: 4, endIndent: 4),

                  // Formatting: Bold, Italic, Headings (Applies directly without tags!)
                  _iconButton(Icons.format_bold_rounded, 'Gras (sélection)', () => _contentCtrl.toggleBold()),
                  const SizedBox(width: 4),
                  _iconButton(Icons.format_italic_rounded, 'Italique (sélection)', () => _contentCtrl.toggleItalic()),
                  const SizedBox(width: 4),
                  _textToolButton('H1', 'Grand Titre', () => _contentCtrl.applyHeading(1)),
                  const SizedBox(width: 4),
                  _textToolButton('H2', 'Sous-titre', () => _contentCtrl.applyHeading(2)),
                  const SizedBox(width: 4),
                  _iconButton(Icons.format_clear_rounded, 'Effacer le style de la sélection', () => _contentCtrl.clearFormatting()),
                  const VerticalDivider(width: 24, thickness: 1, indent: 4, endIndent: 4),

                  // ✒️ Selective Text Colors (Feutres)
                  const Text('Feutre :', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF7E7092))),
                  const SizedBox(width: 8),
                  ..._inkColors.map((ink) {
                    return Tooltip(
                      message: 'Colorer la sélection en ${ink.$1}',
                      child: GestureDetector(
                        onTap: () => _contentCtrl.applyColor(ink.$2),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: ink.$2,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: const [BoxShadow(color: Color(0x20000000), blurRadius: 4)],
                          ),
                        ),
                      ),
                    );
                  }),
                  const VerticalDivider(width: 24, thickness: 1, indent: 4, endIndent: 4),

                  // 🟡 Selective Highlighters (Surligneurs)
                  const Text('Surligneur :', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF7E7092))),
                  const SizedBox(width: 8),
                  ..._highlighters.map((hl) {
                    return Tooltip(
                      message: 'Surligner la sélection en ${hl.$1}',
                      child: GestureDetector(
                        onTap: () => _contentCtrl.applyHighlight(hl.$2),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 24,
                          height: 18,
                          decoration: BoxDecoration(
                            color: hl.$2,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: const Color(0xFFDDD6EC)),
                          ),
                        ),
                      ),
                    );
                  }),
                  const VerticalDivider(width: 24, thickness: 1, indent: 4, endIndent: 4),

                  // 🖼️ Insert Image (From PC or Presets)
                  ElevatedButton.icon(
                    onPressed: _showInsertImageDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF3EFFF),
                      foregroundColor: const Color(0xFF8B72DE),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.add_photo_alternate_rounded, size: 16),
                    label: const Text('Insérer Image / Schéma 🖼️', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                  ),
                ],
              ),
            ),
          ),

          // 📓 Full-Screen Grand Cahier Page
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 880), // Wide comfortable notebook page
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(color: Color(0x18000000), blurRadius: 28, offset: Offset(0, 10)),
                    ],
                  ),
                  child: CustomPaint(
                    painter: _NotebookPaperPainter(style: _paperStyle),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(54, 32, 36, 48), // Authentic notebook margin!
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Chapter & Date Header
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3EFFF),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: IntrinsicWidth(
                                  child: TextField(
                                    controller: _chapterCtrl,
                                    style: const TextStyle(color: Color(0xFF8B72DE), fontWeight: FontWeight.w800, fontSize: 13),
                                    decoration: const InputDecoration(
                                      hintText: 'Chapitre...',
                                      isDense: true,
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'Date : ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                                style: const TextStyle(color: Colors.black38, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const Divider(height: 24, thickness: 1.2, color: Color(0xFFE8EEF5)),

                          // Note Title
                          TextField(
                            controller: _titleCtrl,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF2D3436),
                              letterSpacing: -0.3,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Titre de la leçon / Notions fondamentales...',
                              hintStyle: TextStyle(color: Colors.black26, fontSize: 20, fontWeight: FontWeight.w800),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // 🖼️ VISUAL IMAGE GALLERY ON PAPER (Real visible diagrams!)
                          if (_images.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFAFAFE),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFEAE5F5)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Schémas & Illustrations (${_images.length}) 📷',
                                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5, color: Color(0xFF8B72DE)),
                                      ),
                                      TextButton.icon(
                                        onPressed: _showInsertImageDialog,
                                        icon: const Icon(Icons.add, size: 14, color: Color(0xFF8B72DE)),
                                        label: const Text('Ajouter une image', style: TextStyle(fontSize: 11, color: Color(0xFF8B72DE), fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 14,
                                    runSpacing: 14,
                                    children: _images.asMap().entries.map((entry) {
                                      final index = entry.key;
                                      final imgUrl = entry.value;

                                      return Stack(
                                        children: [
                                          Container(
                                            width: 220,
                                            height: 150,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: const Color(0xFFDDD6EC)),
                                              boxShadow: const [
                                                BoxShadow(color: Color(0x0C000000), blurRadius: 6, offset: Offset(0, 2)),
                                              ],
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(12),
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
                                          ),
                                          Positioned(
                                            top: 6,
                                            right: 6,
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() => _images.removeAt(index));
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.all(4),
                                                decoration: const BoxDecoration(
                                                  color: Colors.redAccent,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(Icons.close_rounded, size: 14, color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Content Area: Switch between Word-Style Visual Editor & Live Notebook Rendering
                          if (_isPreviewMode)
                            RichNotebookRenderer(text: _contentCtrl.exportToMarkup())
                          else
                            TextField(
                              controller: _contentCtrl,
                              maxLines: null,
                              minLines: 20, // Generous, spacious writing height!
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.85,
                                color: Color(0xFF2D3436),
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Commencez à rédiger votre cours ici...\n\nSélectionnez un mot pour changer sa couleur ou le surligner (comme dans Microsoft Word) !\nCliquez sur "Insérer Image / Schéma" pour ajouter vos diagrammes et images depuis votre PC.',
                                hintStyle: TextStyle(color: Colors.black26, fontSize: 14.5, height: 1.85),
                                border: InputBorder.none,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _toolChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8B72DE) : const Color(0xFFF7F5FC),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : const Color(0xFF685D7B),
          ),
        ),
      ),
    );
  }

  Widget _iconButton(IconData icon, String tooltip, VoidCallback onTap) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F5FC),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFF685D7B)),
        ),
      ),
    );
  }

  Widget _textToolButton(String label, String tooltip, VoidCallback onTap) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F5FC),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF685D7B))),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// 🎨 Custom Notebook Paper Painter (Lignes et Carreaux de Cahier)
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
      ..color = const Color(0xFFFFCDD2) // Red / Pink notebook margin line
      ..strokeWidth = 1.5;

    // Draw Left Margin line (at 44px from left)
    canvas.drawLine(const Offset(44, 0), Offset(44, size.height), marginPaint);

    if (style == PaperStyle.lined) {
      // Draw horizontal notebook lines (spaced 28px)
      const lineHeight = 28.0;
      for (double y = 56; y < size.height; y += lineHeight) {
        canvas.drawLine(Offset(44, y), Offset(size.width, y), linePaint);
      }
    } else if (style == PaperStyle.grid) {
      // Draw graph grid (22px x 22px)
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
