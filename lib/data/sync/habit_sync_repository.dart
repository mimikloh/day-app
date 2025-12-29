import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:day_app/data/models/habit.dart';
import 'package:day_app/data/repositories/hive_habit_repository.dart';
import 'package:day_app/data/remote/rtdb_habit_repository.dart';

class HabitSyncRepository {
  final HiveHabitRepository hive;
  final RtdbHabitRepository rtdb;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  HabitSyncRepository({
    required this.hive,
    required this.rtdb,
  });

  Future<List<Habit>> getAll() async {
    final user = _auth.currentUser;

    if (user != null) {
      await syncFromCloud();
    }

    return await hive.getAll();
  }

  Future<void> add(Habit habit) async {
    await hive.add(habit);

    final user = _auth.currentUser;
    if (user != null) {
      try {
        await rtdb.uploadHabit(habit);
      } catch (e) {
        log('RTDB habit sync error: $e');
      }
    }
  }

  Future<void> update(Habit habit) async {
    await hive.update(habit);

    final user = _auth.currentUser;
    if (user != null) {
      try {
        await rtdb.uploadHabit(habit);
      } catch (e) {
        log('RTDB habit sync error: $e');
      }
    }
  }

  Future<void> delete(String id) async {
    await hive.delete(id);

    final user = _auth.currentUser;
    if (user != null) {
      try {
        await rtdb.deleteHabit(id);
      } catch (e) {
        log('RTDB habit sync error: $e');
      }
    }
  }

  Future<void> syncFromCloud() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final cloudHabits = await rtdb.fetchAll();
    if (cloudHabits.isEmpty) return;

    await hive.saveAll(cloudHabits);
  }
  Future<void> clearLocal() async {
    await hive.saveAll([]);
  }
}