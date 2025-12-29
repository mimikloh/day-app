import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:day_app/data/models/task.dart';
import 'package:day_app/data/repositories/hive_task_repository.dart';
import 'package:day_app/data/remote/rtdb_task_repository.dart';

class TaskSyncRepository {
  final HiveTaskRepository hive;
  final RtdbTaskRepository rtdb;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  TaskSyncRepository({
    required this.hive,
    required this.rtdb,
  });

  Future<List<Task>> getAll() async {
    final user = _auth.currentUser;

    if (user != null) {
      await syncFromCloud();
    }

    return await hive.getAll();
  }


  Future<void> add(Task task) async {
    await hive.add(task);

    final user = _auth.currentUser;
    if (user != null) {
      try {
        await rtdb.uploadTask(task);
      } catch (e) {
        // Логируем, но не крашим приложение
        log('RTDB sync error: $e');
      }
    }
  }
  Future<void> delete(String id) async {
    await hive.delete(id);

    final user = _auth.currentUser;
    if (user != null) {
      try {
        await rtdb.deleteTask(id);
      } catch (e) {
        log('RTDB sync error: $e');
      }
    }
  }

  //Синхронизация при логине / старте
  Future<void> syncFromCloud() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final cloudTasks = await rtdb.fetchAll();
    if (cloudTasks.isEmpty) return;

    await hive.saveAll(cloudTasks);
  }
  Future<void> clearLocal() async {
    await hive.saveAll([]);
  }
}
