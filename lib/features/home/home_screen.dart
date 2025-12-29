import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:day_app/features/habits/habit_tasks_screen.dart';
import 'package:day_app/core/theme/app_colors.dart';
import 'package:day_app/widgets/custom_bottom_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';


import '../../core/theme/progress_controller.dart';
import '../../providers/habit_provider.dart';
import '../../providers/task_provider.dart';
import '../../widgets/dismissible_task_card.dart';
import '../../widgets/habit_line_painter.dart';
import '../../widgets/habit_ring_painter.dart';

final List<_TaskData> _sampleTasks = [
  _TaskData('Теоретическое занятие', '19:00', 'Автошкола', const Color(0xFF973928), 'assets/icons/isometric/icons8-sedan-50.png'),
  _TaskData('Математика(Матвей)', '19:00', 'Тетрика', const Color(0xFF1565C0), 'assets/icons/isometric/icons8-book-50.png'),
  _TaskData('Валорант', '20:00', 'Игрульки', const Color(0xFF7B1FA2), 'assets/icons/isometric/icons8-game-controller-50.png'),
  _TaskData('Дота', '21:00', 'Игрульки', const Color(0xFF2E7D32), 'assets/icons/isometric/icons8-game-controller-50.png'),
  _TaskData('Тренировка', '18:00', 'Спорт', const Color(0xFF2E7D32), 'assets/icons/isometric/icons8-game-controller-50.png'),
];

String getGreeting(BuildContext context) {
  final hour = DateTime.now().hour;
  return switch (hour) {
    < 6 => 'Доброй ночи',
    < 12 => 'Доброе утро',
    < 18 => 'Добрый день',
    _ => 'Добрый вечер',
  };
}



