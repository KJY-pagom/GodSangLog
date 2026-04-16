import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/preferences_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final prefsAsync = ref.watch(preferencesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: prefsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
        data: (prefs) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('신체 정보', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            // 성별
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'male', label: Text('남성')),
                ButtonSegment(value: 'female', label: Text('여성')),
              ],
              selected: {profile.gender},
              onSelectionChanged: (v) => ref
                  .read(userProfileProvider.notifier)
                  .update(prefs: prefs, gender: v.first),
            ),
            const SizedBox(height: 16),
            _SliderTile(
              label: '나이: ${profile.age}세',
              value: profile.age.toDouble(),
              min: 10,
              max: 80,
              divisions: 70,
              onChanged: (v) => ref
                  .read(userProfileProvider.notifier)
                  .update(prefs: prefs, age: v.toInt()),
            ),
            _SliderTile(
              label: '키: ${profile.heightCm.toInt()} cm',
              value: profile.heightCm,
              min: 140,
              max: 210,
              divisions: 70,
              onChanged: (v) => ref
                  .read(userProfileProvider.notifier)
                  .update(prefs: prefs, heightCm: v),
            ),
            _SliderTile(
              label: '몸무게: ${profile.weightKg.toInt()} kg',
              value: profile.weightKg,
              min: 30,
              max: 150,
              divisions: 120,
              onChanged: (v) => ref
                  .read(userProfileProvider.notifier)
                  .update(prefs: prefs, weightKg: v),
            ),
            const Divider(height: 32),
            Text('활동 수준', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ..._activityLevels.entries.map(
              (e) => RadioListTile<double>(
                title: Text(e.key),
                value: e.value,
                groupValue: profile.activityLevel,
                onChanged: (v) => ref
                    .read(userProfileProvider.notifier)
                    .update(prefs: prefs, activityLevel: v),
              ),
            ),
            const Divider(height: 32),
            Text('목표 칼로리', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              '${profile.goalCalories.toInt()} kcal / 일',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const Divider(height: 32),
            Text('영상 촬영 시간', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 2, label: Text('2초')),
                ButtonSegment(value: 5, label: Text('5초')),
                ButtonSegment(value: 10, label: Text('10초')),
              ],
              selected: {profile.recordDuration},
              onSelectionChanged: (v) => ref
                  .read(userProfileProvider.notifier)
                  .update(prefs: prefs, recordDuration: v.first),
            ),
            const Divider(height: 32),
            Text('워터마크', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('영상 워터마크 표시'),
              subtitle: const Text('촬영 시 앱 이름 · 날짜 · 칼로리 오버레이'),
              value: profile.watermarkEnabled,
              onChanged: (v) => ref
                  .read(userProfileProvider.notifier)
                  .update(prefs: prefs, watermarkEnabled: v),
            ),
          ],
        ),
      ),
    );
  }

  static const _activityLevels = {
    '거의 활동 안 함': 1.2,
    '가벼운 활동 (주 1-3회)': 1.375,
    '보통 활동 (주 3-5회)': 1.55,
    '활발한 활동 (주 6-7회)': 1.725,
    '매우 활발 (하루 2회 이상)': 1.9,
  };
}

class _SliderTile extends StatelessWidget {
  final String label;
  final double value, min, max;
  final int divisions;
  final ValueChanged<double> onChanged;

  const _SliderTile({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
