import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import '../../domain/models/daily_log.dart';
import '../../domain/models/meal.dart';
import '../../domain/models/exercise.dart';
import '../local/isar_service.dart';

/// DailyLog CRUD 레포지토리
class LogRepository {
  Future<Isar> get _db => IsarService.getInstance();

  /// 날짜로 DailyLog 조회 (없으면 생성)
  Future<DailyLog> getOrCreateLog(DateTime date, double goalCalories) async {
    final isar = await _db;
    final normalized = _normalize(date);
    final existing = await isar.dailyLogs
        .where()
        .dateEqualTo(normalized)
        .findFirst();
    if (existing != null) {
      // 설정에서 목표 칼로리가 바뀐 경우 오늘 로그에 반영
      if (existing.goalCalories != goalCalories) {
        existing.goalCalories = goalCalories;
        await isar.writeTxn(() => isar.dailyLogs.put(existing));
      }
      return existing;
    }

    final log = DailyLog()
      ..date = normalized
      ..goalCalories = goalCalories;
    await isar.writeTxn(() => isar.dailyLogs.put(log));
    return log;
  }

  /// 날짜로 DailyLog 조회 (없으면 null 반환 — 과거 날짜 열람용)
  Future<DailyLog?> getLog(DateTime date) async {
    try {
      final isar = await _db;
      final log = await isar.dailyLogs
          .where()
          .dateEqualTo(_normalize(date))
          .findFirst();
      if (log != null) {
        await log.meals.load();
        await log.exercises.load();
        await log.clips.load();
      }
      return log;
    } catch (e, st) {
      debugPrint('LogRepository.getLog 오류: $e\n$st');
      rethrow;
    }
  }

  /// 날짜 목록 전체 조회 (캘린더용) — 성취 계산을 위해 링크 로드
  Future<List<DailyLog>> getAllLogs() async {
    final isar = await _db;
    final logs = await isar.dailyLogs.where().sortByDate().findAll();
    await Future.wait(
      logs.map((log) async {
        await log.meals.load();
        await log.exercises.load();
      }),
    );
    return logs;
  }

  /// 식사 기록 추가
  Future<void> addMeal(DailyLog log, Meal meal) async {
    final isar = await _db;
    await isar.writeTxn(() async {
      await isar.meals.put(meal);
      log.meals.add(meal);
      await log.meals.save();
    });
  }

  /// 운동 기록 추가
  Future<void> addExercise(DailyLog log, Exercise exercise) async {
    final isar = await _db;
    await isar.writeTxn(() async {
      await isar.exercises.put(exercise);
      log.exercises.add(exercise);
      await log.exercises.save();
    });
  }

  /// 식사 기록 삭제
  Future<void> deleteMeal(DailyLog log, Meal meal) async {
    final isar = await _db;
    await isar.writeTxn(() async {
      log.meals.remove(meal);
      await log.meals.save();
      await isar.meals.delete(meal.id);
    });
  }

  /// 운동 기록 삭제
  Future<void> deleteExercise(DailyLog log, Exercise exercise) async {
    final isar = await _db;
    await isar.writeTxn(() async {
      log.exercises.remove(exercise);
      await log.exercises.save();
      await isar.exercises.delete(exercise.id);
    });
  }

  DateTime _normalize(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
