import 'package:flutter_test/flutter_test.dart';
import 'package:godsanglog/data/remote/food_api.dart';

void main() {
  group('FoodItem.fromJson', () {
    test('정상 응답 파싱 (double 타입)', () {
      final item = FoodItem.fromJson({
        '식품명': '닭가슴살',
        '에너지(kcal)': 165.0,
        '단백질(g)': 31.0,
        '탄수화물(g)': 0.0,
        '지방(g)': 3.6,
        '1회 제공량(g)': 100.0,
      });
      expect(item.name, '닭가슴살');
      expect(item.calories, 165.0);
      expect(item.protein, 31.0);
      expect(item.carbs, 0.0);
      expect(item.fat, 3.6);
      expect(item.servingSize, 100.0);
    });

    test('숫자 필드가 int로 와도 double로 변환', () {
      final item = FoodItem.fromJson({
        '식품명': '현미밥',
        '에너지(kcal)': 150,
        '단백질(g)': 3,
        '탄수화물(g)': 33,
        '지방(g)': 1,
        '1회 제공량(g)': 150,
      });
      expect(item.calories, 150.0);
      expect(item.protein, 3.0);
      expect(item.carbs, 33.0);
    });

    test('숫자 문자열도 double로 변환', () {
      final item = FoodItem.fromJson({
        '식품명': '테스트',
        '에너지(kcal)': '120.5',
        '단백질(g)': '10.2',
        '탄수화물(g)': '15',
        '지방(g)': '3.1',
        '1회 제공량(g)': '100',
      });
      expect(item.calories, closeTo(120.5, 0.001));
      expect(item.protein, closeTo(10.2, 0.001));
    });

    test('누락된 필드는 0.0으로 처리', () {
      final item = FoodItem.fromJson({'식품명': '불완전한데이터'});
      expect(item.calories, 0.0);
      expect(item.protein, 0.0);
      expect(item.carbs, 0.0);
      expect(item.fat, 0.0);
      expect(item.servingSize, 0.0);
    });

    test('식품명 null이면 빈 문자열', () {
      final item = FoodItem.fromJson({});
      expect(item.name, '');
    });

    test('파싱 불가 문자열이면 0.0', () {
      final item = FoodItem.fromJson({'식품명': '테스트', '에너지(kcal)': 'N/A'});
      expect(item.calories, 0.0);
    });
  });
}
