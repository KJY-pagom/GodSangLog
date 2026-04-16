/// 칼로리 계산 유틸 (Mifflin-St Jeor 공식)
class CalorieCalc {
  /// BMR 계산
  /// [gender]: 'male' 또는 'female'
  static double bmr({
    required String gender,
    required double weightKg,
    required double heightCm,
    required int age,
  }) {
    final base = (10 * weightKg) + (6.25 * heightCm) - (5 * age);
    return gender == 'male' ? base + 5 : base - 161;
  }

  /// 다이어트 목표 칼로리 = BMR × 활동지수 × 0.85
  static double goalCalories({
    required String gender,
    required double weightKg,
    required double heightCm,
    required int age,
    required double activityLevel,
  }) {
    return bmr(
          gender: gender,
          weightKg: weightKg,
          heightCm: heightCm,
          age: age,
        ) *
        activityLevel *
        0.85;
  }
}
