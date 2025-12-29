import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:day_app/core/theme/app_colors.dart';
import 'package:day_app/data/models/task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:day_app/providers/task_provider.dart';
import '../../data/models/category.dart';
import '../../providers/category_provider.dart';

class DismissibleTaskCard extends ConsumerWidget {
  final Task task;
  final VoidCallback? onDeleted;

  const DismissibleTaskCard({
    super.key,
    required this.task,
    this.onDeleted,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Slidable(
      key: ValueKey(task.id),

      endActionPane: ActionPane(
        motion: const StretchMotion(),
        extentRatio: 0.3,

        dismissible: DismissiblePane(
          onDismissed: () async {
            await ref.read(taskNotifierProvider.notifier).deleteTask(task.id);
            ref.invalidate(tasksProvider);
            onDeleted?.call();
          },
        ),

        children: [
          CustomSlidableAction(
            onPressed: (_) async {
              await ref.read(taskNotifierProvider.notifier).deleteTask(task.id);
              ref.invalidate(tasksProvider);
              onDeleted?.call();
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
                    Text(
                      'Удалить',
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      softWrap: false,
                      style: const TextStyle(
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

      child: _TaskCardBody(task: task),
    );
  }
}

class _TaskCardBody extends ConsumerWidget {
  final Task task;

  const _TaskCardBody({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 360,
      height: 90,
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Stack(
        children: [
          // Градиент
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                begin: const Alignment(0.5, -1.0),
                end: const Alignment(-0.6, 2.0),
                colors: [
                  task.color.withOpacity(0.2),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.46],
              ),
            ),
          ),


          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      task.time,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary(context),
                      ),
                    ),

                    // Категория
                    Consumer(
                      builder: (context, ref, _) {
                        final categoriesAsync = ref.watch(categoriesProvider);
                        return categoriesAsync.when(
                          data: (categories) {
                            final category = categories.firstWhere(
                                  (c) => c.id == task.categoryId,
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
                                fontSize: 16,
                                color: AppColors.textSecondary(context),
                              ),
                            );
                          },
                          loading: () => const SizedBox(),
                          error: (_, __) => const Text('?'),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ИКОНКА КАТЕГОРИИ
          Positioned(
            right: 12,
            top: 10,
            child: Consumer(
              builder: (context, ref, _) {
                final categoriesAsync = ref.watch(categoriesProvider);
                return categoriesAsync.when(
                  data: (categories) {
                    final category = categories.firstWhere(
                          (c) => c.id == task.categoryId,
                      orElse: () => Category.create(
                        id: '',
                        name: 'Без тематики',
                        color: Colors.grey,
                        iconPath: 'assets/icons/default.png',
                      ),
                    );
                    return Image.asset(
                      category.iconPath,
                      width: 44,
                      height: 44,
                      fit: BoxFit.contain,
                    );
                  },
                  loading: () => const SizedBox(width: 44, height: 44),
                  error: (_, __) => const Icon(Icons.error, size: 44),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}