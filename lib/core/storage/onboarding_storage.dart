import 'package:shared_preferences/shared_preferences.dart';

class OnboardingStorage {
  static const _completedKey = 'ONBOARDING_COMPLETED';

  Future<bool> isCompleted() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_completedKey) ?? false;
  }

  Future<void> markCompleted() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_completedKey, true);
  }
}
