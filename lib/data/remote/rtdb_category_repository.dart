import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:day_app/data/models/category.dart';

class RtdbCategoryRepository {
  final FirebaseDatabase _db = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://raspisanie-625fb-default-rtdb.europe-west1.firebasedatabase.app',
  );
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DatabaseReference _userCategoriesRef(String uid) {
    return _db.ref('users/$uid/categories');
  }

  Future<void> uploadCategory(Category category) async {
    log('RTDB CATEGORY ADD CALLED');

    final user = _auth.currentUser;
    if (user == null) {
      log('RTDB: user is null');
      return;
    }

    log('RTDB UID: ${user.uid}');

    await _userCategoriesRef(user.uid).child(category.id).set({
      ...category.toJson(),
      'updatedAt': ServerValue.timestamp,
    });

    log('RTDB: category uploaded');
  }

  Future<void> deleteCategory(String categoryId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _userCategoriesRef(user.uid).child(categoryId).remove();
  }

  Future<List<Category>> fetchAll() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final snapshot = await _userCategoriesRef(user.uid).get();
    if (!snapshot.exists) return [];

    final data = Map<String, dynamic>.from(snapshot.value as Map);

    return data.values
        .map((e) => Category.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}