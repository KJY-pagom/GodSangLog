import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repository/log_repository.dart';
import '../domain/models/daily_log.dart';
import '../domain/models/meal.dart';
import '../domain/models/exercise.dart';
import 'preferences_provider.dart';

final _logRepoProvider = Provider((_) => LogRepository());

/// 선택된 날짜 Provider (기본: 오늘)
final selectedDateProvider = StateProvider<DateTime>((_) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

/// 선택된 날짜의 DailyLog AsyncNotifier
class DailyLogNotifier extends AsyncNotifier<DailyLog?> {
  @override
  Future<DailyLog?> build() async {
    final date = ref.watch(selectedDateProvider);
    final profile = ref.watch(userProfileProvider);
    final repo = ref.read(_logRepoProvider);
    final log = await repo.getOrCreateLog(date, profile.goalCalories);
    await log.meals.load();
    await log.exercises.load();
    await log.clips.load();
    return log;
  }

  Future<void> addMeal(Meal meal) async {
    final log = state.valueOrNull;
    if (log == null) return;
    await ref.read(_logRepoProvider).addMeal(log, meal);
    ref.invalidateSelf();
    ref.invalidate(allLogsProvider); // 캘린더 갱신
  }

  Future<void> addExercise(Exercise exercise) async {
    final log = state.valueOrNull;
    if (log == null) return;
    await ref.read(_logRepoProvider).addExercise(log, exercise);
    ref.invalidateSelf();
    ref.invalidate(allLogsProvider); // 캘린더 갱신
  }

  Future<void> deleteMeal(Meal meal) async {
    final log = state.valueOrNull;
    if (log == null) return;
    await ref.read(_logRepoProvider).deleteMeal(log, meal);
    ref.invalidateSelf();
    ref.invalidate(allLogsProvider); // 캘린더 갱신
  }

  Future<void> deleteExercise(Exercise exercise) async {
    final log = state.valueOrNull;
    if (log == null) return;
    await ref.read(_logRepoProvider).deleteExercise(log, exercise);
    ref.invalidateSelf();
    ref.invalidate(allLogsProvider); // 캘린더 갱신
  }
}

final dailyLogProvider = AsyncNotifierProvider<DailyLogNotifier, DailyLog?>(
  DailyLogNotifier.new,
);

/// 모든 로그 (캘린더용)
final allLogsProvider = FutureProvider<List<DailyLog>>(
  (ref) => ref.read(_logRepoProvider).getAllLogs(),
);

/// 특정 날짜의 DailyLog 읽기 전용 조회 (캘린더 상세 열람용)
/// 기록이 없으면 null 반환
final dayDetailProvider =
    FutureProvider.family<DailyLog?, DateTime>((ref, date) {
  final normalized = DateTime(date.year, date.month, date.day);
  return ref.read(_logRepoProvider).getLog(normalized);
});

/// 이번 주 (월~일) 7일치 로그 — null 이면 해당 날 기록 없음
final weeklyLogsProvider = FutureProvider<List<DailyLog?>>((ref) async {
  ref.watch(dailyLogProvider); // 오늘 로그 변경 시 자동 갱신
  final today = DateTime.now();
  final monday = today.subtract(Duration(days: today.weekday - 1));
  final allLogs = await ref.read(_logRepoProvider).getAllLogs();
  return List.generate(7, (i) {
    final day = DateTime(monday.year, monday.month, monday.day + i);
    try {
      return allLogs.firstWhere(
        (l) =>
            l.date.year == day.year &&
            l.date.month == day.month &&
            l.date.day == day.day,
      );
    } catch (_) {
      return null;
    }
  });
});
