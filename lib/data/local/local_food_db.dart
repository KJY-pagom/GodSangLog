import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../remote/food_api.dart';

/// 로컬 식품 영양 DB (SQLite)
///
/// assets/food_db.sqlite 를 Document 디렉토리로 복사한 뒤
/// sqflite 로 쿼리한다.
class LocalFoodDb {
  static const _dbFileName = 'food_db.sqlite';
  static const _dbVersion = 1; // assets DB 교체 시 올릴 것

  Database? _db;

  Future<void> init() async {
    try {
      final docDir = await getApplicationDocumentsDirectory();
      final dbPath = p.join(docDir.path, _dbFileName);
      final versionFile = File('${dbPath}_ver');

      final needsCopy =
          !File(dbPath).existsSync() ||
          !versionFile.existsSync() ||
          int.tryParse(await versionFile.readAsString()) != _dbVersion;

      if (needsCopy) {
        debugPrint('LocalFoodDb: assets 에서 DB 복사 중...');
        final data = await rootBundle.load('assets/$_dbFileName');
        final bytes = data.buffer.asUint8List();
        await File(dbPath).writeAsBytes(bytes, flush: true);
        await versionFile.writeAsString('$_dbVersion');
        debugPrint('LocalFoodDb: 복사 완료 (${bytes.length ~/ 1024}KB)');
      }

      _db = await openDatabase(dbPath, readOnly: true);
    } catch (e, st) {
      debugPrint('LocalFoodDb init 오류: $e\n$st');
      rethrow;
    }
  }

  /// 식품명 검색
  ///
  /// 정렬 우선순위:
  ///   1. 완전 일치 (name = query)
  ///   2. 앞 일치  (name LIKE 'query%')
  ///   3. 부분 일치 (name LIKE '%query%')
  ///
  /// [offset] / [limit] 으로 페이지네이션 지원
  Future<List<FoodItem>> search(
    String query, {
    int limit = 20,
    int offset = 0,
  }) async {
    if (_db == null) return [];
    try {
      final rows = await _db!.rawQuery(
        '''
        SELECT name, calories, protein, fat, carbs, serving_size
        FROM foods
        WHERE name LIKE ?
        ORDER BY
          CASE
            WHEN name = ?          THEN 0
            WHEN name LIKE ?       THEN 1
            ELSE                        2
          END,
          length(name),
          name
        LIMIT ? OFFSET ?
        ''',
        ['%$query%', query, '$query%', limit, offset],
      );
      return rows.map(_rowToFoodItem).toList();
    } catch (e, st) {
      debugPrint('LocalFoodDb search 오류: $e\n$st');
      rethrow;
    }
  }

  FoodItem _rowToFoodItem(Map<String, Object?> row) {
    return FoodItem(
      name: row['name'] as String,
      calories: (row['calories'] as num?)?.toDouble() ?? 0,
      protein: (row['protein'] as num?)?.toDouble() ?? 0,
      carbs: (row['carbs'] as num?)?.toDouble() ?? 0,
      fat: (row['fat'] as num?)?.toDouble() ?? 0,
      servingSize: (row['serving_size'] as num?)?.toDouble() ?? 100,
    );
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
