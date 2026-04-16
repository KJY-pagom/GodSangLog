import 'package:isar/isar.dart';

part 'recipe_preset.g.dart';

/// 나만의 레시피 프리셋 컬렉션
@Collection()
class RecipePreset {
  Id id = Isar.autoIncrement;

  /// 레시피 이름
  late String name;

  /// 재료 목록 (콤마 구분 문자열)
  late String ingredients;

  /// 총 칼로리 (kcal)
  late double calories;

  /// 단백질 (g)
  late double protein;

  /// 탄수화물 (g)
  late double carbs;

  /// 지방 (g)
  late double fat;

  /// 생성 일시
  late DateTime createdAt;
}
