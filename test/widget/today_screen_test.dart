import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:godsanglog/domain/models/daily_log.dart';
import 'package:godsanglog/presentation/today/today_screen.dart';
import 'package:godsanglog/providers/daily_log_provider.dart';

// ── 가짜 Notifier ─────────────────────────────────────────────────────────────

/// Isar 없이 고정 DailyLog를 반환하는 가짜 Notifier
class _FakeDailyLogNotifier extends DailyLogNotifier {
  final DailyLog? value;
  _FakeDailyLogNotifier(this.value);

  @override
  Future<DailyLog?> build() async => value;
}

/// 로딩 상태를 유지하는 Notifier (build가 영원히 완료되지 않음)
class _LoadingDailyLogNotifier extends DailyLogNotifier {
  @override
  Future<DailyLog?> build() => Completer<DailyLog?>().future;
}

// ── 헬퍼 ──────────────────────────────────────────────────────────────────────

DailyLog _emptyLog({double goalCalories = 1800}) => DailyLog()
  ..date = DateTime.now()
  ..goalCalories = goalCalories;

Widget _wrap(Widget screen, DailyLog? log) => ProviderScope(
  overrides: [dailyLogProvider.overrideWith(() => _FakeDailyLogNotifier(log))],
  child: MaterialApp(home: screen),
);

// ── 테스트 ────────────────────────────────────────────────────────────────────

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ko');
  });

  group('TodayScreen', () {
    testWidgets('로그가 null이면 빈 화면 렌더링 (오류 없음)', (tester) async {
      await tester.pumpWidget(_wrap(const TodayScreen(), null));
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('로딩 중 CircularProgressIndicator 표시', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dailyLogProvider.overrideWith(_LoadingDailyLogNotifier.new),
          ],
          child: const MaterialApp(home: TodayScreen()),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('CalorieSummaryCard에 목표 칼로리 표시', (tester) async {
      await tester.pumpWidget(
        _wrap(const TodayScreen(), _emptyLog(goalCalories: 2000)),
      );
      await tester.pump();

      expect(find.text('목표: 2000 kcal'), findsOneWidget);
    });

    testWidgets('식사 기록 · 운동 기록 섹션 헤더 존재', (tester) async {
      await tester.pumpWidget(_wrap(const TodayScreen(), _emptyLog()));
      await tester.pump();

      expect(find.text('식사 기록'), findsOneWidget);
      expect(find.text('운동 기록'), findsOneWidget);
    });

    testWidgets('섭취·소모 0 일 때 잔여가 목표와 동일', (tester) async {
      await tester.pumpWidget(
        _wrap(const TodayScreen(), _emptyLog(goalCalories: 1800)),
      );
      await tester.pump();

      // 섭취 0, 소모 0 → 잔여 = 1800
      expect(find.text('1800 kcal'), findsWidgets);
    });

    testWidgets('각 섹션에 카메라·추가 아이콘 버튼 존재', (tester) async {
      await tester.pumpWidget(_wrap(const TodayScreen(), _emptyLog()));
      await tester.pump();

      expect(find.byIcon(Icons.videocam), findsWidgets);
      expect(find.byIcon(Icons.add), findsWidgets);
    });
  });
}
