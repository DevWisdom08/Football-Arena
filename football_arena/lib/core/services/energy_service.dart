import 'package:shared_preferences/shared_preferences.dart';

class EnergyService {
  static const String _keyEnergy = 'user_energy';
  static const String _keyMaxEnergy = 'user_max_energy';
  static const String _keyLastRefillTime = 'last_energy_refill_time';

  static const int defaultMaxEnergy = 5;
  static const int refillTimeMinutes = 30; // Energy refills every 30 minutes

  static Future<int> getEnergy() async {
    final prefs = await SharedPreferences.getInstance();
    final currentEnergy = prefs.getInt(_keyEnergy) ?? defaultMaxEnergy;
    final lastRefill = prefs.getInt(_keyLastRefillTime) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    // Calculate how many energy points should have been refilled
    final minutesPassed = (now - lastRefill) ~/ (1000 * 60);
    final energyToAdd = minutesPassed ~/ refillTimeMinutes;

    if (energyToAdd > 0) {
      final maxEnergy = prefs.getInt(_keyMaxEnergy) ?? defaultMaxEnergy;
      final newEnergy = (currentEnergy + energyToAdd).clamp(0, maxEnergy);
      await prefs.setInt(_keyEnergy, newEnergy);
      await prefs.setInt(_keyLastRefillTime, now);
      return newEnergy;
    }

    return currentEnergy;
  }

  static Future<int> getMaxEnergy() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyMaxEnergy) ?? defaultMaxEnergy;
  }

  static Future<bool> useEnergy(int amount) async {
    final currentEnergy = await getEnergy();
    if (currentEnergy < amount) {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyEnergy, currentEnergy - amount);
    return true;
  }

  static Future<void> refillEnergyWithCoins(int coinsCost) async {
    final prefs = await SharedPreferences.getInstance();
    final maxEnergy = await getMaxEnergy();
    await prefs.setInt(_keyEnergy, maxEnergy);
    await prefs.setInt(
      _keyLastRefillTime,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  static Future<DateTime?> getNextRefillTime() async {
    final prefs = await SharedPreferences.getInstance();
    final lastRefill = prefs.getInt(_keyLastRefillTime) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    final minutesPassed = (now - lastRefill) ~/ (1000 * 60);
    final minutesUntilNext =
        refillTimeMinutes - (minutesPassed % refillTimeMinutes);

    return DateTime.now().add(Duration(minutes: minutesUntilNext));
  }

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getInt(_keyEnergy) == null) {
      await prefs.setInt(_keyEnergy, defaultMaxEnergy);
      await prefs.setInt(_keyMaxEnergy, defaultMaxEnergy);
      await prefs.setInt(
        _keyLastRefillTime,
        DateTime.now().millisecondsSinceEpoch,
      );
    }
  }
}
