import 'package:shared_preferences/shared_preferences.dart';

/// 사용자 프로필 및 앱 설정 저장소
class AppPreferences {
  static const _keyGender = 'gender';
  static const _keyAge = 'age';
  static const _keyHeightCm = 'heightCm';
  static const _keyWeightKg = 'weightKg';
  static const _keyActivityLevel = 'activityLevel';
  static const _keyGoalCalories = 'goalCalories';
  static const _keyRecordDuration = 'recordDuration';
  static const _keyWatermarkEnabled = 'watermarkEnabled';

  final SharedPreferences _prefs;

  AppPreferences(this._prefs);

  static Future<AppPreferences> create() async {
    final prefs = await SharedPreferences.getInstance();
    return AppPreferences(prefs);
  }

  // --- UserProfile ---

  String get gender => _prefs.getString(_keyGender) ?? 'male';
  Future<void> setGender(String value) => _prefs.setString(_keyGender, value);

  int get age => _prefs.getInt(_keyAge) ?? 25;
  Future<void> setAge(int value) => _prefs.setInt(_keyAge, value);

  double get heightCm => _prefs.getDouble(_keyHeightCm) ?? 170.0;
  Future<void> setHeightCm(double value) =>
      _prefs.setDouble(_keyHeightCm, value);

  double get weightKg => _prefs.getDouble(_keyWeightKg) ?? 65.0;
  Future<void> setWeightKg(double value) =>
      _prefs.setDouble(_keyWeightKg, value);

  /// 활동지수: 1.2 / 1.375 / 1.55 / 1.725 / 1.9
  double get activityLevel => _prefs.getDouble(_keyActivityLevel) ?? 1.375;
  Future<void> setActivityLevel(double value) =>
      _prefs.setDouble(_keyActivityLevel, value);

  double get goalCalories => _prefs.getDouble(_keyGoalCalories) ?? 1800.0;
  Future<void> setGoalCalories(double value) =>
      _prefs.setDouble(_keyGoalCalories, value);

  // --- 촬영 시간 설정 (2 / 5 / 10초) ---

  int get recordDuration => _prefs.getInt(_keyRecordDuration) ?? 2;
  Future<void> setRecordDuration(int seconds) =>
      _prefs.setInt(_keyRecordDuration, seconds);

  // --- 워터마크 옵션 ---

  bool get watermarkEnabled => _prefs.getBool(_keyWatermarkEnabled) ?? false;
  Future<void> setWatermarkEnabled(bool value) =>
      _prefs.setBool(_keyWatermarkEnabled, value);
}
