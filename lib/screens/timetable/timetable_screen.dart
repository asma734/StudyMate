// ══════════════════════════════════════════════════════════════
// TimetableScreen — StudyMate AI Companion
// Visual weekly timetable inspired by student schedule template.
// Days: Lundi, Mardi, Mercredi, Jeudi, Vendredi, Samedi
// Hours: 08h to 18h
// ══════════════════════════════════════════════════════════════

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  List<Map<String, dynamic>> _slots = [];
  bool _isLoading = true;
  String _selectedDay = 'Lundi';

  static const List<String> _days = [
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
    'Samedi',
  ];

  @override
  void initState() {
    super.initState();
    _loadTimetable();
  }

  Future<void> _loadTimetable() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('sm_timetable');
    if (jsonStr != null) {
      try {
        final List decoded = jsonDecode(jsonStr);
        setState(() {
          _slots = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
          _isLoading = false;
        });
        return;
      } catch (_) {}
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveTimetable() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sm_timetable', jsonEncode(_slots));
  }

  @override
  Widget build(BuildContext context) {
    final daySlots = _slots.where((s) => s['day'] == _selectedDay).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Mon Emploi du Temps 📅', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                // Day selector tabs
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: _days.map((day) {
                        final isSelected = _selectedDay == day;
                        final count = _slots.where((s) => s['day'] == day).length;

                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text('$day ($count)'),
                            selected: isSelected,
                            selectedColor: AppColors.primaryLight,
                            backgroundColor: Theme.of(context).cardColor,
                            labelStyle: TextStyle(
                              color: isSelected ? AppColors.primary : AppColors.textMuted,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              fontSize: 12.5,
                            ),
                            onSelected: (selected) {
                              if (selected) setState(() => _selectedDay = day);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                Expanded(
                  child: daySlots.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('🌸', style: TextStyle(fontSize: 48)),
                                const SizedBox(height: 14),
                                Text(
                                  'Aucun cours pour $_selectedDay',
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Journée libre pour vos révisions personnelles.',
                                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: daySlots.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, i) {
                            final slot = daySlots[i];
                            final colorHex = (slot['color'] as String? ?? '#B8A7EA').replaceFirst('#', '0xFF');
                            final cardColor = Color(int.tryParse(colorHex) ?? 0xFFB8A7EA);

                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.borderLight),
                                boxShadow: const [
                                  BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 3)),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 5,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: cardColor,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              slot['subject'] ?? '',
                                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AppColors.primaryLight,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                slot['type'] ?? 'Cours',
                                                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 11),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textMuted),
                                            const SizedBox(width: 4),
                                            Text(
                                              slot['time'] ?? '',
                                              style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600),
                                            ),
                                            if ((slot['room'] as String? ?? '').isNotEmpty) ...[
                                              const SizedBox(width: 14),
                                              const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
                                              const SizedBox(width: 4),
                                              Text(
                                                slot['room'],
                                                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                                    onPressed: () {
                                      setState(() {
                                        _slots.remove(slot);
                                      });
                                      _saveTimetable();
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
