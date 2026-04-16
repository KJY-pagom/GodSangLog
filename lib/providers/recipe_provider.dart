import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repository/recipe_repository.dart';
import '../domain/models/recipe_preset.dart';

final _recipeRepoProvider = Provider((_) => RecipeRepository());

/// 레시피 프리셋 목록 AsyncNotifier
class RecipeListNotifier extends AsyncNotifier<List<RecipePreset>> {
  @override
  Future<List<RecipePreset>> build() => ref.read(_recipeRepoProvider).getAll();

  Future<void> save(RecipePreset preset) async {
    await ref.read(_recipeRepoProvider).save(preset);
    ref.invalidateSelf();
  }

  Future<void> delete(int id) async {
    await ref.read(_recipeRepoProvider).delete(id);
    ref.invalidateSelf();
  }
}

final recipeListProvider =
    AsyncNotifierProvider<RecipeListNotifier, List<RecipePreset>>(
      RecipeListNotifier.new,
    );
