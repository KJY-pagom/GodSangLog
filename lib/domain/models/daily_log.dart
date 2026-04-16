import 'package:isar/isar.dart';
import 'meal.dart';
import 'exercise.dart';
import 'video_clip.dart';

part 'daily_log.g.dart';

/// 하루 기록 컬렉션 — Meal, Exercise, VideoClip을 날짜로 묶는 최상위 모델
@Collection()
class DailyLog {
  Id id = Isar.autoIncrement;

  /// 날짜 (시/분/초는 00:00:00 기준)
  @Index(unique: true)
  late DateTime date;

  /// 하루 목표 칼로리 (kcal)
  late double goalCalories;

  /// 연결된 식사 기록
  final meals = IsarLinks<Meal>();

  /// 연결된 운동 기록
  final exercises = IsarLinks<Exercise>();

  /// 연결된 영상 클립
  final clips = IsarLinks<VideoClip>();
}
