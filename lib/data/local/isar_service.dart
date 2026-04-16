import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../domain/models/daily_log.dart';
import '../../domain/models/meal.dart';
import '../../domain/models/exercise.dart';
import '../../domain/models/video_clip.dart';
import '../../domain/models/recipe_preset.dart';

/// Isar 데이터베이스 싱글턴 서비스
class IsarService {
  static Isar? _instance;

  static Future<Isar> getInstance() async {
    if (_instance != null && _instance!.isOpen) return _instance!;
    // hot restart 후 Dart 정적변수는 초기화되지만 Isar 인스턴스는 살아 있음
    // → 기존 인스턴스를 재사용해 "Instance has already been opened" 방지
    final existing = Isar.getInstance();
    if (existing != null) {
      _instance = existing;
      return _instance!;
    }
    final dir = await getApplicationDocumentsDirectory();
    _instance = await Isar.open([
      DailyLogSchema,
      MealSchema,
      ExerciseSchema,
      VideoClipSchema,
      RecipePresetSchema,
    ], directory: dir.path);
    return _instance!;
  }
}
