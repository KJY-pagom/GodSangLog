import 'package:isar/isar.dart';
import '../../domain/models/recipe_preset.dart';
import '../local/isar_service.dart';

/// 레시피 프리셋 CRUD 레포지토리
class RecipeRepository {
  Future<Isar> get _db => IsarService.getInstance();

  Future<List<RecipePreset>> getAll() async {
    final isar = await _db;
    return isar.recipePresets.where().sortByCreatedAtDesc().findAll();
  }

  Future<void> save(RecipePreset preset) async {
    final isar = await _db;
    await isar.writeTxn(() => isar.recipePresets.put(preset));
  }

  Future<void> delete(int id) async {
    final isar = await _db;
    await isar.writeTxn(() => isar.recipePresets.delete(id));
  }
}
