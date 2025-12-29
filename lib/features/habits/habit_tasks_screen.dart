import 'package:day_app/features/home/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:day_app/core/theme/app_colors.dart';
import 'package:day_app/providers/habit_provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/habit_card.dart';
import '../../core/theme/progress_controller.dart';
import '../../data/models/habit.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/habit_line_painter.dart';
import '../../widgets/habit_ring_painter.dart';

class HabitTasksScreen extends ConsumerWidget {
  const HabitTasksScreen({super.key});

  String getGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    return switch (hour) {
      < 6 => 'Доброй ночи',
      < 12 => 'Доброе утро',
      < 18 => 'Добрый день',
      _ => 'Добрый вечер',
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsProvider);

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
                  'Задачи',
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

            // Кольцо активности с адаптивным приветствием
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
                          onTap: () => context.go('/'),
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

            // Заголовок
            Padding(
              padding: const EdgeInsets.only(left: 26, right: 26, top: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Задачи:', style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500, color: AppColors.textPrimary(context))),
              ),
            ),

            const SizedBox(height: 16),

            // Список привычек
            Expanded(
              child: habitsAsync.when(
                data: (habits) {
                  if (habits.isEmpty) {
                    return Center(
                      child: Text(
                        'Нет активных задач',
                        style: TextStyle(color: AppColors.textSecondary(context), fontSize: 16),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 26),
                    itemCount: habits.length,
                    itemBuilder: (context, index) {
                      final habit = habits[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Slidable(
                          key: ValueKey(habit.id),
                          endActionPane: ActionPane(
                            motion: const StretchMotion(),
                            extentRatio: 0.3,
                            dismissible: DismissiblePane(
                              onDismissed: () async {
                                await ref.read(habitNotifierProvider.notifier).deleteHabit(habit.id);
                                ref.invalidate(habitsProvider);
                              },
                            ),
                            children: [
                              CustomSlidableAction(
                                onPressed: (_) async {
                                  await ref.read(habitNotifierProvider.notifier).deleteHabit(habit.id);
                                  ref.invalidate(habitsProvider);
                                },
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: double.infinity,
                                  child: ClipRect(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.delete, size: 32),
                                        const SizedBox(height: 6),
                                        const Text(
                                          'Удалить',
                                          maxLines: 1,
                                          overflow: TextOverflow.clip,
                                          softWrap: false,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          child: HabitCardBody(habit: habit),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => Center(child: Text('Ошибка', style: TextStyle(color: AppColors.textPrimary(context)))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}