class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ←←← Принудительно обновляем при появлении ?refresh=1
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final refresh = GoRouterState.of(context).uri.queryParameters['refresh'];
      if (refresh == '1') {
        ref.refresh(tasksProvider); // мгновенно обновит
      }
    });

    final tasksAsync = ref.watch(tasksProvider);
    final progressType = ref.watch(progressControllerProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [

            Container(
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.card(context),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0, 4),
                    blurRadius: 10,
                    color: Colors.black.withOpacity(0.1),
                  ),
                ],
              ),
              child: AppBar(
                title: Text(
                  'Главная',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                centerTitle: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading: false,
              ),
            ),

            const SizedBox(height: 20),

            // ←←← КОЛЬЦО АКТИВНОСТИ С АДАПТИВНЫМ ПРИВЕТСТВИЕМ
            SizedBox(
              height: 180,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26),
                child: Consumer(
                  builder: (context, ref, child) {
                    final habitsAsync = ref.watch(habitsProvider);
                    final progressType = ref.watch(progressControllerProvider);

                    return habitsAsync.when(
                      data: (habits) {
                        final completed = habits.where((h) => h.completed).length;
                        final total = habits.length;
                        final progress = total == 0 ? 0.0 : completed / total;
                        final percent = (progress * 100).round();

                        return GestureDetector(
                          onTap: () => context.go('/habits'),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.card(context),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(offset: const Offset(0, 6), blurRadius: 3, color: Colors.black.withOpacity(0.25)),
                              ],
                            ),
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Прогресс — в зависимости от типа
                                Expanded(
                                  child: Center(
                                    child: progressType == 'line'
                                        ? Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // ====== ПРИВЕТСТВИЕ ======
                                        StreamBuilder<User?>(
                                          stream: FirebaseAuth.instance.authStateChanges(),
                                          builder: (context, snapshot) {
                                            final user = snapshot.data;
                                            final name = user?.displayName?.trim();
                                            final greeting = getGreeting(context);

                                            final text = (name != null && name.isNotEmpty)
                                                ? '$greeting, $name!'
                                                : greeting!;

                                            return Text(
                                              text,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.textPrimary(context),
                                              ),
                                            );
                                          },
                                        ),

                                        const Spacer(),

                                        // ====== ЛИНИЯ ======
                                        SizedBox(
                                          width: double.infinity,
                                          height: 40,
                                          child: TweenAnimationBuilder<double>(
                                            tween: Tween<double>(begin: 0.0, end: progress),
                                            duration: const Duration(milliseconds: 900),
                                            curve: Curves.easeOutCubic,
                                            builder: (context, animatedProgress, _) {
                                              return CustomPaint(
                                                painter: HabitLinePainter(
                                                  animatedProgress,
                                                  AppColors.textSecondary(context),
                                                ),
                                              );
                                            },
                                          ),
                                        ),


                                        const SizedBox(height: 6),

                                        // ====== ПОДПИСЬ ======
                                        Text(
                                          'Активность',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: AppColors.textSecondary(context),
                                          ),
                                        ),
                                      ],
                                    )

                                        : Row(
                                      children: [
                                        // ЛЕВАЯ ЧАСТЬ — ТЕКСТ (ОГРАНИЧЕНА)
                                        Expanded(
                                          child: LayoutBuilder(
                                            builder: (context, constraints) {
                                              final isSmall = constraints.maxWidth < 220;

                                              return Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  // Приветствие
                                                  StreamBuilder<User?>(
                                                    stream: FirebaseAuth.instance.authStateChanges(),
                                                    builder: (context, snapshot) {
                                                      final user = snapshot.data;
                                                      final name = user?.displayName?.trim();
                                                      final greeting = getGreeting(context);

                                                      return Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            greeting,
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: TextStyle(
                                                              fontSize: isSmall ? 20 : 24,
                                                              fontWeight: FontWeight.w500,
                                                              color: AppColors.textPrimary(context),
                                                            ),
                                                          ),
                                                          if (name != null && name.isNotEmpty)
                                                            Text(
                                                              name,
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                              style: TextStyle(
                                                                fontSize: isSmall ? 20 : 24,
                                                                fontWeight: FontWeight.w600,
                                                                color: AppColors.textPrimary(context),
                                                              ),
                                                            ),
                                                        ],
                                                      );
                                                    },
                                                  ),

                                                  const Spacer(),

                                                  // Подпись
                                                  Text(
                                                    'Кольцо активности',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: AppColors.textSecondary(context),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        ),

                                        // ПРАВАЯ ЧАСТЬ — КОЛЬЦО (ФИКС)
                                        SizedBox(
                                          width: 140,
                                          height: 140,
                                          child: Center(
                                            child: TweenAnimationBuilder<double>(
                                              tween: Tween(begin: 0.0, end: progress),
                                              duration: const Duration(milliseconds: 1400),
                                              curve: Curves.easeOutQuint,
                                              builder: (context, value, _) {
                                                return Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    CustomPaint(
                                                      size: const Size(140, 140),
                                                      painter: HabitRingPainter(
                                                        value,
                                                        AppColors.textSecondary(context),
                                                      ),
                                                    ),
                                                    Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          'Выполнено',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: AppColors.textSecondary(context),
                                                          ),
                                                        ),
                                                        Text(
                                                          '$completed/$total',
                                                          style: TextStyle(
                                                            fontSize: 20,
                                                            fontWeight: FontWeight.bold,
                                                            color: AppColors.textPrimary(context),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (_, __) => const Center(child: Text('Ошибка')),
                    );
                  },
                ),
              ),
            ),

            // 3. Сегодня + карточки
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 26, right: 26, top: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Сегодня:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: AppColors.textPrimary(context))),
                    const SizedBox(height: 16),

                    Expanded(
                      child: tasksAsync.when(
                        data: (tasks) {
                          final todayTasks = tasks.where((t) =>
                          t.date.year == DateTime.now().year &&
                              t.date.month == DateTime.now().month &&
                              t.date.day == DateTime.now().day).toList();

                          if (todayTasks.isEmpty) {
                            return Center(
                              child: Text(
                                'Нет расписания на сегодня',
                                style: TextStyle(
                                  color: AppColors.textSecondary(context),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: todayTasks.length,
                            itemBuilder: (context, index) {
                              final task = todayTasks[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: DismissibleTaskCard(task: task),
                              );
                            },
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (_, __) => const Center(child: Text('Ошибка загрузки задач')),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskData {
  final String title, time, category;
  final Color color;
  final String iconPath;

  _TaskData(this.title, this.time, this.category, this.color, this.iconPath);
}

// ←←← КАРТОЧКА С PNG
class _TaskCard extends StatelessWidget {
  final String title, time, category, iconPath;
  final Color color;

  const _TaskCard({
    required this.title,
    required this.time,
    required this.category,
    required this.color,
    required this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      height: 90,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Stack(
        children: [
          // Градиент от цвета иконки
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                begin: const Alignment(0.5, -1.0),
                end: const Alignment(-0.6, 2.0),
                colors: [
                  color.withOpacity(0.2),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.46],
              ),
            ),
          ),

          // Тексты
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.textPrimary(context))),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(time, style: TextStyle(fontSize: 16, color: AppColors.textSecondary(context))),
                    Text(category, style: TextStyle(fontSize: 16, color: AppColors.textSecondary(context))),
                  ],
                ),
              ],
            ),
          ),

          Positioned(
            right: 12,
            top: 10,
            child: Image.asset(
              iconPath,
              width: 44,
              height: 44,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}