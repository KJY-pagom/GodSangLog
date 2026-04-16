import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/models/exercise.dart';
import '../../../providers/daily_log_provider.dart';
import '../../../providers/preferences_provider.dart';
import '../../../utils/exercise_mets.dart';

class ExerciseRecordScreen extends ConsumerStatefulWidget {
  const ExerciseRecordScreen({super.key});

  @override
  ConsumerState<ExerciseRecordScreen> createState() =>
      _ExerciseRecordScreenState();
}

class _ExerciseRecordScreenState extends ConsumerState<ExerciseRecordScreen> {
  String _type = ExerciseMets.exercises.first;
  int _duration = 30;

  double get _burned {
    final weight = ref.read(userProfileProvider).weightKg;
    return ExerciseMets.calculateCalories(
      exerciseType: _type,
      weightKg: weight,
      durationMinutes: _duration,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('운동 기록')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('운동 종류', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _type,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: ExerciseMets.exercises
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _type = v!),
            ),
            const SizedBox(height: 24),
            Text(
              '운동 시간: $_duration 분',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Slider(
              value: _duration.toDouble(),
              min: 5,
              max: 180,
              divisions: 35,
              label: '$_duration 분',
              onChanged: (v) => setState(() => _duration = v.toInt()),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('예상 소모 칼로리: '),
                    Text(
                      '${_burned.toInt()} kcal',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
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
    final ex = Exercise()
      ..type = _type
      ..durationMinutes = _duration
      ..caloriesBurned = _burned
      ..recordedAt = DateTime.now();
    await ref.read(dailyLogProvider.notifier).addExercise(ex);
    if (mounted) context.pop();
  }
}
