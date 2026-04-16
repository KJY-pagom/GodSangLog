import 'package:flutter_test/flutter_test.dart';
import 'package:godsanglog/utils/calorie_calc.dart';

void main() {
  group('CalorieCalc.bmr', () {
    test('남성 BMR 계산 (Mifflin-St Jeor)', () {
      // (10×70) + (6.25×175) - (5×30) + 5 = 1648.75
      expect(
        CalorieCalc.bmr(gender: 'male', weightKg: 70, heightCm: 175, age: 30),
        closeTo(1648.75, 0.01),
      );
    });

    test('여성 BMR 계산 (Mifflin-St Jeor)', () {
      // (10×55) + (6.25×162) - (5×25) - 161 = 1276.5
      expect(
        CalorieCalc.bmr(gender: 'female', weightKg: 55, heightCm: 162, age: 25),
        closeTo(1276.5, 0.01),
      );
    });

    test('남성과 여성의 BMR 차이는 166 (공식상 고정)', () {
      const params = (weightKg: 65.0, heightCm: 170.0, age: 25);
      final male = CalorieCalc.bmr(
        gender: 'male',
        weightKg: params.weightKg,
        heightCm: params.heightCm,
        age: params.age,
      );
      final female = CalorieCalc.bmr(
        gender: 'female',
        weightKg: params.weightKg,
        heightCm: params.heightCm,
        age: params.age,
      );
      // male = base + 5, female = base - 161 → 차이 = 166
      expect(male - female, closeTo(166.0, 0.01));
    });
  });

  group('CalorieCalc.goalCalories', () {
    test('목표 칼로리 = BMR × 활동지수 × 0.85', () {
      const gender = 'male';
      const w = 70.0, h = 175.0;
      const age = 30;
      const activity = 1.375;

      final bmr = CalorieCalc.bmr(
        gender: gender,
        weightKg: w,
        heightCm: h,
        age: age,
      );
      final expected = bmr * activity * 0.85;

      expect(
        CalorieCalc.goalCalories(
          gender: gender,
          weightKg: w,
          heightCm: h,
          age: age,
          activityLevel: activity,
        ),
        closeTo(expected, 0.01),
      );
    });

    test('활동지수가 클수록 목표 칼로리가 높음', () {
      double goal(double activity) => CalorieCalc.goalCalories(
        gender: 'male',
        weightKg: 70,
        heightCm: 175,
        age: 30,
        activityLevel: activity,
      );
      expect(goal(1.725), greaterThan(goal(1.375)));
    });
  });
}
