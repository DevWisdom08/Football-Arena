import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';

class StorageService {
  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();
  
  StorageService._();

  late SharedPreferences _prefs;
  late Box _box;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await Hive.initFlutter();
    _box = await Hive.openBox('football_arena');
  }

  // String operations
  Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  // Int operations
  Future<bool> setInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }

  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  // Bool operations
  Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  // Double operations
  Future<bool> setDouble(String key, double value) async {
    return await _prefs.setDouble(key, value);
  }

  double? getDouble(String key) {
    return _prefs.getDouble(key);
  }

  // Complex object operations using Hive
  Future<void> saveObject(String key, dynamic value) async {
    await _box.put(key, value);
  }

  dynamic getObject(String key) {
    return _box.get(key);
  }

  // Remove operations
  Future<bool> remove(String key) async {
    await _box.delete(key);
    return await _prefs.remove(key);
  }

  // Clear all
  Future<void> clearAll() async {
    await _box.clear();
    await _prefs.clear();
  }

  // Auth token helpers
  Future<void> saveAuthToken(String token) async {
    await setString(AppConstants.keyAuthToken, token);
  }

  String? getAuthToken() {
    return getString(AppConstants.keyAuthToken);
  }

  Future<void> removeAuthToken() async {
    await remove(AppConstants.keyAuthToken);
  }

  bool get isAuthenticated => getAuthToken() != null;

  // User ID helpers
  Future<void> saveUserId(String userId) async {
    await setString(AppConstants.keyUserId, userId);
  }

  String? getUserId() {
    return getString(AppConstants.keyUserId);
  }

  // Language helpers
  Future<void> saveLanguage(String languageCode) async {
    await setString(AppConstants.keyLanguage, languageCode);
  }

  String getLanguage() {
    return getString(AppConstants.keyLanguage) ?? 'en';
  }

  // Streak helpers
  Future<void> saveStreak(int streak) async {
    await setInt(AppConstants.keyStreak, streak);
  }

  int getStreak() {
    return getInt(AppConstants.keyStreak) ?? 0;
  }

  Future<void> saveLastPlayDate(DateTime date) async {
    await setString(AppConstants.keyLastPlayDate, date.toIso8601String());
  }

  DateTime? getLastPlayDate() {
    final dateString = getString(AppConstants.keyLastPlayDate);
    if (dateString != null) {
      return DateTime.parse(dateString);
    }
    return null;
  }

  // Clear auth data
  Future<void> clearAuthData() async {
    await removeAuthToken();
    await remove(AppConstants.keyUserId);
    await remove(AppConstants.keyUserData);
  }

  // Save user data
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await saveObject(AppConstants.keyUserData, userData);
  }

  // Get user data
  Map<String, dynamic>? getUserData() {
    final data = getObject(AppConstants.keyUserData);
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }
}

