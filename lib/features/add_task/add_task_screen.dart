import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/category.dart';
import '../../data/models/task.dart';
import '../../data/models/habit.dart';
import '../../providers/task_provider.dart';
import '../../providers/habit_provider.dart';
import '../../providers/category_provider.dart';
import '../../widgets/add_category_screen.dart';

class AddTaskScreen extends ConsumerStatefulWidget {
  final String? returnPath;

  const AddTaskScreen({super.key, this.returnPath});

  @override
  ConsumerState<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends ConsumerState<AddTaskScreen> {
  final _titleController = TextEditingController();
  TimeOfDay? _selectedTime;
  DateTime _selectedDate = DateTime.now();
  Category? _selectedCategory;

  bool _isHabit = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
    resizeToAvoidBottomInset: false,
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
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, size: 28),
            onPressed: () {
              final path = widget.returnPath ?? '/';
              context.go(path);
            },
            color: AppColors.textPrimary(context),
          ),
          title: Text(
            'Новая задача',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary(context),
            ),
          ),
          centerTitle: true,
        ),
      ),

      // ОСНОВНОЙ КОНТЕНТ
      Expanded(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Название
              TextField(
                controller: _titleController,
                style: TextStyle(fontSize: 18, color: AppColors.textPrimary(context)),
                decoration: InputDecoration(
                  hintText: 'Название задачи',
                  hintStyle: TextStyle(color: AppColors.textSecondary(context)),
                  filled: true,
                  fillColor: AppColors.card(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),

              const SizedBox(height: 20),

              // Переключатель: с временем / без времени
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildModeButton('С временем', !_isHabit),
                  const SizedBox(width: 16),
                  _buildModeButton('Без времени', _isHabit),
                ],
              ),

              const SizedBox(height: 20),

              // Если выбрано "С временем"
              if (!_isHabit) ...[
                ListTile(
                  onTap: () async {
                    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                    if (time != null) setState(() => _selectedTime = time);
                  },
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  tileColor: AppColors.card(context),
                  leading: Icon(Icons.access_time, color: AppColors.textSecondary(context)),
                  title: Text(
                    _selectedTime == null ? 'Выбрать время' : _selectedTime!.format(context),
                    style: TextStyle(fontSize: 16, color: AppColors.textPrimary(context)),
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) setState(() => _selectedDate = date);
                  },
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  tileColor: AppColors.card(context),
                  leading: Icon(Icons.calendar_today, color: AppColors.textSecondary(context)),
                  title: Text(
                    DateFormat('d MMMM yyyy', 'ru').format(_selectedDate),
                    style: TextStyle(fontSize: 16, color: AppColors.textPrimary(context)),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Выпадающий список тематик
              categoriesAsync.when(
                data: (categories) => LayoutBuilder(
                  builder: (context, constraints) {
                    final buttonWidth = constraints.maxWidth;

                    return Theme(
                      data: Theme.of(context).copyWith(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                      ),
                      child: PopupMenuButton<Category>(
                        onSelected: (value) => setState(() => _selectedCategory = value),
                        offset: const Offset(0, 70),
                        constraints: BoxConstraints(
                          minWidth: buttonWidth,
                          maxWidth: buttonWidth,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        color: AppColors.card(context),
                        elevation: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.card(context),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _selectedCategory?.name ?? 'Выбрать тематику',
                                  style: TextStyle(fontSize: 16, color: AppColors.textPrimary(context)),
                                ),
                              ),
                              Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary(context)),
                            ],
                          ),
                        ),
                        itemBuilder: (context) => [
                          ...categories.map((c) => PopupMenuItem(
                            value: c,
                            child: SizedBox(
                              width: buttonWidth - 32,
                              child: Text(
                                c.name,
                                style: TextStyle(color: AppColors.textPrimary(context)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )),
                          PopupMenuItem(
                            enabled: false,
                            height: 48,
                            child: GestureDetector(
                              onTap: () async {
                                Navigator.of(context).pop();
                                await Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const AddCategoryScreen()),
                                );
                                ref.refresh(categoriesProvider);
                              },
                              child: Row(
                                children: [
                                  Icon(Icons.add_circle_outline, color: AppColors.accentBlue, size: 24),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Добавить новую тематику',
                                      style: TextStyle(
                                        color: AppColors.accentBlue,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                loading: () => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  decoration: BoxDecoration(
                    color: AppColors.card(context),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                error: (_, __) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  decoration: BoxDecoration(
                    color: AppColors.card(context),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    'Ошибка',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),

              const Spacer(),

              // Кнопка сохранить
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 8,
                  ),
                  onPressed: () async {
                    if (_titleController.text.isEmpty || _selectedCategory == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Заполните название и тематику')),
                      );
                      return;
                    }

                    if (_isHabit) {
                      final habit = Habit.create(
                        id: const Uuid().v4(),
                        title: _titleController.text,
                        categoryId: _selectedCategory!.id,
                        color: _selectedCategory!.color,
                      );
                      await ref.read(habitNotifierProvider.notifier).addHabit(habit);
                      ref.invalidate(habitsProvider);
                    } else {
                      final task = Task.create(
                        id: const Uuid().v4(),
                        title: _titleController.text,
                        time: _selectedTime!.format(context),
                        date: _selectedDate,
                        categoryId: _selectedCategory!.id,
                        iconPath: _selectedCategory!.iconPath,
                        color: _selectedCategory!.color,
                      );
                      await ref.read(taskNotifierProvider.notifier).addTask(task);
                      ref.invalidate(tasksProvider);
                    }

                    if (context.mounted) {
                      final returnPath = widget.returnPath ?? '/';
                      final newPath = returnPath.contains('?')
                          ? '$returnPath&refresh=1'
                          : '$returnPath?refresh=1';
                      context.go(newPath);
                    }
                  },
                  child: Text(
                    _isHabit ? 'Добавить задачу' : 'Добавить в расписание',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
        ],
      ),
    ),
    );
  }

  Widget _buildModeButton(String text, bool isActive) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isHabit = (text == 'Без времени');
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppColors.accentBlue : AppColors.card(context),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? Colors.white : AppColors.textSecondary(context),
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}