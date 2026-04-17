import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/preferences.dart';
import '../utils/calorie_calc.dart';

/// AppPreferences 인스턴스 Provider
final preferencesProvider = FutureProvider<AppPreferences>(
  (_) => AppPreferences.create(),
);

/// UserProfile 상태 — 설정 화면에서 읽기/쓰기
class UserProfileNotifier extends Notifier<UserProfile> {
  @override
  UserProfile build() {
    // SharedPreferences에서 저장된 값 로드 (로딩 중에는 기본값 사용)
    final prefsAsync = ref.watch(preferencesProvider);
    return prefsAsync.when(
      data: (p) => UserProfile(
        gender: p.gender,
        age: p.age,
        heightCm: p.heightCm,
        weightKg: p.weightKg,
        activityLevel: p.activityLevel,
        goalCalories: p.goalCalories,
        recordDuration: p.recordDuration,
        watermarkEnabled: p.watermarkEnabled,
      ),
      loading: () => const UserProfile(),
      error: (_, __) => const UserProfile(),
    );
  }

  Future<void> update({
    required AppPreferences prefs,
    String? gender,
    int? age,
    double? heightCm,
    double? weightKg,
    double? activityLevel,
    int? recordDuration,
    bool? watermarkEnabled,
  }) async {
    final updated = state.copyWith(
      gender: gender,
      age: age,
      heightCm: heightCm,
      weightKg: weightKg,
      activityLevel: activityLevel,
      recordDuration: recordDuration,
      watermarkEnabled: watermarkEnabled,
    );
    // 목표 칼로리 재계산
    final goal = CalorieCalc.goalCalories(
      gender: updated.gender,
      weightKg: updated.weightKg,
      heightCm: updated.heightCm,
      age: updated.age,
      activityLevel: updated.activityLevel,
    );
    final final_ = updated.copyWith(goalCalories: goal);

    if (gender != null) await prefs.setGender(final_.gender);
    if (age != null) await prefs.setAge(final_.age);
    if (heightCm != null) await prefs.setHeightCm(final_.heightCm);
    if (weightKg != null) await prefs.setWeightKg(final_.weightKg);
    if (activityLevel != null) {
      await prefs.setActivityLevel(final_.activityLevel);
    }
    if (recordDuration != null) {
      await prefs.setRecordDuration(final_.recordDuration);
    }
    if (watermarkEnabled != null) {
      await prefs.setWatermarkEnabled(final_.watermarkEnabled);
    }
    await prefs.setGoalCalories(final_.goalCalories);

    state = final_;
  }
}

final userProfileProvider = NotifierProvider<UserProfileNotifier, UserProfile>(
  UserProfileNotifier.new,
);

/// 불변 UserProfile 값 객체
class UserProfile {
  final String gender;
  final int age;
  final double heightCm;
  final double weightKg;
  final double activityLevel;
  final double goalCalories;
  final int recordDuration;
  final bool watermarkEnabled;

  const UserProfile({
    this.gender = 'male',
    this.age = 25,
    this.heightCm = 170.0,
    this.weightKg = 65.0,
    this.activityLevel = 1.375,
    this.goalCalories = 1800.0,
    this.recordDuration = 2,
    this.watermarkEnabled = false,
  });

  UserProfile copyWith({
    String? gender,
    int? age,
    double? heightCm,
    double? weightKg,
    double? activityLevel,
    double? goalCalories,
    int? recordDuration,
    bool? watermarkEnabled,
  }) {
    return UserProfile(
      gender: gender ?? this.gender,
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      activityLevel: activityLevel ?? this.activityLevel,
      goalCalories: goalCalories ?? this.goalCalories,
      recordDuration: recordDuration ?? this.recordDuration,
      watermarkEnabled: watermarkEnabled ?? this.watermarkEnabled,
    );
  }
}
