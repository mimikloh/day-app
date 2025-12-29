import 'package:hive/hive.dart';
import 'package:day_app/data/models/task.dart';

class HiveTaskRepository {
  final Box<Task> _box = Hive.box<Task>('tasks');

  Future<List<Task>> getAll() async {
    return _box.values.toList();
  }

  Future<void> add(Task task) async {
    await _box.put(task.id, task);
  }

  Future<void> update(Task task) async {
    await _box.put(task.id, task);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> saveAll(List<Task> tasks) async {
    await _box.clear();
    for (var task in tasks) {
      await _box.put(task.id, task);
    }
  }
}