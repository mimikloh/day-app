import 'dart:developer';

import 'package:day_app/providers/category_provider.dart';
import 'package:day_app/providers/habit_provider.dart';
import 'package:day_app/providers/task_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';

import 'data/models/category.dart';
import 'data/models/habit.dart';
import 'data/models/task.dart';
import 'router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseMessaging.instance.getToken();

  await initializeDateFormatting('ru_RU', null);

  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(HabitAdapter());
  await Hive.openBox<Task>('tasks');
  await Hive.openBox<Category>('categories');
  await Hive.openBox<Habit>('habits');

  runApp(const ProviderScope(child: DayApp()));
}

class DayApp extends ConsumerStatefulWidget {
  const DayApp({super.key});

  @override
  ConsumerState<DayApp> createState() => _DayAppState();
}

class _DayAppState extends ConsumerState<DayApp> {
  @override
  void initState() {
    super.initState();

    // ←←← ЕДИНСТВЕННЫЙ СЛУШАТЕЛЬ — ЗДЕСЬ
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      final taskSync = ref.read(taskSyncRepositoryProvider);
      final categorySync = ref.read(categorySyncRepositoryProvider);
      final habitSync = ref.read(habitSyncRepositoryProvider);

      if (user != null) {
        // Вход — синхронизируем с облака
        await taskSync.syncFromCloud();
        await categorySync.syncFromCloud();
        await habitSync.syncFromCloud();
      } else {
        // Выход — очищаем локальные данные
        await taskSync.clearLocal();
        await categorySync.clearLocal();
        await habitSync.clearLocal();
      }

      // Обновляем UI
      ref.invalidate(tasksProvider);
      ref.invalidate(categoriesProvider);
      ref.invalidate(habitsProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeControllerProvider);

    return MaterialApp.router(
      title: 'Day',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        return ColoredBox(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: child,
        );
      },
    );
  }
}