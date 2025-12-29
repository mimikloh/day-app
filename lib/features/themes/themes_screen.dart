import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:day_app/core/theme/app_colors.dart';
import 'package:day_app/core/theme/theme_controller.dart';
import 'package:day_app/providers/category_provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../core/theme/progress_controller.dart';
import '../../providers/habit_provider.dart';
import '../../providers/task_provider.dart';
import '../../widgets/add_category_screen.dart';

class ThemesScreen extends ConsumerWidget {
  const ThemesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressType = ref.watch(progressControllerProvider);
    final themeMode = ref.watch(themeControllerProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

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
                'Моя тема',
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
          // ←←← ОСНОВНОЙ КОНТЕНТ
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [

                const Text('Тема приложения', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.card(context),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      _buildRadioTile(
                        context: context,
                        title: 'Светлая',
                        value: ThemeMode.light,
                        groupValue: themeMode,
                        onChanged: (val) => ref.read(themeControllerProvider.notifier).setTheme(val!),
                      ),
                      _buildRadioTile(
                        context: context,
                        title: 'Тёмная',
                        value: ThemeMode.dark,
                        groupValue: themeMode,
                        onChanged: (val) => ref.read(themeControllerProvider.notifier).setTheme(val!),
                      ),

                      _buildRadioTile(
                        context: context,
                        title: 'Как в системе',
                        value: ThemeMode.system,
                        groupValue: themeMode,
                        onChanged: (val) => ref.read(themeControllerProvider.notifier).setTheme(val!),
                      ),
                    ],
                  ),
                ),

            const SizedBox(height: 32),

