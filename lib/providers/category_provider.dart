import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:day_app/data/models/category.dart';
import 'package:day_app/data/sync/category_sync_repository.dart';
import 'package:day_app/data/repositories/hive_category_repository.dart';
import 'package:day_app/data/remote/rtdb_category_repository.dart';

final categorySyncRepositoryProvider = Provider<CategorySyncRepository>((ref) {
  return CategorySyncRepository(
    hive: HiveCategoryRepository(),
    rtdb: RtdbCategoryRepository(),
  );
});

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  return await ref.watch(categorySyncRepositoryProvider).getAll();
});

final categoryNotifierProvider = StateNotifierProvider<CategoryNotifier, AsyncValue<void>>((ref) {
  return CategoryNotifier(ref);
});

class CategoryNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  CategoryNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> addCategory(Category category) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(categorySyncRepositoryProvider).add(category);
      ref.invalidate(categoriesProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateCategory(Category category) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(categorySyncRepositoryProvider).update(category);
      ref.invalidate(categoriesProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteCategory(String id) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(categorySyncRepositoryProvider).delete(id);
      ref.invalidate(categoriesProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}