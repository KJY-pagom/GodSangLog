/// 운동별 MET(Metabolic Equivalent of Task) 테이블
/// 소모 칼로리 = MET × 체중(kg) × 시간(h)
class ExerciseMets {
  static const Map<String, double> table = {
    '걷기': 3.5,
    '달리기': 8.0,
    '자전거': 6.0,
    '수영': 7.0,
    '등산': 6.0,
    '줄넘기': 10.0,
    '근력 운동': 5.0,
    '요가': 2.5,
    '필라테스': 3.0,
    '축구': 7.0,
    '농구': 6.5,
    '배드민턴': 5.5,
    '테니스': 7.0,
    '댄스': 5.0,
    '기타': 4.0,
  };

  /// 운동 목록 반환
  static List<String> get exercises => table.keys.toList();

  /// 칼로리 소모량 계산
  static double calculateCalories({
    required String exerciseType,
    required double weightKg,
    required int durationMinutes,
  }) {
    final met = table[exerciseType] ?? table['기타']!;
    return met * weightKg * (durationMinutes / 60.0);
  }
}
