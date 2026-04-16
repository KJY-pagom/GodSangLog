import '../local/local_food_db.dart';
import '../remote/food_api.dart';

/// 음식 검색 레포지토리
///
/// 검색 순서:
/// 1. 로컬 SQLite DB (오프라인, 빠름) — 정렬: 완전일치 → 앞일치 → 부분일치
/// 2. 공공 API (온라인, 보완) — 로컬 결과 부족 시만 호출
class FoodRepository {
  final LocalFoodDb _localDb;
  final FoodApi _api;

  FoodRepository(this._localDb, this._api);

  /// [offset]=0 이면 API 도 함께 조회, offset>0 이면 로컬 DB 페이지네이션만.
  Future<List<FoodItem>> search(
    String query, {
    int limit = 20,
    int offset = 0,
  }) async {
    List<FoodItem> localResults = [];
    try {
      localResults = await _localDb.search(query, limit: limit, offset: offset);
    } catch (_) {}

    // 첫 페이지이고 로컬 결과가 부족할 때만 API 보완
    if (offset == 0 && localResults.length < 5) {
      List<FoodItem> apiResults = [];
      try {
        apiResults = await _api.search(query);
      } catch (_) {}

      final seen = <String>{...localResults.map((e) => e.name)};
      for (final item in apiResults) {
        if (seen.add(item.name)) localResults.add(item);
      }
    }

    return localResults;
  }
}