            // Кольцо активности
                const Text('Кольцо активности', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.card(context),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      _buildRadioTileProgress(
                        context: context,
                        title: 'Кольцо',
                        value: 'ring',
                        groupValue: progressType,
                        onChanged: (val) => ref.read(progressControllerProvider.notifier).setProgressType(val!),
                      ),
                      _buildRadioTileProgress(
                        context: context,
                        title: 'Линейный прогресс',
                        value: 'line',
                        groupValue: progressType,
                        onChanged: (val) => ref.read(progressControllerProvider.notifier).setProgressType(val!),
                      ),
                    ],
                  ),
                ),


            const SizedBox(height: 40),

            // Мои тематики
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Мои тематики', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, size: 28),
                  onPressed: () async {
                    // Открываем экран добавления тематики
                    await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AddCategoryScreen()),
                    );

                    // Обновляем список тематик — новая сразу появится
                    ref.refresh(categoriesProvider);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
                // УМНОЕ УДАЛЕНИЕ С ПРОВЕРКОЙ И ЗАДАЧ И ПРИВЫЧЕК!
                Consumer(
                  builder: (context, ref, child) {
                    final categoriesAsync = ref.watch(categoriesProvider);
                    final tasksAsync = ref.watch(tasksProvider);
                    final habitsAsync = ref.watch(habitsProvider);

                    return categoriesAsync.when(
                      data: (categories) {
                        if (categories.isEmpty) {
                          return const Center(child: Text('Нет тематик', style: TextStyle(color: Colors.grey, fontSize: 16)));
                        }

                        return tasksAsync.when(
                          data: (tasks) {
                            return habitsAsync.when(
                              data: (habits) {
                                return Column(
                                  children: categories.map((category) {
                                    // Считаем, сколько задач используют эту тематику
                                    final usedInTasks = tasks.where((t) => t.categoryId == category.id).length;

                                    // Считаем, сколько привычек используют эту тематику
                                    final usedInHabits = habits.where((h) => h.categoryId == category.id).length;

                                    // Общее количество использований
                                    final totalUsed = usedInTasks + usedInHabits;

                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: Slidable(
                                        key: ValueKey(category.id),

                                        endActionPane: ActionPane(
                                          motion: const StretchMotion(),
                                          extentRatio: 0.3,

                                          dismissible: totalUsed == 0
                                              ? DismissiblePane(
                                            onDismissed: () async {
                                              await ref
                                                  .read(categoryNotifierProvider.notifier)
                                                  .deleteCategory(category.id);
                                              ref.invalidate(categoriesProvider);
                                            },
                                          )
                                              : null,

                                          children: [
                                            CustomSlidableAction(
                                              onPressed: totalUsed == 0
                                                  ? (_) async {
                                                await ref
                                                    .read(categoryNotifierProvider.notifier)
                                                    .deleteCategory(category.id);
                                                ref.invalidate(categoriesProvider);
                                              }
                                                  : (_) {
                                                _showDeleteWarningDialog(
                                                  context: context,
                                                  ref: ref,
                                                  categoryId: category.id,
                                                  totalUsed: totalUsed,
                                                );
                                              },

                                              backgroundColor: totalUsed == 0 ? Colors.red : Colors.grey,
                                              foregroundColor: Colors.white,
                                              borderRadius: BorderRadius.circular(15),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: totalUsed > 0
                                                    ? [
                                                  const Icon(Icons.delete, size: 32),
                                                  const SizedBox(height: 6),
                                                  Text(  // ← убрали const, потому что внутри totalUsed
                                                    'Используется ($totalUsed)',
                                                    textAlign: TextAlign.center,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    softWrap: false,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ]
                                                    : [
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
                                          ],
                                        ),

                                        child: Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: AppColors.card(context),
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                          child: Row(
                                            children: [
                                              Image.asset(
                                                category.iconPath,
                                                width: 40,
                                                height: 40,
                                                errorBuilder: (_, __, ___) =>
                                                const Icon(Icons.error),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      category.name,
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                    if (totalUsed > 0)
                                                      Text(
                                                        'Используется: $totalUsed (${usedInTasks} задач, ${usedInHabits} привычек)',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: AppColors.textSecondary(context),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                width: 32,
                                                height: 32,
                                                decoration: BoxDecoration(
                                                  color: category.color,
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withOpacity(0.1),
                                                      blurRadius: 4,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                );
                              },
                              loading: () => const Center(child: CircularProgressIndicator()),
                              error: (_, __) => const Center(child: Text('Ошибка загрузки привычек')),
                            );
                          },
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (_, __) => const Center(child: Text('Ошибка загрузки задач')),
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (_, __) => const Center(child: Text('Ошибка загрузки тематик')),
                    );
                  },
                ),
          ],
            ),
          ),
            ],
          ),
        ),
    );
  }
  void _showDeleteWarningDialog({
    required BuildContext context,
    required WidgetRef ref,
    required String categoryId,
    int totalUsed = 0,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Удалить тематику?'),
          content: Text(
            'Эта тематика используется в $totalUsed элементах (задачи и привычки).\n\n'
                'Если удалить тематику, будут удалены ВСЕ связанные с ней задачи и привычки.\n\n'
                'Это действие нельзя отменить.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Отмена'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () async {
                Navigator.of(ctx).pop();

                // Удаляем задачи
                await ref.read(taskNotifierProvider.notifier).deleteTasksByCategory(categoryId);

                // Удаляем привычки
                await ref.read(habitNotifierProvider.notifier).deleteHabitsByCategory(categoryId);

                // Удаляем категорию
                await ref.read(categoryNotifierProvider.notifier).deleteCategory(categoryId);

                // Обновляем UI
                ref.invalidate(tasksProvider);
                ref.invalidate(habitsProvider);
                ref.invalidate(categoriesProvider);
              },
              child: const Text('Всё равно удалить'),
            ),
          ],
        );
      },
    );
  }

  // Передаём context
  Widget _buildRadioTileProgress({
    required BuildContext context,
    required String title,
    required String value,
    required String groupValue,
    required Function(String?) onChanged,
  }) {
    return RadioListTile<String>(
      title: Text(
        title,
        style: TextStyle(fontSize: 16, color: AppColors.textPrimary(context)),
      ),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: AppColors.accentBlue,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      visualDensity: VisualDensity.compact,
    );
  }
  Widget _buildRadioTile({
    required BuildContext context,
    required String title,
    required ThemeMode value,
    required ThemeMode groupValue,
    required Function(ThemeMode?) onChanged,
  }) {
    return RadioListTile<ThemeMode>(
      title: Text(
        title,
        style: TextStyle(fontSize: 16, color: AppColors.textPrimary(context)),
      ),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: AppColors.accentBlue,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildSettingTile({
    required BuildContext context,
    required String title,
    Widget? trailing,
  }) {
    return ListTile(
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      tileColor: AppColors.card(context),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Настройка "$title" — скоро будет!')),
        );
      },
    );
  }
}