import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/daily_log_provider.dart';
import '../../domain/models/daily_log.dart';
import 'day_detail_sheet.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allLogsAsync = ref.watch(allLogsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('주간 기록')),
      body: allLogsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
        data: (logs) {
          final logMap = {for (final l in logs) _dateKey(l.date): l};
          final weeks = _generateWeeks(logs);

          if (weeks.isEmpty) {
            return const Center(child: Text('기록이 없습니다'));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: weeks.length,
            itemBuilder: (context, i) => _WeekCard(
              monday: weeks[i],
              logMap: logMap,
              onDayTap: (date) async {
                final shouldEdit = await DayDetailSheet.show(context, date);
                if (shouldEdit && context.mounted) {
                  ref.read(selectedDateProvider.notifier).state =
                      DateTime(date.year, date.month, date.day);
                  if (context.mounted) Navigator.pop(context);
                }
              },
            ),
          );
        },
      ),
    );
  }

  /// 오늘 기준으로 가장 오래된 기록 주차까지 주 목록 생성 (최신 순)
  List<DateTime> _generateWeeks(List<DailyLog> logs) {
    final today = DateTime.now();
    final thisMonday = _mondayOf(today);

    // 기록이 있는 경우 가장 오래된 날짜의 주차까지, 없으면 12주
    DateTime earliest = thisMonday.subtract(const Duration(days: 7 * 11));
    if (logs.isNotEmpty) {
      final dates = logs.map((l) => l.date).toList()..sort();
      final firstDate = dates.first;
      final firstMonday = _mondayOf(firstDate);
      if (firstMonday.isBefore(earliest)) earliest = firstMonday;
    }

    final weeks = <DateTime>[];
    var cur = thisMonday;
    while (!cur.isBefore(earliest)) {
      weeks.add(cur);
      cur = cur.subtract(const Duration(days: 7));
    }
    return weeks; // 최신 주가 맨 위
  }

  static DateTime _mondayOf(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return d.subtract(Duration(days: d.weekday - 1));
  }

  static String _dateKey(DateTime d) => '${d.year}-${d.month}-${d.day}';
}

// ─── 주간 카드 ────────────────────────────────────────────────────────────────

class _WeekCard extends StatelessWidget {
  final DateTime monday;
  final Map<String, DailyLog> logMap;
  final void Function(DateTime) onDayTap;

  const _WeekCard({
    required this.monday,
    required this.logMap,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final days = List.generate(7, (i) => monday.add(Duration(days: i)));
    final sunday = days.last;
    final label = _weekLabel(monday);
    final rangeStr =
        '${DateFormat('M.d').format(monday)} ~ ${DateFormat('M.d').format(sunday)}';
    final today = DateTime.now();
    final isCurrentWeek = monday == _mondayOf(today);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      elevation: isCurrentWeek ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isCurrentWeek
            ? BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 1.5,
              )
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 주차 헤더
            Row(
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isCurrentWeek
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                ),
                const SizedBox(width: 8),
                Text(
                  rangeStr,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade500,
                      ),
                ),
                if (isCurrentWeek) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '이번 주',
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            // 7일 셀
            Row(
              children: days
                  .map(
                    (day) => Expanded(
                      child: _DayCell(
                        day: day,
                        log: logMap[_dateKey(day)],
                        onTap: onDayTap,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// ISO 기준 (목요일의 달/주차)
  String _weekLabel(DateTime monday) {
    final thursday = monday.add(const Duration(days: 3));
    final month = thursday.month;
    final firstOfMonth = DateTime(thursday.year, month, 1);
    final offset = (firstOfMonth.weekday - 1) % 7;
    final firstMonday = firstOfMonth.subtract(Duration(days: offset));
    final weekNum = (monday.difference(firstMonday).inDays ~/ 7) + 1;
    return '$month월 $weekNum주차';
  }

  static DateTime _mondayOf(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return d.subtract(Duration(days: d.weekday - 1));
  }

  static String _dateKey(DateTime d) => '${d.year}-${d.month}-${d.day}';
}

// ─── 날짜 셀 ─────────────────────────────────────────────────────────────────

class _DayCell extends StatelessWidget {
  final DateTime day;
  final DailyLog? log;
  final void Function(DateTime) onTap;

  const _DayCell({required this.day, required this.log, required this.onTap});

  static const _dayNames = ['월', '화', '수', '목', '금', '토', '일'];

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final isToday = day.year == today.year &&
        day.month == today.month &&
        day.day == today.day;
    final isFuture = day.isAfter(DateTime(today.year, today.month, today.day));

    // 기록 없는 날(식사·운동 모두 없음)은 미달성으로 처리
    final hasAnyRecord = log != null &&
        (log!.meals.isNotEmpty || log!.exercises.isNotEmpty);
    final achieved = hasAnyRecord && _isAchieved(log!);
    final exceeded = hasAnyRecord && !achieved;

    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => onTap(day),
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          // 요일
          Text(
            _dayNames[day.weekday - 1],
            style: TextStyle(
              fontSize: 10,
              color: day.weekday == 6
                  ? Colors.blue
                  : day.weekday == 7
                      ? Colors.red
                      : Colors.grey.shade500,
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 4),
          // 날짜 + 상태
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isToday
                  ? cs.primaryContainer
                  : achieved
                      ? Colors.green.shade100
                      : null,
              border: isToday
                  ? Border.all(color: cs.primary, width: 1.5)
                  : null,
            ),
            child: Center(
              child: Text(
                '${day.day}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  color: isToday ? cs.primary : null,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          // 달성 아이콘
          SizedBox(
            height: 14,
            child: isFuture
                ? const SizedBox.shrink()
                : achieved
                    ? const Icon(Icons.check_circle,
                        color: Colors.green, size: 14)
                    : exceeded
                        ? const Icon(Icons.cancel,
                            color: Colors.redAccent, size: 14)
                        : const Icon(Icons.remove,
                            color: Colors.grey, size: 10),
          ),
        ],
      ),
    );
  }

  bool _isAchieved(DailyLog log) {
    // 식사 기록이 하나도 없으면 달성 아님
    if (log.meals.isEmpty) return false;
    if (log.goalCalories <= 0) return false;
    final net = log.meals.fold<double>(0, (s, m) => s + m.calories) -
        log.exercises.fold<double>(0, (s, e) => s + e.caloriesBurned);
    return net <= log.goalCalories;
  }
}
