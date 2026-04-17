import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/daily_log_provider.dart';
import '../../domain/models/daily_log.dart';
import '../../domain/models/meal.dart';
import '../../domain/models/exercise.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final logAsync = ref.watch(dailyLogProvider);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isToday = selectedDate == today;

    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('M월 d일 (E)', 'ko').format(selectedDate)),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () => context.push('/calendar'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── 과거/미래 날짜 배너 ──────────────────────────────
          if (!isToday)
            _DateBanner(
              date: selectedDate,
              onBackToToday: () {
                ref.read(selectedDateProvider.notifier).state = today;
              },
            ),

          // ── 본문 ────────────────────────────────────────────
          Expanded(
            child: logAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('오류: $e')),
              data: (log) {
                if (log == null) return const SizedBox.shrink();

                final totalCaloriesIn = log.meals.fold<double>(
                  0,
                  (sum, m) => sum + m.calories,
                );
                final totalCaloriesOut = log.exercises.fold<double>(
                  0,
                  (sum, e) => sum + e.caloriesBurned,
                );
                final net = totalCaloriesIn - totalCaloriesOut;
                final goal = log.goalCalories;

                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(dailyLogProvider),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _CalorieSummaryCard(
                        goal: goal,
                        intake: totalCaloriesIn,
                        burned: totalCaloriesOut,
                        net: net,
                      ),
                      const SizedBox(height: 8),
                      if (isToday) const _WeeklyAchievementWidget(),
                      if (isToday) const SizedBox(height: 16),
                      _SectionHeader(
                        title: '식사 기록',
                        onAdd: () => context.push('/record/food'),
                        onCamera: () =>
                            context.push('/record/camera?tag=meal'),
                      ),
                      ...log.meals.map(
                        (m) => _MealTile(
                          meal: m,
                          onDelete: () => ref
                              .read(dailyLogProvider.notifier)
                              .deleteMeal(m),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _SectionHeader(
                        title: '운동 기록',
                        onAdd: () => context.push('/record/exercise'),
                        onCamera: () =>
                            context.push('/record/camera?tag=exercise'),
                      ),
                      ...log.exercises.map(
                        (e) => _ExerciseTile(
                          exercise: e,
                          onDelete: () => ref
                              .read(dailyLogProvider.notifier)
                              .deleteExercise(e),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── 날짜 배너 ─────────────────────────────────────────────────────────────────

class _DateBanner extends StatelessWidget {
  final DateTime date;
  final VoidCallback onBackToToday;

  const _DateBanner({required this.date, required this.onBackToToday});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isFuture = date.isAfter(DateTime(now.year, now.month, now.day));
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      color: isFuture
          ? Colors.blue.shade50
          : cs.tertiaryContainer.withValues(alpha: 0.5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            isFuture ? Icons.event : Icons.history,
            size: 16,
            color: isFuture ? Colors.blue.shade700 : cs.tertiary,
          ),
          const SizedBox(width: 8),
          Text(
            isFuture ? '미래 날짜 기록' : '과거 날짜 기록 중',
            style: TextStyle(
              fontSize: 13,
              color: isFuture ? Colors.blue.shade700 : cs.tertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: onBackToToday,
            icon: Icon(Icons.today, size: 14, color: cs.primary),
            label: Text(
              '오늘로',
              style: TextStyle(fontSize: 12, color: cs.primary),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 칼로리 요약 카드 ──────────────────────────────────────────────────────────

class _CalorieSummaryCard extends StatelessWidget {
  final double goal, intake, burned, net;
  const _CalorieSummaryCard({
    required this.goal,
    required this.intake,
    required this.burned,
    required this.net,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = goal - net;
    final progress = goal > 0 ? (net / goal).clamp(0.0, 1.0) : 0.0;
    final color = remaining >= 0 ? Colors.green : Colors.red;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatItem('섭취', '${intake.toInt()} kcal', Colors.orange),
                _StatItem('소모', '${burned.toInt()} kcal', Colors.blue),
                _StatItem('잔여', '${remaining.toInt()} kcal', color),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              color: color,
              backgroundColor: Colors.grey.shade200,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 6),
            Text(
              '목표: ${goal.toInt()} kcal',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatItem(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onAdd;
  final VoidCallback onCamera;
  const _SectionHeader({
    required this.title,
    required this.onAdd,
    required this.onCamera,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const Spacer(),
        IconButton(icon: const Icon(Icons.videocam), onPressed: onCamera),
        IconButton(icon: const Icon(Icons.add), onPressed: onAdd),
      ],
    );
  }
}

class _MealTile extends StatelessWidget {
  final Meal meal;
  final VoidCallback onDelete;
  const _MealTile({required this.meal, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.restaurant),
      title: Text(meal.name),
      subtitle: Text(meal.mealTime),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${meal.calories.toInt()} kcal'),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onDelete;
  const _ExerciseTile({required this.exercise, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.fitness_center),
      title: Text(exercise.type),
      subtitle: Text('${exercise.durationMinutes}분'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${exercise.caloriesBurned.toInt()} kcal'),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

// ── 주간 달성 현황 ────────────────────────────────────────────────────────────

enum _DotStatus { none, achieved, exceeded }

class _WeeklyAchievementWidget extends ConsumerStatefulWidget {
  const _WeeklyAchievementWidget();

  @override
  ConsumerState<_WeeklyAchievementWidget> createState() =>
      _WeeklyAchievementWidgetState();
}

class _WeeklyAchievementWidgetState
    extends ConsumerState<_WeeklyAchievementWidget> {
  bool _expanded = false;

  static const _dayNames = ['월', '화', '수', '목', '금', '토', '일'];

  _DotStatus _statusOf(DailyLog? log, DateTime day) {
    final today = DateTime.now();
    if (day.isAfter(DateTime(today.year, today.month, today.day))) {
      return _DotStatus.none;
    }
    if (log == null || log.meals.isEmpty) return _DotStatus.none;
    final net =
        log.meals.fold<double>(0, (s, m) => s + m.calories) -
        log.exercises.fold<double>(0, (s, e) => s + e.caloriesBurned);
    return net <= log.goalCalories ? _DotStatus.achieved : _DotStatus.exceeded;
  }

  @override
  Widget build(BuildContext context) {
    final weeklyAsync = ref.watch(weeklyLogsProvider);
    final cs = Theme.of(context).colorScheme;
    final today = DateTime.now();
    final monday = today.subtract(Duration(days: today.weekday - 1));

    return weeklyAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (logs) {
        final statuses = List.generate(7, (i) {
          final day = DateTime(monday.year, monday.month, monday.day + i);
          return _statusOf(logs[i], day);
        });

        return Card(
          child: InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '이번 주',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 10),
                      ...List.generate(7, (i) {
                        final day = DateTime(
                          monday.year,
                          monday.month,
                          monday.day + i,
                        );
                        final isToday =
                            day.day == today.day &&
                            day.month == today.month &&
                            day.year == today.year;
                        return _DotCell(
                          status: statuses[i],
                          label: _dayNames[i],
                          isToday: isToday,
                        );
                      }),
                      const Spacer(),
                      Icon(
                        _expanded ? Icons.expand_less : Icons.expand_more,
                        size: 16,
                        color: cs.onSurfaceVariant,
                      ),
                    ],
                  ),
                  if (_expanded) ...[
                    const SizedBox(height: 8),
                    const Divider(height: 1),
                    const SizedBox(height: 8),
                    ...List.generate(7, (i) {
                      final day = DateTime(
                        monday.year,
                        monday.month,
                        monday.day + i,
                      );
                      final log = logs[i];
                      final net = log == null
                          ? null
                          : log.meals.fold<double>(
                                  0,
                                  (s, m) => s + m.calories,
                                ) -
                                log.exercises.fold<double>(
                                  0,
                                  (s, e) => s + e.caloriesBurned,
                                );
                      final isToday =
                          day.day == today.day &&
                          day.month == today.month &&
                          day.year == today.year;
                      final dotColor = statuses[i] == _DotStatus.achieved
                          ? cs.primary
                          : statuses[i] == _DotStatus.exceeded
                          ? Colors.redAccent
                          : cs.onSurface.withValues(alpha: 0.25);

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            Text(
                              _dayNames[i],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isToday
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color:
                                    isToday ? cs.primary : cs.onSurface,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${day.month}/${day.day}',
                              style: TextStyle(
                                fontSize: 11,
                                color: cs.onSurface.withValues(alpha: 0.45),
                              ),
                            ),
                            const Spacer(),
                            if (net == null)
                              Text(
                                '—',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: cs.onSurface.withValues(alpha: 0.3),
                                ),
                              )
                            else
                              Text(
                                '${net.toInt()} / ${log!.goalCalories.toInt()} kcal',
                                style:
                                    TextStyle(fontSize: 12, color: dotColor),
                              ),
                          ],
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DotCell extends StatelessWidget {
  final _DotStatus status;
  final String label;
  final bool isToday;

  const _DotCell({
    required this.status,
    required this.label,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final Color dotColor;
    final bool filled;

    switch (status) {
      case _DotStatus.achieved:
        dotColor = cs.primary;
        filled = true;
      case _DotStatus.exceeded:
        dotColor = Colors.redAccent;
        filled = true;
      case _DotStatus.none:
        dotColor = cs.onSurface.withValues(alpha: 0.25);
        filled = false;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 11,
            height: 11,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: filled ? dotColor : Colors.transparent,
              border: Border.all(
                color: isToday ? cs.primary : dotColor,
                width: isToday ? 2 : 1.5,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: isToday
                  ? cs.primary
                  : cs.onSurface.withValues(alpha: 0.5),
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
