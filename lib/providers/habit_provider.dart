import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:day_app/data/models/habit.dart';
import 'package:day_app/data/sync/habit_sync_repository.dart';
import 'package:day_app/data/repositories/hive_habit_repository.dart';
import 'package:day_app/data/remote/rtdb_habit_repository.dart';

final habitSyncRepositoryProvider = Provider<HabitSyncRepository>((ref) {
  return HabitSyncRepository(
    hive: HiveHabitRepository(),
    rtdb: RtdbHabitRepository(),
  );
});

final habitsProvider = FutureProvider<List<Habit>>((ref) async {
  return await ref.watch(habitSyncRepositoryProvider).getAll();
});

final habitNotifierProvider = StateNotifierProvider<HabitNotifier, AsyncValue<void>>((ref) {
  return HabitNotifier(ref);
});

class HabitNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  HabitNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> addHabit(Habit habit) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(habitSyncRepositoryProvider).add(habit);
      ref.invalidate(habitsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateHabit(Habit habit) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(habitSyncRepositoryProvider).update(habit);
      ref.invalidate(habitsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteHabit(String id) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(habitSyncRepositoryProvider).delete(id);
      ref.invalidate(habitsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  Future<void> deleteHabitsByCategory(String categoryId) async {
    final habits = await ref.read(habitsProvider.future);

    for (final habit in habits.where((h) => h.categoryId == categoryId)) {
      await deleteHabit(habit.id);
    }
  }
}
