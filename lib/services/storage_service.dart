import 'package:shared_preferences/shared_preferences.dart';
import '../models/history_entry.dart';

/// Persists calculator state across app restarts.
class StorageService {
  static const _keyHistory = 'calc_history';
  static const _keyMemory = 'calc_memory';
  static const _keyLastExpression = 'calc_last_expression';
  static const _keyLastResult = 'calc_last_result';
  static const _keyHapticEnabled = 'settings_haptic';
  static const _keyScientificDefault = 'settings_scientific';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ── History ───────────────────────────────────────────────────────────

  Future<void> saveHistory(List<HistoryEntry> history) async {
    final list = history.take(50).map((e) => e.encode()).toList();
    await _prefs.setStringList(_keyHistory, list);
  }

  List<HistoryEntry> loadHistory() {
    try {
      final list = _prefs.getStringList(_keyHistory);
      if (list == null) return [];
      return list.map((json) => HistoryEntry.decode(json)).toList();
    } catch (_) {
      // Corrupted data — clear and return empty
      _prefs.remove(_keyHistory);
      return [];
    }
  }

  // ── Memory ────────────────────────────────────────────────────────────

  Future<void> saveMemory(double? value) async {
    if (value == null) {
      await _prefs.remove(_keyMemory);
    } else {
      await _prefs.setDouble(_keyMemory, value);
    }
  }

  double? loadMemory() {
    return _prefs.getDouble(_keyMemory);
  }

  // ── Last calculation ──────────────────────────────────────────────────

  Future<void> saveLastCalc(String expression, String result) async {
    await _prefs.setString(_keyLastExpression, expression);
    await _prefs.setString(_keyLastResult, result);
  }

  String get lastExpression => _prefs.getString(_keyLastExpression) ?? '';
  String get lastResult => _prefs.getString(_keyLastResult) ?? '0';

  // ── Settings ──────────────────────────────────────────────────────────

  bool get hapticEnabled => _prefs.getBool(_keyHapticEnabled) ?? true;
  Future<void> setHapticEnabled(bool value) =>
      _prefs.setBool(_keyHapticEnabled, value);

  bool get scientificDefault => _prefs.getBool(_keyScientificDefault) ?? false;
  Future<void> setScientificDefault(bool value) =>
      _prefs.setBool(_keyScientificDefault, value);
}
