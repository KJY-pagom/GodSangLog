import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/remote/food_api.dart';
import '../../../domain/models/meal.dart';
import '../../../providers/daily_log_provider.dart';

class FoodAddScreen extends ConsumerStatefulWidget {
  final FoodItem item;
  const FoodAddScreen({super.key, required this.item});

  @override
  ConsumerState<FoodAddScreen> createState() => _FoodAddScreenState();
}

class _FoodAddScreenState extends ConsumerState<FoodAddScreen> {
  late final TextEditingController _gramController;
  double _grams = 100;
  String _mealTime = '점심';

  static const _mealTimes = ['아침', '점심', '저녁', '간식'];

  /// 기준 100g 대비 배율
  double get _ratio => _grams / 100;

  @override
  void initState() {
    super.initState();
    // DB는 모두 100g 기준이므로 기본값 100
    _grams = 100;
    _gramController = TextEditingController(text: '100');
    _gramController.addListener(_onGramChanged);
  }

  @override
  void dispose() {
    _gramController
      ..removeListener(_onGramChanged)
      ..dispose();
    super.dispose();
  }

  void _onGramChanged() {
    final v = double.tryParse(_gramController.text);
    if (v != null && v > 0 && v != _grams) {
      setState(() => _grams = v);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Scaffold(
      appBar: AppBar(title: Text(item.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 영양성분 카드 ──────────────────────────────────
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  children: [
                    _NutritionRow(
                      label: '칼로리',
                      value: '${(item.calories * _ratio).toStringAsFixed(1)} kcal',
                      highlight: true,
                    ),
                    const Divider(height: 16),
                    _NutritionRow(
                      label: '탄수화물',
                      value:
                          '${(item.carbs * _ratio).toStringAsFixed(1)} g',
                    ),
                    _NutritionRow(
                      label: '단백질',
                      value:
                          '${(item.protein * _ratio).toStringAsFixed(1)} g',
                    ),
                    _NutritionRow(
                      label: '지방',
                      value:
                          '${(item.fat * _ratio).toStringAsFixed(1)} g',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── 섭취량 입력 ────────────────────────────────────
            Text(
              '섭취량 (g)',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                SizedBox(
                  width: 120,
                  child: TextField(
                    controller: _gramController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d*'),
                      ),
                    ],
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      suffixText: 'g',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 빠른 선택 칩
                Wrap(
                  spacing: 6,
                  children: [50, 100, 150, 200].map((g) {
                    final selected = _grams == g.toDouble();
                    return ActionChip(
                      label: Text('${g}g'),
                      backgroundColor: selected
                          ? Theme.of(context).colorScheme.primaryContainer
                          : null,
                      labelStyle: TextStyle(
                        fontWeight: selected ? FontWeight.bold : null,
                        color: selected
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : null,
                      ),
                      onPressed: () {
                        _gramController.text = '$g';
                        setState(() => _grams = g.toDouble());
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '※ 영양성분 기준량: 100g',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 24),

            // ── 끼니 선택 ─────────────────────────────────────
            Text('끼니', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _mealTimes
                  .map(
                    (t) => ChoiceChip(
                      label: Text(t),
                      selected: _mealTime == t,
                      onSelected: (_) => setState(() => _mealTime = t),
                    ),
                  )
                  .toList(),
            ),
            const Spacer(),

            // ── 저장 버튼 ─────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _grams > 0 ? _save : null,
                child: const Text('저장'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final item = widget.item;
    final selectedDate = ref.read(selectedDateProvider);

    final meal = Meal()
      ..name = item.name
      ..calories = item.calories * _ratio
      ..protein = item.protein * _ratio
      ..carbs = item.carbs * _ratio
      ..fat = item.fat * _ratio
      ..mealTime = _mealTime
      ..source = 'local'
      ..recordedAt = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        12,
      );

    await ref.read(dailyLogProvider.notifier).addMeal(meal);
    if (mounted) context.pop();
  }
}

class _NutritionRow extends StatelessWidget {
  final String label, value;
  final bool highlight;
  const _NutritionRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: highlight
                ? Theme.of(context).textTheme.bodyMedium
                : Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade700,
                ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: highlight ? 16 : 14,
              color: highlight
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
