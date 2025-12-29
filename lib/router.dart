import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_colors.dart';
import 'features/add_task/add_task_screen.dart';
import 'features/habits/habit_tasks_screen.dart';
import 'features/home/home_screen.dart';
import 'features/schedule/schedule_screen.dart';
import 'features/themes/themes_screen.dart';
import 'features/settings/settings_screen.dart';
import 'widgets/custom_bottom_bar.dart'; // ← наш новый навбар

final router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => const NoTransitionPage(child: HomeScreen()),
        ),
        GoRoute(
          path: '/schedule',
          pageBuilder: (context, state) => const NoTransitionPage(child: ScheduleScreen()),
        ),
        GoRoute(
          path: '/themes',
          pageBuilder: (context, state) => const NoTransitionPage(child: ThemesScreen()),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => const NoTransitionPage(child: SettingsScreen()),
        ),
      ],
    ),

    GoRoute(
      path: '/add-task',
      pageBuilder: (context, state) {
        final fromPath = state.extra as String?; // ← получаем путь
        return MaterialPage(
          child: AddTaskScreen(returnPath: fromPath),
          fullscreenDialog: false,
        );
      },
    ),
    GoRoute(
      path: '/habits',
      pageBuilder: (_, __) => const NoTransitionPage(child: HabitTasksScreen()),
    ),
  ],
);

class MainScaffold extends StatefulWidget {
  final Widget child;
  const MainScaffold({required this.child, super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int get currentIndex {
    final location = GoRouterState.of(context).uri.path;
    return switch (location) {
      '/' => 0,
      '/schedule' => 1,
      '/themes' => 2,
      '/settings' => 3,
      _ => 0,
    };
  }

  void _onTap(int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/schedule');
        break;
      case 2:
        context.go('/themes');
        break;
      case 3:
        context.go('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,   // ← 1 строчка (в самое начало Scaffold)

      body: SafeArea(
        bottom: false,                   // ← 2 строчка (выключаем стандартный отступ снизу)
        child: widget.child,
      ),

      bottomNavigationBar: CustomBottomBar(
        currentIndex: currentIndex,
        onTap: _onTap,
      ),
    );
  }
}