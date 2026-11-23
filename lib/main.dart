import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_colors.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/books_provider.dart';
import 'providers/tasks_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const StudyMateApp());
}

class StudyMateApp extends StatelessWidget {
  const StudyMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BooksProvider()),
        ChangeNotifierProvider(create: (_) => TasksProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'StudyMate AI',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const RootGateScreen(),
          );
        },
      ),
    );
  }
}

// Gate Screen managing session routing
class RootGateScreen extends StatelessWidget {
  const RootGateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // 1. Loading Splash
    if (authProvider.isLoading) {
      return Scaffold(
        backgroundColor: AppColors.bgLight,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: AppColors.peach,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppColors.shadowPurple, blurRadius: 20, offset: Offset(0, 8)),
                  ],
                ),
                child: const Center(child: Text('🐻', style: TextStyle(fontSize: 48))),
              ),
              const SizedBox(height: 20),
              const Text(
                'StudyMate AI',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primary),
              ),
              const SizedBox(height: 8),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5),
              ),
            ],
          ),
        ),
      );
    }

    // 2. Not Authenticated -> Login
    if (!authProvider.isAuthenticated) {
      return const LoginScreen();
    }

    // 3. Authenticated but haven't finished Onboarding -> Onboarding
    if (!authProvider.hasCompletedOnboarding) {
      return const OnboardingScreen();
    }

    // 4. Authenticated & Onboarded -> Main Navigation Dashboard
    return const MainNavigationScreen();
  }
}
