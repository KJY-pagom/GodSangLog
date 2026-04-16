import 'package:isar/isar.dart';

part 'meal.g.dart';

/// 식사 기록 컬렉션
@Collection()
class Meal {
  Id id = Isar.autoIncrement;

  /// 식품명
  late String name;

  /// 칼로리 (kcal)
  late double calories;

  /// 단백질 (g)
  late double protein;

  /// 탄수화물 (g)
  late double carbs;

  /// 지방 (g)
  late double fat;

  /// 끼니 (아침/점심/저녁/간식)
  late String mealTime;

  /// 데이터 출처 (api / manual / recipe)
  late String source;

  /// 연결된 영상 클립 id (없으면 null)
  int? clipId;

  /// 기록 일시
  late DateTime recordedAt;
}
