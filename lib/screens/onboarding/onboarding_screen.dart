import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/books_provider.dart';
import '../../providers/theme_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentStep = 0;

  // Step 1: Academic Background
  final _universityController = TextEditingController(text: 'Faculté des Sciences');
  final _levelController = TextEditingController(text: 'Licence 3');
  final _degreeController = TextEditingController(text: 'Informatique');
  final _specializationController = TextEditingController(text: 'Systèmes Distribués & Mobile');
  final _semesterController = TextEditingController(text: 'Semestre 5');

  // Step 2: Subjects entered EXCLUSIVELY by the student (empty by default)
  final List<Map<String, dynamic>> _subjects = [];

  final _newSubjectNameController = TextEditingController();
  double _newSubjectCoeff = 3.0;
  int _newSubjectDifficulty = 3;
  String _selectedColor = '#B8A7EA';

  static const List<String> _pastelColors = [
    '#B8A7EA', // Lavender
    '#FFD8CC', // Peach
    '#D4EDDA', // Mint
    '#FFF4D2', // Butter Yellow
    '#FCE8E6', // Soft Pink
    '#D0ECF8', // Sky Blue
  ];

  // Step 3: Timetable filled EXCLUSIVELY by the student (empty by default)
  // Inspired by: "Mon emploi du temps" (Lundi, Mardi, Mercredi, Jeudi, Vendredi, Samedi)
  final List<Map<String, dynamic>> _scheduleSlots = [];
  String _selectedDayTab = 'Lundi';

  static const List<String> _weekDays = [
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
    'Samedi',
  ];

  static const List<String> _timeSlotPresets = [
    '08h00 - 09h00',
    '09h00 - 10h00',
    '10h00 - 11h00',
    '11h00 - 12h00',
    '12h00 - 13h00',
    '13h00 - 14h00',
    '14h00 - 15h00',
    '15h00 - 16h00',
    '16h00 - 17h00',
    '17h00 - 18h00',
    '08h30 - 11h30',
    '13h30 - 16h30',
  ];

  @override
  void dispose() {
    _universityController.dispose();
    _levelController.dispose();
    _degreeController.dispose();
    _specializationController.dispose();
    _semesterController.dispose();
    _newSubjectNameController.dispose();
    super.dispose();
  }

  void _addSubject() {
    final name = _newSubjectNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer le nom de la matière'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _subjects.add({
        'id': 'sub_${DateTime.now().millisecondsSinceEpoch}',
        'name': name,
        'coeff': _newSubjectCoeff,
        'color': _selectedColor,
        'difficulty': _newSubjectDifficulty,
      });
      _newSubjectNameController.clear();
      _newSubjectCoeff = 3.0;
      _newSubjectDifficulty = 3;
    });
  }

  void _removeSubject(int index) {
    setState(() {
      final removed = _subjects.removeAt(index);
      // Also remove any schedule slots tied to this subject
      _scheduleSlots.removeWhere((slot) => slot['subject'] == removed['name']);
    });
  }

  void _showAddScheduleDialog() {
    if (_subjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ajoutez d\'abord vos matières à l\'étape 2 !'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    String day = _selectedDayTab;
    String subject = _subjects.first['name'] as String;
    String time = _timeSlotPresets.first;
    String type = 'Cours';
    final roomController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Text(
                'Ajouter un cours 📅',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Day Selector
                    const Text('Jour', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: day,
                      decoration: _dialogInputDecoration(),
                      items: _weekDays.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                      onChanged: (val) => setDialogState(() => day = val!),
                    ),
                    const SizedBox(height: 14),

                    // Subject Selector (from user's own subjects!)
                    const Text('Matière', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: subject,
                      decoration: _dialogInputDecoration(),
                      items: _subjects.map((s) {
                        return DropdownMenuItem<String>(
                          value: s['name'] as String,
                          child: Text(s['name'] as String),
                        );
                      }).toList(),
                      onChanged: (val) => setDialogState(() => subject = val!),
                    ),
                    const SizedBox(height: 14),

                    // Time Slot
                    const Text('Créneau horaire', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: time,
                      decoration: _dialogInputDecoration(),
                      items: _timeSlotPresets.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                      onChanged: (val) => setDialogState(() => time = val!),
                    ),
                    const SizedBox(height: 14),

                    // Session Type
                    const Text('Type de séance', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: type,
                      decoration: _dialogInputDecoration(),
                      items: const [
                        DropdownMenuItem(value: 'Cours', child: Text('Cours magistral (CM)')),
                        DropdownMenuItem(value: 'TD', child: Text('Travaux Dirigés (TD)')),
                        DropdownMenuItem(value: 'TP', child: Text('Travaux Pratiques (TP)')),
                        DropdownMenuItem(value: 'Atelier / Projet', child: Text('Atelier / Projet')),
                      ],
                      onChanged: (val) => setDialogState(() => type = val!),
                    ),
                    const SizedBox(height: 14),

                    // Room (optional)
                    const Text('Salle / Amphi (optionnel)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: roomController,
                      decoration: _dialogInputDecoration(hint: 'ex: Salle B12, Amphi A...'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Annuler', style: TextStyle(color: AppColors.textMuted)),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Match subject color
                    final subObj = _subjects.firstWhere(
                      (s) => s['name'] == subject,
                      orElse: () => {'color': '#B8A7EA'},
                    );

                    setState(() {
                      _scheduleSlots.add({
                        'day': day,
                        'subject': subject,
                        'time': time,
                        'type': type,
                        'room': roomController.text.trim(),
                        'color': subObj['color'] ?? '#B8A7EA',
                      });
                      _selectedDayTab = day;
                    });

                    Navigator.pop(dialogContext);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Ajouter', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _completeOnboarding() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final booksProvider = Provider.of<BooksProvider>(context, listen: false);

    await authProvider.completeOnboarding(
      university: _universityController.text.trim(),
      degree: _degreeController.text.trim(),
      academicLevel: _levelController.text.trim(),
      semester: _semesterController.text.trim(),
      subjects: _subjects,
      timetable: _scheduleSlots,
    );

    // Refresh books provider with the student's newly created subjects
    await booksProvider.loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Stepper Indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                children: List.generate(4, (index) {
                  final isActive = index <= _currentStep;
                  return Expanded(
                    child: Container(
                      height: 5,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.primary : AppColors.borderLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Step Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: _buildStepContent(),
              ),
            ),

            // Bottom Navigation Bar
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: const [
                  BoxShadow(color: Color(0x10000000), blurRadius: 10, offset: Offset(0, -4)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    TextButton(
                      onPressed: () => setState(() => _currentStep--),
                      child: const Text('Précédent', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w700)),
                    )
                  else
                    const SizedBox.shrink(),
                  ElevatedButton(
                    onPressed: () {
                      if (_currentStep == 1 && _subjects.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Veuillez ajouter au moins une matière avant de continuer !'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }

                      if (_currentStep < 3) {
                        setState(() => _currentStep++);
                      } else {
                        _completeOnboarding();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      _currentStep == 3 ? 'Lancer StudyMate 🚀' : 'Étape suivante →',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1AcademicInfo();
      case 1:
        return _buildStep2Subjects();
      case 2:
        return _buildStep3Timetable();
      case 3:
        return _buildStep4Personalization();
      default:
        return const SizedBox.shrink();
    }
  }

  // STEP 1: ACADEMIC BACKGROUND
  Widget _buildStep1AcademicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Étape 1 sur 4', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 13)),
        const SizedBox(height: 6),
        Text('Profil Académique 🎓', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 22)),
        const SizedBox(height: 6),
        const Text('Renseignez votre formation universitaire pour personnaliser votre espace de travail.', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
        const SizedBox(height: 24),
        _buildTextField('Université / Faculté', _universityController, Icons.school_outlined, 'ex: Faculté des Sciences'),
        const SizedBox(height: 14),
        _buildTextField('Filière / Spécialité', _degreeController, Icons.menu_book_outlined, 'ex: Informatique'),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: _buildTextField('Niveau d\'études', _levelController, Icons.stairs_outlined, 'ex: Licence 3')),
            const SizedBox(width: 12),
            Expanded(child: _buildTextField('Semestre', _semesterController, Icons.calendar_today_outlined, 'ex: Semestre 5')),
          ],
        ),
      ],
    );
  }

  // STEP 2: SUBJECTS ENTERED EXCLUSIVELY BY THE USER
  Widget _buildStep2Subjects() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Étape 2 sur 4', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 13)),
        const SizedBox(height: 6),
        Text('Vos Matières & Coefficients 📚', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 22)),
        const SizedBox(height: 6),
        const Text('Saisissez vous-même vos matières. Les coefficients permettent à l\'IA de prioriser intelligemment vos tâches et révisions.', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
        const SizedBox(height: 20),

        // List of student's subjects
        if (_subjects.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.5),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.primarySoft.withOpacity(0.3)),
            ),
            child: Row(
              children: const [
                Text('📝', style: TextStyle(fontSize: 28)),
                SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Aucune matière ajoutée pour le moment. Remplissez le formulaire ci-dessous pour ajouter vos matières.',
                    style: TextStyle(color: AppColors.textMain, fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
          )
        else
          ..._subjects.asMap().entries.map((entry) {
            final index = entry.key;
            final sub = entry.value;
            final colorHex = (sub['color'] as String).replaceFirst('#', '0xFF');
            final cardColor = Color(int.tryParse(colorHex) ?? 0xFFB8A7EA);

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.borderLight),
                boxShadow: const [
                  BoxShadow(color: Color(0x06000000), blurRadius: 6, offset: Offset(0, 2)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(color: cardColor, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sub['name'] as String,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                        Row(
                          children: [
                            Text(
                              'Difficulté : ',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                            ),
                            ...List.generate(
                              5,
                              (i) => Icon(
                                Icons.star_rounded,
                                size: 14,
                                color: i < (sub['difficulty'] as int) ? AppColors.yellowDark : AppColors.borderLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      'Coeff. ${(sub['coeff'] as num).toStringAsFixed(1)}',
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                    onPressed: () => _removeSubject(index),
                    tooltip: 'Supprimer',
                  ),
                ],
              ),
            );
          }),

        const SizedBox(height: 20),

        // Add Subject Form
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: const [
              BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 3)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Ajouter une matière ➕', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
              const SizedBox(height: 12),
              TextField(
                controller: _newSubjectNameController,
                decoration: const InputDecoration(
                  hintText: 'ex: Algorithmique, Compilation, Réseaux...',
                  isDense: true,
                ),
              ),
              const SizedBox(height: 14),

              // Coefficient Slider
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Coefficient :', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _newSubjectCoeff.toStringAsFixed(1),
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                  ),
                ],
              ),
              Slider(
                value: _newSubjectCoeff,
                min: 1.0,
                max: 6.0,
                divisions: 10,
                activeColor: AppColors.primary,
                onChanged: (val) => setState(() => _newSubjectCoeff = val),
              ),

              // Difficulty level
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Difficulté estimée :', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  Row(
                    children: List.generate(5, (i) {
                      return GestureDetector(
                        onTap: () => setState(() => _newSubjectDifficulty = i + 1),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Icon(
                            Icons.star_rounded,
                            size: 24,
                            color: i < _newSubjectDifficulty ? AppColors.yellowDark : AppColors.borderLight,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Color Choice
              const Text('Couleur du Book :', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 8),
              Row(
                children: _pastelColors.map((hex) {
                  final color = Color(int.parse(hex.replaceFirst('#', '0xFF')));
                  final isSelected = _selectedColor == hex;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = hex),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected ? Border.all(color: AppColors.primary, width: 2.5) : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _addSubject,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Ajouter la matière', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // STEP 3: TIMETABLE FILLED EXCLUSIVELY BY THE USER
  // Matching: "Mon emploi du temps" (Lundi, Mardi, Mercredi, Jeudi, Vendredi, Samedi)
  Widget _buildStep3Timetable() {
    final filteredSlots = _scheduleSlots.where((s) => s['day'] == _selectedDayTab).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Étape 3 sur 4', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 13)),
        const SizedBox(height: 6),
        Text('Mon Emploi du Temps 📅', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 22)),
        const SizedBox(height: 6),
        const Text('Renseignez vos créneaux de cours, TD et TP. L\'IA adaptera vos heures d\'étude selon vos disponibilités.', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
        const SizedBox(height: 16),

        // Button to add course slot
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _showAddScheduleDialog,
            icon: const Icon(Icons.add_alarm_rounded, size: 20),
            label: const Text('Ajouter un cours / séance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Weekdays Tabs (Lundi, Mardi, Mercredi, Jeudi, Vendredi, Samedi)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _weekDays.map((day) {
              final isSelected = _selectedDayTab == day;
              final dayCount = _scheduleSlots.where((s) => s['day'] == day).length;

              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text('$day ($dayCount)'),
                  selected: isSelected,
                  selectedColor: AppColors.primaryLight,
                  backgroundColor: Theme.of(context).cardColor,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.primary : AppColors.textMuted,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 12.5,
                  ),
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedDayTab = day);
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),

        // Day's slots list
        if (filteredSlots.isEmpty)
          Container(
            padding: const EdgeInsets.all(28),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              children: [
                const Text('☕', style: TextStyle(fontSize: 36)),
                const SizedBox(height: 10),
                Text(
                  'Aucun cours pour $_selectedDayTab',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Journée libre ou cliquez sur "Ajouter un cours" ci-dessus.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ...filteredSlots.map((slot) {
            final colorHex = (slot['color'] as String).replaceFirst('#', '0xFF');
            final cardColor = Color(int.tryParse(colorHex) ?? 0xFFB8A7EA);

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.borderLight),
                boxShadow: const [
                  BoxShadow(color: Color(0x06000000), blurRadius: 6, offset: Offset(0, 2)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 44,
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              slot['subject'] as String,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                slot['type'] as String,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.access_time_rounded, size: 13, color: AppColors.textMuted),
                            const SizedBox(width: 4),
                            Text(
                              slot['time'] as String,
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            if ((slot['room'] as String).isNotEmpty) ...[
                              const SizedBox(width: 12),
                              const Icon(Icons.location_on_outlined, size: 13, color: AppColors.textMuted),
                              const SizedBox(width: 3),
                              Text(
                                slot['room'] as String,
                                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                    onPressed: () {
                      setState(() {
                        _scheduleSlots.remove(slot);
                      });
                    },
                    tooltip: 'Supprimer ce créneau',
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  // STEP 4: PERSONALIZATION & DARK MODE
  Widget _buildStep4Personalization() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Étape 4 sur 4', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 13)),
        const SizedBox(height: 6),
        Text('Ambiance & Thème 🎨', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 22)),
        const SizedBox(height: 6),
        const Text('Choisissez votre environnement d\'étude préféré.', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
        const SizedBox(height: 24),

        // Dark / Light Toggle Card (Safe without duplicate GlobalKey ink renderer)
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            final isDark = themeProvider.isDarkMode;
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.borderLight),
                boxShadow: const [
                  BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 4)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF383344) : AppColors.primaryLight,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isDark ? 'Mode Sombre Activé 🌙' : 'Mode Clair Pastel 🌸',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isDark ? 'Ambiance feutrée pour le soir' : 'Design doux et apaisant',
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Custom Animated Toggle without Material Ink / GlobalKey to prevent Flutter Web collision
                  GestureDetector(
                    onTap: () {
                      themeProvider.toggleTheme();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeInOut,
                      width: 58,
                      height: 32,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: isDark ? AppColors.primary : const Color(0xFFE6E0F5),
                        boxShadow: const [
                          BoxShadow(color: Color(0x12000000), blurRadius: 4, offset: Offset(0, 2)),
                        ],
                      ),
                      child: AnimatedAlign(
                        duration: const Duration(milliseconds: 240),
                        curve: Curves.easeInOut,
                        alignment: isDark ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(color: Color(0x25000000), blurRadius: 3, offset: Offset(0, 1)),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              isDark ? '🌙' : '☀️',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 24),

        // Summary of configuration
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFF9E6), Color(0xFFFFF2CC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(color: Color(0x15000000), blurRadius: 14, offset: Offset(0, 6)),
            ],
          ),
          child: Row(
            children: [
              const Text('✨', style: TextStyle(fontSize: 36)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tout est prêt ! 💜', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF332C3E))),
                    const SizedBox(height: 4),
                    Text(
                      '${_subjects.length} matière(s) et ${_scheduleSlots.length} créneau(x) d\'emploi du temps configurés.',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF7E7052), fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Cliquez sur "Lancer StudyMate" pour ouvrir votre tableau de bord.',
                      style: TextStyle(fontSize: 11, color: Color(0xFF7E7052)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.primarySoft, size: 20),
          ),
        ),
      ],
    );
  }

  InputDecoration _dialogInputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderLight)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderLight)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
    );
  }
}
