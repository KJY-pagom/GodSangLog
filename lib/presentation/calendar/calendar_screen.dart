import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/daily_log_provider.dart';
import '../../domain/models/daily_log.dart';
import 'day_detail_sheet.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _focusedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month, 1);
  }

  Future<void> _onDateTap(DateTime date) async {
    if (!mounted) return;
    final shouldEdit = await DayDetailSheet.show(context, date);
    if (shouldEdit && mounted) {
      // 선택 날짜 변경 → TodayScreen이 해당 날짜 데이터를 표시
      ref.read(selectedDateProvider.notifier).state =
          DateTime(date.year, date.month, date.day);
      if (mounted) Navigator.pop(context); // CalendarScreen 닫기
    }
  }

  @override
  Widget build(BuildContext context) {
    final allLogsAsync = ref.watch(allLogsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('yyyy년 M월', 'ko').format(_focusedMonth)),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => setState(
              () => _focusedMonth = DateTime(
                _focusedMonth.year,
                _focusedMonth.month - 1,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => setState(
              () => _focusedMonth = DateTime(
                _focusedMonth.year,
                _focusedMonth.month + 1,
              ),
            ),
          ),
        ],
      ),
      body: allLogsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
        data: (logs) => _CalendarGrid(
          focusedMonth: _focusedMonth,
          logs: logs,
          onDateTap: _onDateTap,
        ),
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  final DateTime focusedMonth;
  final List<DailyLog> logs;
  final void Function(DateTime) onDateTap;

  const _CalendarGrid({
    required this.focusedMonth,
    required this.logs,
    required this.onDateTap,
  });

  @override
  Widget build(BuildContext context) {
    final logMap = {for (final l in logs) _key(l.date): l};

    final firstDay = focusedMonth;
    final lastDay = DateTime(focusedMonth.year, focusedMonth.month + 1, 0);
    final startOffset = firstDay.weekday % 7; // 일요일 = 0
    final totalCells = startOffset + lastDay.day;
    final rows = (totalCells / 7).ceil();

    return Column(
      children: [
        // 요일 헤더
        Row(
          children: ['일', '월', '화', '수', '목', '금', '토']
              .map(
                (d) => Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: TextStyle(
                        color: d == '일'
                            ? Colors.red
                            : d == '토'
                            ? Colors.blue
                            : null,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const Divider(height: 8),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.8,
            ),
            itemCount: rows * 7,
            itemBuilder: (context, index) {
              final dayNum = index - startOffset + 1;
              if (dayNum < 1 || dayNum > lastDay.day) {
                return const SizedBox.shrink();
              }
              final date = DateTime(
                focusedMonth.year,
                focusedMonth.month,
                dayNum,
              );
              final log = logMap[_key(date)];
              final isToday = _key(date) == _key(DateTime.now());
              final achieved = log != null && _isAchieved(log);
              final hasRecord = log != null &&
                  (log.meals.isNotEmpty || log.exercises.isNotEmpty);

              return GestureDetector(
                onTap: () => onDateTap(date),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isToday
                        ? Theme.of(context).colorScheme.primaryContainer
                        : achieved
                        ? Colors.green.shade100
                        : null,
                    borderRadius: BorderRadius.circular(8),
                    border: hasRecord && !isToday && !achieved
                        ? Border.all(
                            color: Colors.orange.shade200,
                            width: 1,
                          )
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$dayNum',
                        style: TextStyle(
                          fontWeight: isToday ? FontWeight.bold : null,
                        ),
                      ),
                      if (achieved)
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 12,
                        )
                      else if (hasRecord)
                        Icon(
                          Icons.circle,
                          color: Colors.orange.shade300,
                          size: 6,
                        ),
                    ],
                  ),
                ),
              );
        },
          ),
        ),
      ],
    );
  }

  String _key(DateTime d) => '${d.year}-${d.month}-${d.day}';

  bool _isAchieved(DailyLog log) {
    if (log.goalCalories <= 0) return false;
    final intake = log.meals.fold<double>(0, (s, m) => s + m.calories);
    final burned = log.exercises.fold<double>(
      0,
      (s, e) => s + e.caloriesBurned,
    );
    final net = intake - burned;
    return net <= log.goalCalories;
  }
}
