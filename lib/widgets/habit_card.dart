import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../data/models/category.dart';
import '../data/models/habit.dart';
import '../providers/category_provider.dart';
import '../providers/habit_provider.dart';

class HabitCardBody extends ConsumerWidget {
  final Habit habit;

  const HabitCardBody({super.key, required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 78, //
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              habit.title,
              style: TextStyle(
                fontSize: 17, //
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary(context),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            // Нижняя строка: цвет + категория + чекбокс справа
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Цветной индикатор + название категории
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: habit.color,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Consumer(
                      builder: (context, ref, child) {
                        final categoriesAsync = ref.watch(categoriesProvider);
                        return categoriesAsync.when(
                          data: (categories) {
                            final category = categories.firstWhere(
                                  (c) => c.id == habit.categoryId,
                              orElse: () => Category.create(
                                id: '',
                                name: 'Без тематики',
                                color: Colors.grey,
                                iconPath: 'assets/icons/default.png',
                              ),
                            );
                            return Text(
                              category.name,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary(context),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            );
                          },
                          loading: () => const SizedBox(),
                          error: (_, __) => const Text('Без тематики'),
                        );
                      },
                    ),
                  ],
                ),

                const Spacer(),

                // Чекбокс справа
                Checkbox(
                  value: habit.completed,
                  onChanged: (value) async {
                    final updated = habit.copyWith(completed: value ?? false);
                    await ref.read(habitNotifierProvider.notifier).updateHabit(updated);
                  },
                  activeColor: AppColors.accentBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}