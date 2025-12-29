import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final progressControllerProvider = StateNotifierProvider<ProgressController, String>((ref) {
  return ProgressController();
});

class ProgressController extends StateNotifier<String> {
  ProgressController() : super('ring') {  // по умолчанию 'ring'
    _loadProgressType();
  }

  Future<void> _loadProgressType() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('progress_type');
    state = saved ?? 'ring';
  }

  Future<void> setProgressType(String type) async {
    state = type;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('progress_type', type);
  }
}