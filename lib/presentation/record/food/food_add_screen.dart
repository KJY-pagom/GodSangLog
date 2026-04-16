import 'package:flutter/material.dart';
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
  double _quantity = 1.0;
  String _mealTime = '점심';

  static const _mealTimes = ['아침', '점심', '저녁', '간식'];

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final multiplied = _quantity;

    return Scaffold(
      appBar: AppBar(title: Text(item.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _NutritionRow(
              '칼로리',
              '${(item.calories * multiplied).toInt()} kcal',
            ),
            _NutritionRow(
              '탄수화물',
              '${(item.carbs * multiplied).toStringAsFixed(1)} g',
            ),
            _NutritionRow(
              '단백질',
              '${(item.protein * multiplied).toStringAsFixed(1)} g',
            ),
            _NutritionRow(
              '지방',
              '${(item.fat * multiplied).toStringAsFixed(1)} g',
            ),
            const SizedBox(height: 24),
            Text(
              '수량 (1회 제공량 기준)',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Slider(
              value: _quantity,
              min: 0.5,
              max: 5.0,
              divisions: 9,
              label: '×${_quantity.toStringAsFixed(1)}',
              onChanged: (v) => setState(() => _quantity = v),
            ),
            const SizedBox(height: 16),
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
            SizedBox(
              width: double.infinity,
              child: FilledButton(onPressed: _save, child: const Text('저장')),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final item = widget.item;
    final meal = Meal()
      ..name = item.name
      ..calories = item.calories * _quantity
      ..protein = item.protein * _quantity
      ..carbs = item.carbs * _quantity
      ..fat = item.fat * _quantity
      ..mealTime = _mealTime
      ..source = 'api'
      ..recordedAt = DateTime.now();

    await ref.read(dailyLogProvider.notifier).addMeal(meal);
    if (mounted) context.pop();
  }
}

class _NutritionRow extends StatelessWidget {
  final String label, value;
  const _NutritionRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
