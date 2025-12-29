
import 'package:hive/hive.dart';
import 'package:day_app/data/models/category.dart';

class HiveCategoryRepository {
  final Box<Category> _box = Hive.box<Category>('categories');

  Future<List<Category>> getAll() async {
    return _box.values.toList();
  }

  Future<void> add(Category category) async {
    await _box.put(category.id, category);
  }

  Future<void> update(Category category) async {
    await _box.put(category.id, category);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> saveAll(List<Category> categories) async {
    await _box.clear();
    for (var cat in categories) {
      await _box.put(cat.id, cat);
    }
  }
}