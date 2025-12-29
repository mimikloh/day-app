import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:day_app/data/models/category.dart';
import 'package:day_app/data/repositories/hive_category_repository.dart';
import 'package:day_app/data/remote/rtdb_category_repository.dart';

class CategorySyncRepository {
  final HiveCategoryRepository hive;
  final RtdbCategoryRepository rtdb;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CategorySyncRepository({
    required this.hive,
    required this.rtdb,
  });

  Future<List<Category>> getAll() async {
    final user = _auth.currentUser;

    if (user != null) {
      await syncFromCloud();
    }

    return await hive.getAll();
  }

  Future<void> add(Category category) async {
    await hive.add(category);

    final user = _auth.currentUser;
    if (user != null) {
      try {
        await rtdb.uploadCategory(category);
      } catch (e) {
        log('RTDB category sync error: $e');
      }
    }
  }

  Future<void> update(Category category) async {
    await hive.update(category);

    final user = _auth.currentUser;
    if (user != null) {
      try {
        await rtdb.uploadCategory(category);
      } catch (e) {
        log('RTDB category sync error: $e');
      }
    }
  }

  Future<void> delete(String id) async {
    await hive.delete(id);

    final user = _auth.currentUser;
    if (user != null) {
      try {
        await rtdb.deleteCategory(id);
      } catch (e) {
        log('RTDB category sync error: $e');
      }
    }
  }

  Future<void> syncFromCloud() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final cloudCategories = await rtdb.fetchAll();
    if (cloudCategories.isEmpty) return;

    await hive.saveAll(cloudCategories);
  }
  Future<void> clearLocal() async {
    await hive.saveAll([]); // очищает Hive
  }
}