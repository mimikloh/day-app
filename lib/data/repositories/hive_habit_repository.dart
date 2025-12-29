import 'package:hive/hive.dart';
import 'package:day_app/data/models/habit.dart';

class HiveHabitRepository {
  final Box<Habit> _box = Hive.box<Habit>('habits');

  Future<List<Habit>> getAll() async {
    return _box.values.toList();
  }

  Future<void> add(Habit habit) async {
    await _box.put(habit.id, habit);
  }

  Future<void> update(Habit updatedHabit) async {
    await _box.put(updatedHabit.id, updatedHabit);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> saveAll(List<Habit> habits) async {
    await _box.clear();
    for (var habit in habits) {
      await _box.put(habit.id, habit);
    }
  }
}