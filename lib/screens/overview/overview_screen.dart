import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/books_provider.dart';
import '../../providers/tasks_provider.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final booksProvider = Provider.of<BooksProvider>(context);
    final tasksProvider = Provider.of<TasksProvider>(context);
    final user = authProvider.user;

    final subjectsCount = booksProvider.subjects.length;
    final doneTasksCount = tasksProvider.doneTasks.length;
    final todoTasksCount = tasksProvider.todoTasks.length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard 👋',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
            ),
            Text(
              'Welcome back, ${user?.name ?? "Nidhi"}! 💜',
              style: TextStyle(
                fontSize: 12.5,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Badge(
              label: Text('3', style: TextStyle(fontSize: 10)),
              backgroundColor: AppColors.peachDark,
              child: Icon(Icons.notifications_outlined, size: 22),
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primarySoft,
            child: const Text('🎓', style: TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Hero Card (Mascot & Morning greeting matching reference image)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFF0EB), Color(0xFFFDE3DB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(26),
                boxShadow: const [
                  BoxShadow(color: Color(0x18F29A80), blurRadius: 16, offset: Offset(0, 6)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: const [
                        BoxShadow(color: Color(0x20F29A80), blurRadius: 10, offset: Offset(0, 4)),
                      ],
                    ),
                    child: const Center(
                      child: Text('👩‍🎓', style: TextStyle(fontSize: 38)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Good Morning! ☀️',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF332C3E),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Let's make today amazing! 💜",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF766660),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2. 4 Mobile KPI Stat Cards
            Row(
              children: [
                Expanded(child: _buildKpiCard('Total Subjects', '$subjectsCount', '📚', '+12%', AppColors.primaryLight, AppColors.primary)),
                const SizedBox(width: 14),
                Expanded(child: _buildKpiCard('Tasks Done', '$doneTasksCount', '✅', '+18%', AppColors.peach, AppColors.peachDark)),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _buildKpiCard('Revision Hours', '32h', '⏱️', '+8%', AppColors.mint, AppColors.mintDark)),
                const SizedBox(width: 14),
                Expanded(child: _buildKpiCard('Curriculum Progress', '68%', '🎯', '+5%', AppColors.butterYellow, AppColors.yellowDark)),
              ],
            ),
            const SizedBox(height: 22),

            // 3. Weekly Study Activity Card (Curved Spline Simulation)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.borderLight),
                boxShadow: const [
                  BoxShadow(color: AppColors.shadowPurple, blurRadius: 14, offset: Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Activity Overview',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Text('This Week', style: TextStyle(color: AppColors.primary, fontSize: 11.5, fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Mobile friendly weekly bar graph
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildDayColumn('Mon', 0.4, false),
                      _buildDayColumn('Tue', 0.6, false),
                      _buildDayColumn('Wed', 0.5, false),
                      _buildDayColumn('Thu', 0.9, true), // Peak day (matching image)
                      _buildDayColumn('Fri', 0.55, false),
                      _buildDayColumn('Sat', 0.7, false),
                      _buildDayColumn('Sun', 0.6, false),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 4. "Don't forget!" Cactus Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(child: Text('🌵', style: TextStyle(fontSize: 28))),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("Don't forget! 🌸", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                        SizedBox(height: 2),
                        Text('You have 2 high-priority tasks due this week', style: TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard(String title, String val, String emoji, String trend, Color bg, Color iconTint) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: const [
          BoxShadow(color: Color(0x10B8A7EA), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                child: Center(child: Text(emoji, style: const TextStyle(fontSize: 16))),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(val, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textMain)),
          const SizedBox(height: 4),
          Text('$trend from last week', style: TextStyle(fontSize: 10, color: AppColors.mintDark, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildDayColumn(String day, double fraction, bool isPeak) {
    return Column(
      children: [
        if (isPeak)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
            child: const Text('75h', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
          ),
        Container(
          width: 28,
          height: 100 * fraction,
          decoration: BoxDecoration(
            color: isPeak ? AppColors.primary : AppColors.primarySoft.withOpacity(0.4),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          day,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isPeak ? FontWeight.w800 : FontWeight.w600,
            color: isPeak ? AppColors.primary : AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
