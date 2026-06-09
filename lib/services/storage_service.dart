import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_settings.dart';
import '../models/progress_data.dart';
import '../utils/alphabet_data.dart';

class StorageService {
  static const _settingsKey = 'game_settings_v1';
  static const _progressFrKey = 'progress_fr_v1';
  static const _progressArKey = 'progress_ar_v1';

  Future<GameSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_settingsKey);
    if (raw == null) return GameSettings();
    try {
      return GameSettings.fromJson(jsonDecode(raw));
    } catch (_) {
      return GameSettings();
    }
  }

  Future<void> saveSettings(GameSettings s) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(s.toJson()));
  }

  Future<ProgressData> loadProgress(Language lang) async {
    final prefs = await SharedPreferences.getInstance();
    final key = lang == Language.french ? _progressFrKey : _progressArKey;
    final raw = prefs.getString(key);
    if (raw == null) return ProgressData();
    try {
      return ProgressData.fromJson(jsonDecode(raw));
    } catch (_) {
      return ProgressData();
    }
  }

  Future<void> saveProgress(Language lang, ProgressData p) async {
    final prefs = await SharedPreferences.getInstance();
    final key = lang == Language.french ? _progressFrKey : _progressArKey;
    await prefs.setString(key, jsonEncode(p.toJson()));
  }

  Future<void> clearProgress(Language lang) async {
    final prefs = await SharedPreferences.getInstance();
    final key = lang == Language.french ? _progressFrKey : _progressArKey;
    await prefs.remove(key);
  }
}
