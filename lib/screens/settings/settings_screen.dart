// ══════════════════════════════════════════════════════════════
// SettingsScreen — StudyMate AI Companion
// Profile, theme, and account management.
// ══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Settings ⚙️', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryLight, AppColors.peach],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: AppColors.shadowPurple, blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Row(
              children: [
                Container(
                  width: 64, height: 64,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Center(child: Text('👩‍🎓', style: TextStyle(fontSize: 32))),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'Student',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textMain),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user?.email ?? 'student@university.dz',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 12.5),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          user?.degree ?? 'Computer Science · L3',
                          style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Academic Info section
          _sectionHeader('Academic Information 🎓'),
          _infoTile(context, Icons.school_outlined, 'University', user?.university ?? 'Not set'),
          _infoTile(context, Icons.grade_outlined, 'Academic Level', user?.academicLevel ?? 'Not set'),
          _infoTile(context, Icons.timeline_outlined, 'Semester', user?.semester ?? 'Not set'),
          const SizedBox(height: 20),

          // Appearance section
          _sectionHeader('Appearance 🎨'),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: AppColors.shadowPurple, blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: Row(
              children: [
                Icon(
                  themeProvider.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      const SizedBox(height: 2),
                      Text(
                        themeProvider.isDarkMode ? 'Dark theme active' : 'Light theme active',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => themeProvider.toggleTheme(),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeInOut,
                    width: 54,
                    height: 30,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: themeProvider.isDarkMode ? AppColors.primary : const Color(0xFFE6E0F5),
                    ),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeInOut,
                      alignment: themeProvider.isDarkMode ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(color: Color(0x25000000), blurRadius: 3, offset: Offset(0, 1)),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            themeProvider.isDarkMode ? '🌙' : '☀️',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // App Info section
          _sectionHeader('About 📱'),
          _listTile(context, Icons.info_outline_rounded, 'Version', '1.0.0 (Week 2 Build)', () {}),
          _listTile(context, Icons.bug_report_outlined, 'Report a Bug', '', () {}),
          const SizedBox(height: 20),

          // Logout
          Container(
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
            ),
            child: ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              title: const Text('Log Out', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w700)),
              onTap: () => _confirmLogout(context, authProvider),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textMuted)),
    );
  }

  Widget _infoTile(BuildContext context, IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: AppColors.shadowPurple, blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: AppColors.textMuted, fontSize: 11.5, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _listTile(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: AppColors.shadowPurple, blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: subtitle.isNotEmpty ? Text(subtitle, style: TextStyle(color: AppColors.textMuted, fontSize: 12)) : null,
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  void _confirmLogout(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log Out?', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('You will need to log in again to access your workspace.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              authProvider.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
