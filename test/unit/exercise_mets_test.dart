import 'package:flutter_test/flutter_test.dart';
import 'package:godsanglog/utils/exercise_mets.dart';

void main() {
  group('ExerciseMets.calculateCalories', () {
    test('달리기 30분, 70kg → 8.0 × 70 × 0.5 = 280 kcal', () {
      expect(
        ExerciseMets.calculateCalories(
          exerciseType: '달리기',
          weightKg: 70,
          durationMinutes: 30,
        ),
        closeTo(280.0, 0.01),
      );
    });

    test('걷기 60분, 60kg → 3.5 × 60 × 1.0 = 210 kcal', () {
      expect(
        ExerciseMets.calculateCalories(
          exerciseType: '걷기',
          weightKg: 60,
          durationMinutes: 60,
        ),
        closeTo(210.0, 0.01),
      );
    });

    test('알 수 없는 종목은 기타 MET(4.0) 사용', () {
      expect(
        ExerciseMets.calculateCalories(
          exerciseType: '알수없음',
          weightKg: 60,
          durationMinutes: 60,
        ),
        closeTo(240.0, 0.01), // 4.0 × 60 × 1.0
      );
    });

    test('시간이 0분이면 소모 칼로리는 0', () {
      expect(
        ExerciseMets.calculateCalories(
          exerciseType: '달리기',
          weightKg: 70,
          durationMinutes: 0,
        ),
        0.0,
      );
    });

    test('exercises 목록의 모든 항목이 MET 테이블에 존재', () {
      for (final name in ExerciseMets.exercises) {
        expect(
          ExerciseMets.table.containsKey(name),
          isTrue,
          reason: '$name 이(가) MET 테이블에 없음',
        );
      }
    });

    test('MET 값은 모두 양수', () {
      for (final entry in ExerciseMets.table.entries) {
        expect(
          entry.value,
          greaterThan(0),
          reason: '${entry.key}의 MET 값이 0 이하',
        );
      }
    });
  });
}
