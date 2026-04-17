import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/models/daily_log.dart';
import '../../domain/models/meal.dart';
import '../../domain/models/exercise.dart';
import '../../providers/daily_log_provider.dart';

/// 캘린더에서 날짜 탭 시 표시되는 BottomSheet
///
/// 반환값이 true면 호출부에서 해당 날짜를 선택일로 설정 후 TodayScreen으로 이동.
class DayDetailSheet extends ConsumerWidget {
  final DateTime date;

  const DayDetailSheet({super.key, required this.date});

  /// showModalBottomSheet 헬퍼. 사용자가 "이 날짜에 기록하기"를 누르면 true 반환.
  static Future<bool> show(BuildContext context, DateTime date) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DayDetailSheet(date: date),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logAsync = ref.watch(dayDetailProvider(date));
    final now = DateTime.now();
    final isFuture = date.isAfter(DateTime(now.year, now.month, now.day));

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // 드래그 핸들
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // 날짜 헤더
            _DateHeader(date: date, logAsync: logAsync),
            const Divider(height: 1),
            // 본문
            Expanded(
              child: logAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('오류: $e')),
                data: (log) => log == null
                    ? _EmptyState(date: date)
                    : _LogDetail(
                        log: log,
                        scrollController: scrollController,
                      ),
              ),
            ),
            // ── 기록하기 버튼 ────────────────────────────────────
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => Navigator.pop(context, true),
                    icon: Icon(isFuture ? Icons.edit_calendar : Icons.edit),
                    label: Text(
                      isFuture
                          ? '이 날짜에 미리 기록하기'
                          : '이 날짜에 기록하기',
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── 날짜 헤더 + 달성 뱃지 ──────────────────────────────────────────────────

class _DateHeader extends StatelessWidget {
  final DateTime date;
  final AsyncValue<DailyLog?> logAsync;

  const _DateHeader({required this.date, required this.logAsync});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('M월 d일 (E)', 'ko').format(date);
    final achieved = logAsync.valueOrNull != null &&
        _isAchieved(logAsync.valueOrNull!);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 16, 12),
      child: Row(
        children: [
          Text(
            dateStr,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 10),
          if (logAsync.valueOrNull != null)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: achieved
                    ? Colors.green.shade50
                    : Colors.red.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: achieved ? Colors.green : Colors.redAccent,
                  width: 0.8,
                ),
              ),
              child: Text(
                achieved ? '✅ 목표 달성' : '❌ 목표 초과',
                style: TextStyle(
                  fontSize: 11,
                  color: achieved
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context, false),
            style: IconButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  bool _isAchieved(DailyLog log) {
    if (log.goalCalories <= 0) return false;
    final net = log.meals.fold<double>(0, (s, m) => s + m.calories) -
        log.exercises.fold<double>(0, (s, e) => s + e.caloriesBurned);
    return net <= log.goalCalories;
  }
}

// ─── 기록 없음 ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final DateTime date;
  const _EmptyState({required this.date});

  @override
  Widget build(BuildContext context) {
    final isFuture =
        date.isAfter(DateTime.now());
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isFuture ? Icons.event_outlined : Icons.sentiment_neutral,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            isFuture ? '아직 기록되지 않은 날이에요' : '이 날의 기록이 없어요',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            '아래 버튼으로 기록을 추가해 보세요',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ─── 기록 상세 ───────────────────────────────────────────────────────────────

class _LogDetail extends StatelessWidget {
  final DailyLog log;
  final ScrollController scrollController;

  const _LogDetail({required this.log, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    final intake = log.meals.fold<double>(0, (s, m) => s + m.calories);
    final burned =
        log.exercises.fold<double>(0, (s, e) => s + e.caloriesBurned);
    final net = intake - burned;
    final goal = log.goalCalories;
    final remaining = goal - net;

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      children: [
        _CalorieSummaryCard(
          goal: goal,
          intake: intake,
          burned: burned,
          net: net,
          remaining: remaining,
        ),
        const SizedBox(height: 20),

        _SectionTitle(
          icon: Icons.restaurant,
          title: '식사 기록',
          count: log.meals.length,
        ),
        const SizedBox(height: 6),
        if (log.meals.isEmpty)
          _EmptySection(label: '식사 기록이 없습니다')
        else
          ...log.meals.map((m) => _MealRow(meal: m)),
        const SizedBox(height: 20),

        _SectionTitle(
          icon: Icons.fitness_center,
          title: '운동 기록',
          count: log.exercises.length,
        ),
        const SizedBox(height: 6),
        if (log.exercises.isEmpty)
          _EmptySection(label: '운동 기록이 없습니다')
        else
          ...log.exercises.map((e) => _ExerciseRow(exercise: e)),
      ],
    );
  }
}

// ─── 칼로리 요약 카드 ────────────────────────────────────────────────────────

class _CalorieSummaryCard extends StatelessWidget {
  final double goal, intake, burned, net, remaining;
  const _CalorieSummaryCard({
    required this.goal,
    required this.intake,
    required this.burned,
    required this.net,
    required this.remaining,
  });

  @override
  Widget build(BuildContext context) {
    final progress = goal > 0 ? (net / goal).clamp(0.0, 1.0) : 0.0;
    final color = remaining >= 0 ? Colors.green : Colors.red;

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem('섭취', intake, Colors.orange),
                _Divider(),
                _StatItem('소모', burned, Colors.blue),
                _Divider(),
                _StatItem('잔여', remaining, color),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                color: color,
                backgroundColor: Colors.grey.shade200,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '목표 ${goal.toInt()} kcal',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        height: 32,
        width: 1,
        color: Colors.grey.shade200,
      );
}

class _StatItem extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _StatItem(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey.shade600)),
        const SizedBox(height: 4),
        Text(
          '${value.toInt()}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
        Text('kcal',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
      ],
    );
  }
}

// ─── 섹션 타이틀 ─────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;
  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 6),
        Text(title,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptySection extends StatelessWidget {
  final String label;
  const _EmptySection({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        label,
        style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
      ),
    );
  }
}

// ─── 식사 행 ─────────────────────────────────────────────────────────────────

class _MealRow extends StatelessWidget {
  final Meal meal;
  const _MealRow({required this.meal});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.orange,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(meal.name,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(meal.mealTime,
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              ],
            ),
          ),
          Text(
            '${meal.calories.toInt()} kcal',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

// ─── 운동 행 ─────────────────────────────────────────────────────────────────

class _ExerciseRow extends StatelessWidget {
  final Exercise exercise;
  const _ExerciseRow({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exercise.type,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text('${exercise.durationMinutes}분',
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              ],
            ),
          ),
          Text(
            '${exercise.caloriesBurned.toInt()} kcal',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
