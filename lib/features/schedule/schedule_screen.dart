import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:day_app/core/theme/app_colors.dart';

import '../../providers/task_provider.dart';
import '../../widgets/dismissible_task_card.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  late final tasksAsync = ref.watch(tasksProvider);

  late PageController _pageController;
  late DateTime _currentMonday;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _currentMonday = _getMondayOfWeek(DateTime.now());
    _pageController = PageController(initialPage: 1000);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  DateTime _getMondayOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentMonday = _getMondayOfWeek(DateTime.now())
          .add(Duration(days: 7 * (page - 1000)));
    });
  }

  List<DateTime> _getCurrentWeekDays() {
    return List.generate(7, (i) => _currentMonday.add(Duration(days: i)));
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }


  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final refresh = GoRouterState.of(context).uri.queryParameters['refresh'];
      if (refresh == '1') {
        ref.refresh(tasksProvider); // ← мгновенно обновляет список задач
      }
    });

    final tasksAsync = ref.watch(tasksProvider);
    final weekDays = _getCurrentWeekDays();
    final dayFormatter = DateFormat('d');
    final weekdayFormatter = DateFormat('EEE', 'ru_RU');

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
                  'Расписание',
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

            const SizedBox(height: 10),

            // Неделя
            SizedBox(
              height: 65,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  final monday = _getMondayOfWeek(DateTime.now()).add(Duration(days: 7 * (index - 1000)));
                  final days = List.generate(7, (i) => monday.add(Duration(days: i)));

                  return Row(
                    children: days.map((date) {
                      final isSelected = _selectedDate.year == date.year &&
                          _selectedDate.month == date.month &&
                          _selectedDate.day == date.day;
                      final isToday = _isToday(date);

                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedDate = date),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.accentBlue : Colors.transparent,
                              borderRadius: BorderRadius.circular(15),
                              border: isToday && !isSelected
                                  ? Border.all(color: AppColors.accentBlue, width: 2.5)
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  dayFormatter.format(date),
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : null,
                                  ),
                                ),
                                Text(
                                  weekdayFormatter.format(date).toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? Colors.white : (isToday ? AppColors.accentBlue : Colors.grey[600]),
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
              ),
            ),

            const SizedBox(height: 16),

            // Заголовок выбранного дня
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  DateFormat('d MMMM, EEEE', 'ru_RU').format(_selectedDate),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary(context)),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Карточки
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26), // ← 26px слева и справа
                child: tasksAsync.when(
                  data: (tasks) {
                    final dayTasks = tasks.where((t) =>
                    t.date.year == _selectedDate.year &&
                        t.date.month == _selectedDate.month &&
                        t.date.day == _selectedDate.day).toList();

                    if (dayTasks.isEmpty) {
                      return Center(
                        child: Text(
                          'Нет задач на этот день',
                          style: TextStyle(color: AppColors.textSecondary(context), fontSize: 16),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: EdgeInsets.zero, // ← убираем лишний padding
                      itemCount: dayTasks.length,
                      itemBuilder: (context, index) {
                        final task = dayTasks[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10), // ← расстояние между карточками
                          child: DismissibleTaskCard(task: task),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const Center(child: Text('Ошибка загрузки задач')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Данные задачи для расписания
class _ScheduleTaskData {
  final String title, time, category;
  final Color color;
  final String iconPath;

  _ScheduleTaskData(this.title, this.time, this.category, this.color, this.iconPath);
}

class _ScheduleTaskCard extends StatelessWidget {
  final String title, time, category, iconPath;
  final Color color;

  const _ScheduleTaskCard({
    required this.title,
    required this.time,
    required this.category,
    required this.color,
    required this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
                colors: [color.withOpacity(0.2), Colors.transparent],
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

          // PNG иконка
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