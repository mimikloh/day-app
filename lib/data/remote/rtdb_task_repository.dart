import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart'; // ← добавил импорт
import 'package:day_app/data/models/task.dart';

class RtdbTaskRepository {
  final FirebaseDatabase _db = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://raspisanie-625fb-default-rtdb.europe-west1.firebasedatabase.app',
  );
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DatabaseReference _userTasksRef(String uid) {
    return _db.ref('users/$uid/tasks');
  }

  Future<void> uploadTask(Task task) async {
    log('RTDB ADD CALLED');

    final user = _auth.currentUser;
    if (user == null) {
      log('RTDB: user is null');
      return;
    }

    log('RTDB UID: ${user.uid}');

    await _userTasksRef(user.uid).child(task.id).set({
      ...task.toJson(),
      'updatedAt': ServerValue.timestamp,
    });

    log('RTDB: task uploaded');
  }

  Future<void> deleteTask(String taskId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _userTasksRef(user.uid).child(taskId).remove();
  }

  Future<List<Task>> fetchAll() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final snapshot = await _userTasksRef(user.uid).get();
    if (!snapshot.exists) return [];

    final data = Map<String, dynamic>.from(snapshot.value as Map);

    return data.values
        .map((e) => Task.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}