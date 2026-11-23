// ══════════════════════════════════════════════════════════════
// BooksListScreen — StudyMate AI Companion
// EXACT replica of the user's reference design
// (media_1795420418578_5b10cbce.jpg)
// ══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/subject_model.dart';
import '../../providers/books_provider.dart';
import '../../widgets/app_header.dart';
import 'book_detail_screen.dart';

class BooksListScreen extends StatefulWidget {
  const BooksListScreen({super.key});

  @override
  State<BooksListScreen> createState() => _BooksListScreenState();
}

class _BooksListScreenState extends State<BooksListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BooksProvider>().loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final booksProvider = context.watch<BooksProvider>();
    final subjects = booksProvider.subjects;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F5),
      body: Column(
        children: [
          // 🔝 Top App Header matching reference
          const AppHeader(
            title: 'My Academic Books',
            subtitle: 'Every subject has its own dedicated digital workspace & AI tutor 📚',
          ),

          // Main scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 🌸 Lilac Knowledge Shelves Banner matching reference
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF5F1FD), Color(0xFFEFE8FA)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE7DEF7)),
                      boxShadow: const [
                        BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 3)),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Your Digital Knowledge Shelves 🌸',
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF332C3E),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Organize lecture notes, course materials, practical work (TP) and revision exercises per subject.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF7E7092),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: () => _showCreateBookModal(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B72DE),
                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 3,
                          ),
                          icon: const Icon(Icons.add, color: Colors.white, size: 18),
                          label: const Text(
                            'Create New Subject Book',
                            style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 13.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 📚 Books Grid
                  if (booksProvider.isLoading)
                    const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: AppColors.primary)))
                  else if (subjects.isEmpty)
                    _buildEmptyState(context)
                  else
                    LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = 3;
                        if (constraints.maxWidth < 650) {
                          crossAxisCount = 1;
                        } else if (constraints.maxWidth < 1000) {
                          crossAxisCount = 2;
                        }

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: subjects.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 22,
                            mainAxisSpacing: 22,
                            childAspectRatio: 1.15,
                          ),
                          itemBuilder: (context, i) => _BookShelfCard(subject: subjects[i]),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 40),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          children: [
            const Text('📚', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            const Text(
              'No subject books created yet!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textMain),
            ),
            const SizedBox(height: 6),
            const Text(
              'Click "+ Create New Subject Book" above to add your first academic book.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateBookModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const _CreateBookDialog(),
    );
  }
}

// ── Book Shelf Card (Identical to reference screenshot) ────────
class _BookShelfCard extends StatelessWidget {
  final SubjectModel subject;
  const _BookShelfCard({required this.subject});

