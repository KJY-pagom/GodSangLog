import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/local_food_db.dart';
import '../data/remote/food_api.dart';
import '../data/repository/food_repository.dart';

/// 로컬 식품 DB — 앱 시작 시 한 번만 초기화
final localFoodDbProvider = FutureProvider<LocalFoodDb>((ref) async {
  final db = LocalFoodDb();
  await db.init();
  ref.onDispose(db.close);
  return db;
});

final _foodApiProvider = Provider((_) => FoodApi());

// ───────────────────────────────────────────
// 검색 결과 상태
// ───────────────────────────────────────────

class FoodSearchResult {
  final List<FoodItem> items;

  /// 더 불러올 항목이 있는지 여부
  final bool hasMore;

  /// "더보기" 로딩 중 여부
  final bool isLoadingMore;

  const FoodSearchResult({
    this.items = const [],
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  FoodSearchResult copyWith({
    List<FoodItem>? items,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return FoodSearchResult(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

// ───────────────────────────────────────────
// Notifier
// ───────────────────────────────────────────

const _initialPageSize = 20;
const _morePageSize = 10;

class FoodSearchNotifier extends AsyncNotifier<FoodSearchResult> {
  String _query = '';
  int _offset = 0;

  @override
  Future<FoodSearchResult> build() async => const FoodSearchResult();

  Future<void> search(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      state = const AsyncValue.data(FoodSearchResult());
      return;
    }

    _query = q;
    _offset = 0;
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final localDb = await ref.read(localFoodDbProvider.future);
      final repo = FoodRepository(localDb, ref.read(_foodApiProvider));
      final items = await repo.search(q, limit: _initialPageSize, offset: 0);
      _offset = items.length;
      return FoodSearchResult(
        items: items,
        hasMore: items.length >= _initialPageSize,
      );
    });
  }

  /// 다음 10건 추가 로드
  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    // "더보기" 로딩 스피너 표시
    state = AsyncValue.data(current.copyWith(isLoadingMore: true));

    try {
      final localDb = await ref.read(localFoodDbProvider.future);
      final repo = FoodRepository(localDb, ref.read(_foodApiProvider));
      final more = await repo.search(
        _query,
        limit: _morePageSize,
        offset: _offset,
      );

      _offset += more.length;

      state = AsyncValue.data(
        FoodSearchResult(
          items: [...current.items, ...more],
          hasMore: more.length >= _morePageSize,
          isLoadingMore: false,
        ),
      );
    } catch (_) {
      // 더보기 실패 시 기존 목록 유지
      state = AsyncValue.data(current.copyWith(isLoadingMore: false));
    }
  }

  void clear() {
    _query = '';
    _offset = 0;
    state = const AsyncValue.data(FoodSearchResult());
  }
}

final foodSearchProvider =
    AsyncNotifierProvider<FoodSearchNotifier, FoodSearchResult>(
      FoodSearchNotifier.new,
    );
