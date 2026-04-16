import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:godsanglog/app/app.dart';
import 'package:godsanglog/data/local/preferences.dart';
import 'package:godsanglog/domain/models/daily_log.dart';
import 'package:godsanglog/providers/daily_log_provider.dart';
import 'package:godsanglog/providers/preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── 가짜 Notifier ─────────────────────────────────────────────────────────────

class _FakeDailyLogNotifier extends DailyLogNotifier {
  @override
  Future<DailyLog?> build() async => DailyLog()
    ..date = DateTime.now()
    ..goalCalories = 1800;
}

class _FakeUserProfileNotifier extends UserProfileNotifier {
  @override
  UserProfile build() => const UserProfile();
}

// ── 스모크 테스트 ──────────────────────────────────────────────────────────────

void main() {
  setUpAll(() {
    // dotenv 테스트용 동기 로드
    dotenv.testLoad(fileInput: 'FOOD_API_KEY=test_key');
    // SharedPreferences 목 초기화
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('앱 초기 렌더링 스모크 테스트', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dailyLogProvider.overrideWith(_FakeDailyLogNotifier.new),
          allLogsProvider.overrideWith((_) async => <DailyLog>[]),
          userProfileProvider.overrideWith(_FakeUserProfileNotifier.new),
          preferencesProvider.overrideWith((_) async {
            final sp = await SharedPreferences.getInstance();
            return AppPreferences(sp);
          }),
        ],
        child: const GodSangLogApp(),
      ),
    );

    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
