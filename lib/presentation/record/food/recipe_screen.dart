import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/meal.dart';
import '../../../domain/models/recipe_preset.dart';
import '../../../providers/daily_log_provider.dart';
import '../../../providers/recipe_provider.dart';

class RecipeScreen extends ConsumerWidget {
  const RecipeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(recipeListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('나만의 레시피')),
      body: listAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
        data: (recipes) {
          if (recipes.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.menu_book_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '저장된 레시피가 없습니다',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: () => _showAddDialog(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('레시피 추가'),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: recipes.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final recipe = recipes[i];
              return _RecipeTile(
                recipe: recipe,
                onLog: () => _logRecipe(context, ref, recipe),
                onDelete: () =>
                    ref.read(recipeListProvider.notifier).delete(recipe.id),
              );
            },
          );
        },
      ),
      floatingActionButton: listAsync.hasValue && listAsync.value!.isNotEmpty
          ? FloatingActionButton(
              onPressed: () => _showAddDialog(context, ref),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Future<void> _logRecipe(
    BuildContext context,
    WidgetRef ref,
    RecipePreset recipe,
  ) async {
    final meal = Meal()
      ..name = recipe.name
      ..calories = recipe.calories
      ..protein = recipe.protein
      ..carbs = recipe.carbs
      ..fat = recipe.fat
      ..mealTime = '점심'
      ..source = 'recipe'
      ..recordedAt = DateTime.now();
    await ref.read(dailyLogProvider.notifier).addMeal(meal);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${recipe.name} 기록 완료')));
      Navigator.pop(context);
    }
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddRecipeSheet(
        onSave: (preset) => ref.read(recipeListProvider.notifier).save(preset),
      ),
    );
  }
}

class _RecipeTile extends StatelessWidget {
  final RecipePreset recipe;
  final VoidCallback onLog;
  final VoidCallback onDelete;

  const _RecipeTile({
    required this.recipe,
    required this.onLog,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.rice_bowl_outlined),
      title: Text(recipe.name),
      subtitle: Text(
        '${recipe.calories.toInt()} kcal  ·  ${recipe.ingredients}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(onPressed: onLog, child: const Text('기록')),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _AddRecipeSheet extends StatefulWidget {
  final Future<void> Function(RecipePreset) onSave;
  const _AddRecipeSheet({required this.onSave});

  @override
  State<_AddRecipeSheet> createState() => _AddRecipeSheetState();
}

class _AddRecipeSheetState extends State<_AddRecipeSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _ingredientsCtrl = TextEditingController();
  final _caloriesCtrl = TextEditingController();
  final _proteinCtrl = TextEditingController();
  final _carbsCtrl = TextEditingController();
  final _fatCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ingredientsCtrl.dispose();
    _caloriesCtrl.dispose();
    _proteinCtrl.dispose();
    _carbsCtrl.dispose();
    _fatCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final preset = RecipePreset()
      ..name = _nameCtrl.text.trim()
      ..ingredients = _ingredientsCtrl.text.trim()
      ..calories = double.parse(_caloriesCtrl.text)
      ..protein = double.parse(_proteinCtrl.text)
      ..carbs = double.parse(_carbsCtrl.text)
      ..fat = double.parse(_fatCtrl.text)
      ..createdAt = DateTime.now();
    await widget.onSave(preset);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottom + 20),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('레시피 추가', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              _Field(ctrl: _nameCtrl, label: '레시피 이름', required: true),
              const SizedBox(height: 10),
              _Field(ctrl: _ingredientsCtrl, label: '재료 (예: 닭가슴살, 현미밥)'),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _NumberField(
                      ctrl: _caloriesCtrl,
                      label: '칼로리 (kcal)',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _NumberField(ctrl: _proteinCtrl, label: '단백질 (g)'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _NumberField(ctrl: _carbsCtrl, label: '탄수화물 (g)'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _NumberField(ctrl: _fatCtrl, label: '지방 (g)'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _submit,
                  child: _saving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('저장'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final bool required;
  const _Field({
    required this.ctrl,
    required this.label,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? '필수 항목입니다' : null
          : null,
    );
  }
}

class _NumberField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  const _NumberField({required this.ctrl, required this.label});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return '필수';
        if (double.tryParse(v) == null) return '숫자만';
        return null;
      },
    );
  }
}
