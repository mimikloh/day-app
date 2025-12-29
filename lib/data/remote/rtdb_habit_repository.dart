import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:day_app/data/models/habit.dart';

class RtdbHabitRepository {
  final FirebaseDatabase _db = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://raspisanie-625fb-default-rtdb.europe-west1.firebasedatabase.app',
  );
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DatabaseReference _userHabitsRef(String uid) {
    return _db.ref('users/$uid/habits');
  }

  Future<void> uploadHabit(Habit habit) async {
    log('RTDB HABIT ADD CALLED');

    final user = _auth.currentUser;
    if (user == null) {
      log('RTDB: user is null');
      return;
    }

    log('RTDB UID: ${user.uid}');

    await _userHabitsRef(user.uid).child(habit.id).set({
      ...habit.toJson(),
      'updatedAt': ServerValue.timestamp,
    });

    log('RTDB: habit uploaded');
  }

  Future<void> deleteHabit(String habitId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _userHabitsRef(user.uid).child(habitId).remove();
  }

  Future<List<Habit>> fetchAll() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final snapshot = await _userHabitsRef(user.uid).get();
    if (!snapshot.exists) return [];

    final data = Map<String, dynamic>.from(snapshot.value as Map);

    return data.values
        .map((e) => Habit.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}