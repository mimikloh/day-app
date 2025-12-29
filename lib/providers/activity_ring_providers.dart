import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final activityRingTypeProvider = StateNotifierProvider<ActivityRingTypeNotifier, String>((ref) {
  return ActivityRingTypeNotifier();
});

class ActivityRingTypeNotifier extends StateNotifier<String> {
  ActivityRingTypeNotifier() : super('ring') {
    _loadType();
  }

  Future<void> _loadType() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString('activity_ring_type') ?? 'ring';
  }

  Future<void> setType(String type) async {
    state = type;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('activity_ring_type', type);
  }
}