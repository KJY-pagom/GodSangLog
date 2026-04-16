import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 공공데이터 포털 — 공공급식 식품영양성분 정보 API
class FoodApi {
  static const _baseUrl =
      'https://api.data.go.kr/openapi/tn_pubr_public_nutri_food_info_api';

  final Dio _dio;

  /// 세션 내 메모리 캐시 (검색어 → 결과)
  final Map<String, List<FoodItem>> _cache = {};

  FoodApi()
    : _dio = Dio(
        BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

  Future<List<FoodItem>> search(String query) async {
    if (_cache.containsKey(query)) return _cache[query]!;

    try {
      final apiKey = dotenv.env['FOOD_API_KEY'] ?? '';
      final response = await _dio.get(
        '',
        queryParameters: {
          'serviceKey': apiKey,
          'pageNo': 1,
          'numOfRows': 20,
          'type': 'json',
          'foodNm': query,
        },
      );

      final body =
          (response.data as Map<String, dynamic>)['response']?['body']
              as Map<String, dynamic>?;
      final raw = body?['items'];

      // items가 List 또는 Map(단일 결과) 모두 대응
      final List<dynamic> list;
      if (raw is List) {
        list = raw;
      } else if (raw is Map) {
        final item = raw['item'];
        list = item is List ? item : (item != null ? [item] : []);
      } else {
        list = [];
      }

      final items = list
          .map((e) => FoodItem.fromJson(e as Map<String, dynamic>))
          .toList();

      _cache[query] = items;
      return items;
    } on DioException catch (e) {
      debugPrint('FoodApi 오류: ${e.message}');
      throw FoodApiException('검색 결과를 불러오지 못했습니다');
    }
  }
}

/// 음식 검색 결과 모델
class FoodItem {
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double servingSize;

  const FoodItem({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.servingSize,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      name: (json['foodNm'] as String?) ?? '',
      calories: _toDouble(json['enerc']),
      protein: _toDouble(json['prot']),
      carbs: _toDouble(json['chocdf']),
      fat: _toDouble(json['fatce']),
      servingSize: _toDouble(json['servingWt']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}

class FoodApiException implements Exception {
  final String message;
  const FoodApiException(this.message);

  @override
  String toString() => message;
}
