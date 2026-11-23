// ══════════════════════════════════════════════════════════════
// AppHeader — StudyMate AI Companion
// Header bar with search, notification, and profile
// ══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const AppHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMain,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('👋', style: TextStyle(fontSize: 22)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Search bar & icons
          Row(
            children: [
              // Search Bar
              Container(
                width: 220,
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderLight),
                  boxShadow: const [
                    BoxShadow(color: Color(0x06000000), blurRadius: 6, offset: Offset(0, 2)),
                  ],
                ),
                child: Row(
                  children: const [
                    Icon(Icons.search_rounded, size: 18, color: AppColors.textLight),
                    SizedBox(width: 8),
                    Text(
                      'Search anything...',
                      style: TextStyle(color: AppColors.textLight, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // Bell Notification Badge
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: const Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.notifications_none_rounded, size: 20, color: AppColors.textMuted),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: CircleAvatar(
                        radius: 4,
                        backgroundColor: AppColors.peachDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Chat Message Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: const Center(
                  child: Icon(Icons.chat_bubble_outline_rounded, size: 18, color: AppColors.textMuted),
                ),
              ),
              const SizedBox(width: 12),

              // Profile Avatar
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.peach,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [
                    BoxShadow(color: Color(0x15000000), blurRadius: 8, offset: Offset(0, 3)),
                  ],
                ),
                child: const Center(
                  child: Text('👩‍🎓', style: TextStyle(fontSize: 22)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
