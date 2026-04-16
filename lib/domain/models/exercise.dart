import 'package:isar/isar.dart';

part 'exercise.g.dart';

/// 운동 기록 컬렉션
@Collection()
class Exercise {
  Id id = Isar.autoIncrement;

  /// 운동 종류 (예: 달리기, 자전거 등)
  late String type;

  /// 운동 시간 (분)
  late int durationMinutes;

  /// 소모 칼로리 (kcal) — MET × 체중 × 시간으로 계산
  late double caloriesBurned;

  /// 연결된 영상 클립 id (없으면 null)
  int? clipId;

  /// 기록 일시
  late DateTime recordedAt;
}
