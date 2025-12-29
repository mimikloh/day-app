import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:day_app/data/models/task.dart';
import 'package:day_app/data/repositories/hive_task_repository.dart';
import 'package:day_app/data/remote/rtdb_task_repository.dart';
import 'package:day_app/data/sync/task_sync_repository.dart';

final taskSyncRepositoryProvider = Provider<TaskSyncRepository>((ref) {
  return TaskSyncRepository(
    hive: HiveTaskRepository(),
    rtdb: RtdbTaskRepository(),
  );
});


final tasksProvider = FutureProvider<List<Task>>((ref) async {
  return await ref.watch(taskSyncRepositoryProvider).getAll();
});


// Notifier для добавления/удаления
final taskNotifierProvider = StateNotifierProvider<TaskNotifier, AsyncValue<void>>((ref) {
  return TaskNotifier(ref);
});

class TaskNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  TaskNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> addTask(Task task) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(taskSyncRepositoryProvider).add(task);
      ref.invalidate(tasksProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    } finally {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> deleteTask(String id) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(taskSyncRepositoryProvider).delete(id);
      ref.invalidate(tasksProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  Future<void> deleteTasksByCategory(String categoryId) async {
    final tasks = await ref.read(tasksProvider.future);

    for (final task in tasks.where((t) => t.categoryId == categoryId)) {
      await deleteTask(task.id);
    }
  }


}