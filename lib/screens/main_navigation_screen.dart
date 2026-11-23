// ══════════════════════════════════════════════════════════════
// MainNavigationScreen — StudyMate AI Companion
// Responsive Desktop / Tablet / Mobile Shell
// Displays the Left Purple Sidebar on wider screens (Web / Desktop)
// matching the user's original reference design!
// ══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/books_provider.dart';
import '../providers/tasks_provider.dart';
import '../widgets/app_sidebar.dart';
import 'overview/overview_screen.dart';
import 'my_books/books_list_screen.dart';
import 'tasks/tasks_screen.dart';
import 'ai_tutor/ai_tutor_screen.dart';
import 'revision/revision_screen.dart';
import 'settings/settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 1; // Default to My Books as requested by the user!

  final List<Widget> _screens = const [
    OverviewScreen(),
    BooksListScreen(),
    TasksScreen(),
    AiTutorScreen(),
    RevisionScreen(),
    _AnalyticsPlaceholder(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BooksProvider>().loadData();
      context.read<TasksProvider>().loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 720;

    if (isDesktop) {
      // 💻 Desktop / Web Layout with Persistent Left Sidebar
      return Scaffold(
        backgroundColor: const Color(0xFFFBF9F5),
        body: Row(
          children: [
            AppSidebar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) => setState(() => _currentIndex = index),
            ),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: _screens,
              ),
            ),
          ],
        ),
      );
    }

    // 📱 Mobile Layout (Collapsible Drawer with the same purple styling)
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F5),
      drawer: Drawer(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: AppSidebar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
            Navigator.pop(context);
          },
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('StudyMate 🐻', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex.clamp(0, 4),
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF8B72DE),
        unselectedItemColor: Colors.black38,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Overview'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_rounded), label: 'My Books'),
          BottomNavigationBarItem(icon: Icon(Icons.check_box_outlined), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy_outlined), label: 'AI Tutor'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome_rounded), label: 'Revision'),
        ],
      ),
    );
  }
}

class _AnalyticsPlaceholder extends StatelessWidget {
  const _AnalyticsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text('📊', style: TextStyle(fontSize: 48)),
          SizedBox(height: 14),
          Text('Performance Analytics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          SizedBox(height: 6),
          Text('Track your study hours and mastery progress per subject.', style: TextStyle(color: Colors.black45)),
        ],
      ),
    );
  }
}
