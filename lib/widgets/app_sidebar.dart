// ══════════════════════════════════════════════════════════════
// AppSidebar — StudyMate AI Companion
// Gorgeous pastel lavender left navigation sidebar
// Faithfully matching the React desktop dashboard
// ══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

class AppSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const AppSidebar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  static const List<(String, IconData)> _items = [
    ('Overview', Icons.home_rounded),
    ('My Books', Icons.menu_book_rounded),
    ('Tasks', Icons.check_box_outlined),
    ('AI Tutor', Icons.smart_toy_outlined),
    ('Revision', Icons.auto_awesome_rounded),
    ('Analytics', Icons.bar_chart_rounded),
    ('Settings', Icons.settings_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFB8A7EA),
        borderRadius: BorderRadius.circular(36),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40B8A7EA),
            blurRadius: 32,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 🐻 Brand Header
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 26, top: 4),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFD8CC),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x18000000),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🐻', style: TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'StudyMate',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      'AI Companion',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Navigation Links
          Expanded(
            child: ListView.separated(
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = _items[index];
                final isActive = selectedIndex == index;

                return GestureDetector(
                  onTap: () => onDestinationSelected(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isActive ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: isActive
                          ? const [
                              BoxShadow(
                                color: Color(0x15000000),
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          item.$2,
                          size: 20,
                          color: isActive ? const Color(0xFF8B72DE) : Colors.white,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          item.$1,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                            color: isActive ? const Color(0xFF8B72DE) : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // 🪴 Cute Bottom Plant Widget
          Column(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.22),
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(color: Color(0x10000000), blurRadius: 10, offset: Offset(0, 4)),
                  ],
                ),
                child: const Center(
                  child: Text('🪴', style: TextStyle(fontSize: 34)),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Growing Every Day 🌱',
                style: TextStyle(
                  fontSize: 11.5,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
