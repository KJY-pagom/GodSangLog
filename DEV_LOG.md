# GodSangLog 개발 로그

## 최근 작업 일자: 2026-04-17

---

## ✅ 완료된 작업

### 1. 로컬 식품 영양 DB 통합 (오프라인 검색)

**배경**
- 공공데이터 API만으로는 온라인 의존도가 높고 응답 속도가 느림
- 제공받은 엑셀 DB 2개를 앱 내 번들링 방식으로 통합

**변환 스크립트**
- 파일: `scripts/convert_food_db.py`
- 입력: `20250408_음식DB.xlsx` (14,584건) + `20260309_가공식품_256741건.xlsx` (256,741건)
- 출력: `assets/food_db.sqlite` (256,889건, 33.7MB, 중복 제거 후)
- 중복 제거 기준: 식품명 + 칼로리 동일한 경우 음식DB 우선 유지

**신규 파일**
| 파일 | 역할 |
|------|------|
| `scripts/convert_food_db.py` | 엑셀 → SQLite 변환 스크립트 |
| `assets/food_db.sqlite` | 번들 식품 영양 DB (256,889건) |
| `lib/data/local/local_food_db.dart` | SQLite 서비스 (asset 복사 + 검색) |

**수정 파일**
| 파일 | 변경 내용 |
|------|----------|
| `pubspec.yaml` | `sqflite: ^2.4.1`, `path: ^1.9.0` 추가 / `assets/food_db.sqlite` 등록 |
| `lib/data/repository/food_repository.dart` | 로컬 DB + API 병합 검색 |
| `lib/providers/food_provider.dart` | `localFoodDbProvider` + `FoodSearchResult` 상태 클래스 추가 |
| `lib/presentation/record/food/food_search_screen.dart` | 정렬 + 페이지네이션 UI 반영 |

---

### 2. 검색 정렬 개선 (완전 일치 우선)

**로직** (`local_food_db.dart` → `rawQuery`)
```
1순위: 완전 일치  — name = '닭가슴살'
2순위: 앞 일치   — name LIKE '닭가슴살%'
3순위: 부분 일치 — name LIKE '%닭가슴살%'
같은 순위 내: 이름 길이 짧은 순 → 가나다 순
```

---

### 3. 페이지네이션 (더보기)

- 최초 검색 결과: **20건** 표시
- 목록 최하단 **"더보기 (10건)"** 버튼 → 클릭 시 10건씩 추가 로드
- 더 불러올 결과 없으면 버튼 자동 숨김
- 로딩 중에는 버튼 대신 스피너 표시
- 새 검색 시 오프셋 자동 초기화

---

### 4. GitHub Push

- Remote: `https://github.com/KJY-pagom/GodSangLog.git`
- Branch: `main`
- 커밋: `feat: 다이어트 트래커 앱 초기 구현` (전체 초기 구현 포함)

---

## 🔲 다음 작업 후보

### 우선순위 높음
- [ ] **DB 갱신 흐름 정립**: 엑셀이 업데이트되면 `_dbVersion` 숫자 올리고 스크립트 재실행 → asset 교체 → 앱 배포
- [ ] **검색 성능 최적화**: 256k건 LIKE 쿼리 속도 실기기 테스트 필요 (목표: 300ms 이내)
  - 느릴 경우 FTS5 trigram 인덱스 도입 검토 (`CREATE VIRTUAL TABLE food_fts USING fts5(... tokenize='trigram')`)
- [ ] **food_search_screen.dart 검색 UX**: 검색 후 키보드 자동 닫기 처리

### 우선순위 중간
- [ ] **식품 상세 정보 표시**: 단백질 / 지방 / 탄수화물 수치도 목록에 표시 (현재는 칼로리만)
- [ ] **최근 검색어 히스토리**: SharedPreferences에 저장, 검색창 포커스 시 노출
- [ ] **즐겨찾기 음식**: 자주 먹는 음식 즐겨찾기 → Isar에 저장

### 우선순위 낮음
- [ ] **앱 전체 UI 완성도**: today_screen, calendar_screen, settings_screen 구현 상태 점검
- [ ] **카메라 촬영 타이머**: 2초/5초/10초 선택 기능 완성 여부 확인
- [ ] **워터마크 합성**: CustomPainter로 앱 이름 + 날짜 + 칼로리 영상 합성
- [ ] **iOS 빌드 테스트**: 실기기 연결 후 최초 실행 시 DB 복사 동작 확인

---

## 기술 메모

### SQLite DB 갱신 방법
```bash
# 새 엑셀 파일로 교체 후:
python scripts/convert_food_db.py

# local_food_db.dart 에서 버전 올리기:
static const _dbVersion = 2;  # 1 → 2
```
앱 재설치 없이도 버전 번호만 올리면 다음 실행 시 자동으로 새 DB로 교체됨.

### 검색 소스 구분
SQLite `source` 컬럼으로 출처 구분 가능:
- `'food'` → 20250408_음식DB (13,583건)
- `'processed'` → 20260309_가공식품 (243,306건)

### 패키지 버전
```yaml
sqflite: ^2.4.1
path: ^1.9.0
```