  Color get _color {
    final hex = subject.colorHex.replaceFirst('#', '0xFF');
    return Color(int.tryParse(hex) ?? 0xFFB8A7EA);
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = _color;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderLight, width: 1.2),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 14, offset: Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => BookDetailScreen(subject: subject)),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Color Border Strip
                Container(height: 6, color: cardColor),

                Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Semester tag & Book icon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3EFFF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              subject.semester.isEmpty ? 'Semester 5' : subject.semester,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF8B72DE),
                              ),
                            ),
                          ),
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: cardColor.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Icon(Icons.menu_book_rounded, size: 18, color: Color(0xFF4A3B69)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Title
                      Text(
                        subject.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF332C3E),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),

                      // Description
                      Text(
                        subject.description.isEmpty
                            ? 'Comprehensive lecture notes, practical exercises and AI revision materials.'
                            : subject.description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF7E7292),
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Bottom Stats & Progress Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 16),
                  child: Column(
                    children: [
                      // Notes & TPs Count
                      Row(
                        children: [
                          const Icon(Icons.description_outlined, size: 14, color: Color(0xFF8B72DE)),
                          const SizedBox(width: 4),
                          Text(
                            '${subject.savedNotesCount} Notes',
                            style: const TextStyle(fontSize: 11.5, color: Color(0xFF685D7B), fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 14),
                          const Icon(Icons.check_circle_outline_rounded, size: 14, color: Color(0xFF43A047)),
                          const SizedBox(width: 4),
                          Text(
                            '${subject.completedTpsCount}/${subject.tpsCount} TPs',
                            style: const TextStyle(fontSize: 11.5, color: Color(0xFF685D7B), fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Progress Bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Mastery Progress',
                            style: TextStyle(color: Color(0xFF857C94), fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            '${subject.progressPercentage.toInt()}%',
                            style: const TextStyle(color: Color(0xFF332C3E), fontSize: 11, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: (subject.progressPercentage / 100).clamp(0.0, 1.0),
                          backgroundColor: const Color(0xFFF0ECF8),
                          valueColor: AlwaysStoppedAnimation(cardColor),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Open Workspace Link
                      const Divider(height: 1, color: Color(0xFFF5F2FA)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'Open Subject Workspace',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF8B72DE),
                            ),
                          ),
                          Icon(Icons.arrow_forward_rounded, size: 15, color: Color(0xFF8B72DE)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Create Book Modal (matching media_1794941388518_1f1a018b.png) ────────
class _CreateBookDialog extends StatefulWidget {
  const _CreateBookDialog();

  @override
  State<_CreateBookDialog> createState() => _CreateBookDialogState();
}

class _CreateBookDialogState extends State<_CreateBookDialog> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _semesterCtrl = TextEditingController(text: 'Semester 5');
  final _profCtrl = TextEditingController();
  String _selectedColor = '#B8A7EA';
  double _coeff = 3.0;

  static const _palette = [
    '#B8A7EA', // Lavender
    '#FFD8CC', // Peach
    '#D4EDDA', // Mint
    '#FFF4D2', // Butter Yellow
    '#FCE8E6', // Soft Pink
    '#D0ECF8', // Sky Blue
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _semesterCtrl.dispose();
    _profCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;

    final newSubject = SubjectModel(
      id: 'sub_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: _descCtrl.text.trim(),
      semester: _semesterCtrl.text.trim(),
      professorName: _profCtrl.text.trim(),
      colorHex: _selectedColor,
      coefficient: _coeff,
    );

    context.read<BooksProvider>().addSubject(newSubject);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Create New Subject Book 📖',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF332C3E)),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Each subject receives its own dedicated digital workspace, notes & AI tutor.',
                          style: TextStyle(fontSize: 12, color: Color(0xFF857C94)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20, color: Colors.black45),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Subject Name
              const Text('Subject Name *', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: _nameCtrl,
                decoration: _modalInputDeco('e.g. React JS, SOA, Mobile Dev...'),
              ),
              const SizedBox(height: 14),

              // Description
              const Text('Description', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: _descCtrl,
                maxLines: 2,
                decoration: _modalInputDeco('What is covered in this course?'),
              ),
              const SizedBox(height: 14),

              // Semester & Professor
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Semester', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextField(controller: _semesterCtrl, decoration: _modalInputDeco('Semester 5')),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Professor Name', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextField(controller: _profCtrl, decoration: _modalInputDeco('Prof. name')),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Color Palette
              const Text('Book Aesthetic Theme', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 10),
              Row(
                children: _palette.map((hex) {
                  final color = Color(int.parse(hex.replaceFirst('#', '0xFF')));
                  final isSelected = _selectedColor == hex;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = hex),
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected ? Border.all(color: const Color(0xFF8B72DE), width: 3) : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel', style: TextStyle(color: Color(0xFF857C94), fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B72DE),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: const Icon(Icons.auto_awesome, size: 16, color: Colors.white),
                    label: const Text('Create Book', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _modalInputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      isDense: true,
      hintStyle: const TextStyle(color: Colors.black26, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEDE8F5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEDE8F5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF8B72DE), width: 1.5),
      ),
    );
  }
}
