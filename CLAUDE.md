# 다이어트 트래커 앱 — CLAUDE.md

## 프로젝트 개요

칼로리 섭취/운동 소모를 기록하고, 하루 다이어트 성취를
월간 달력으로 확인하는 iOS 전용 Flutter 앱.
숏폼 영상 기록과 SNS 공유를 핵심 UX로 삼아 Z세대를 타깃으로 함.
한국 사용자 전용 서비스.

## 기술 스택

- Flutter (Dart) / iOS 전용 / 최소 지원 iOS 16.0
- 상태 관리: Riverpod
- 로컬 DB: Isar
- 영상 저장: path_provider + 로컬 파일시스템
- HTTP 통신: dio
- 환경변수: flutter_dotenv

## 외부 API

- 서비스: 공공데이터 포털 — 전국통합식품영양성분정보(가공식품)표준데이터
- 환경변수: FOOD_API_KEY (.env)
- 호출 위치: lib/data/remote/food_api.dart 에서만 호출
- 응답 캐싱: 동일 검색어는 앱 세션 내 메모리 캐시 유지
- 오류 시 SnackBar로 "검색 결과를 불러오지 못했습니다" 표시
- 응답 필드 매핑:
  name ← 식품명
  calories ← 에너지(kcal)
  protein ← 단백질(g)
  carbs ← 탄수화물(g)
  fat ← 지방(g)
  servingSize ← 1회 제공량(g)

## 영상 기록

- 형식: MP4 / 저장: 앱 Document 디렉토리 /clips/
- 파일명: {timestamp}\_{tag}.mp4
- 썸네일: video_thumbnail로 첫 프레임 추출 → 경로만 Isar 저장
- 촬영 시간 옵션: 2초 (기본) / 5초 / 10초 → SharedPreferences 저장
- 촬영 버튼 1회 탭 → 설정 시간만큼 자동 녹화 → 원형 카운트다운 표시
  → 종료 시 식사/운동 태그 BottomSheet → 저장 완료 햅틱 피드백
- 공유: share_plus (iOS 네이티브 공유 시트)
- 워터마크 옵션: CustomPainter로 앱 이름 + 날짜 + 칼로리 합성

## 디렉토리 구조

lib/
├── main.dart
├── app/
│ ├── app.dart
│ └── router.dart # go_router
├── data/
│ ├── remote/
│ │ └── food_api.dart
│ ├── local/
│ │ ├── isar_service.dart
│ │ └── preferences.dart
│ └── repository/
│ ├── food_repository.dart
│ ├── log_repository.dart
│ ├── recipe_repository.dart
│ └── clip_repository.dart
├── domain/
│ └── models/
│ ├── daily_log.dart
│ ├── meal.dart
│ ├── exercise.dart
│ ├── video_clip.dart
│ └── recipe_preset.dart
├── presentation/
│ ├── today/
│ ├── record/
│ │ ├── camera/
│ │ ├── food/
│ │ └── exercise/
│ ├── calendar/
│ └── settings/
├── providers/
└── utils/
├── calorie_calc.dart
├── video_utils.dart
└── exercise_mets.dart

## 데이터 모델

// Isar 컬렉션
DailyLog { date, goalCalories, IsarLinks<Meal/Exercise/VideoClip> }
Meal { name, calories, protein, carbs, fat, mealTime, source, clipId }
Exercise { type, durationMinutes, caloriesBurned, clipId }
VideoClip { filePath, thumbnailPath, durationSeconds, timestamp, tag }
RecipePreset { name, ingredients, calories, protein, carbs, fat, createdAt }

// SharedPreferences
UserProfile { gender, age, heightCm, weightKg, activityLevel,
goalCalories, recordDuration(2|5|10) }

## 칼로리 계산

// Mifflin-St Jeor BMR
남성: (10×체중) + (6.25×키) - (5×나이) + 5
여성: (10×체중) + (6.25×키) - (5×나이) - 161
→ BMR × 활동지수 × 0.85 = 다이어트 목표 칼로리

// 운동 소모
MET × 체중(kg) × 시간(h) — MET 값은 exercise_mets.dart 관리

## 코딩 규칙

- 상태 관리: Riverpod (Notifier 패턴)
- 라우팅: go_router
- 비동기: AsyncValue로 핸들링
- 파일명: snake_case / 클래스명: PascalCase
- API 호출은 presentation 레이어에서 직접 금지 (repository 경유)
- API 키 하드코딩 금지 (.env 사용)
- print() 금지 (debugPrint() 허용)
- Android 관련 파일 수정 금지
- File I/O, DB, 네트워크, 네이티브 플러그인 호출에는 항시 예외 처리 (try-catch + debugPrint + rethrow)

## Git

- 브랜치 전략: main(배포) / dev(개발) / feature/{기능명}
- 커밋 단위: 기능 단위로 작게
- 커밋 메시지 형식:
  feat: 카메라 촬영 타이머 선택 기능 추가
  fix: 칼로리 계산 오류 수정
  refactor: food_repository 캐싱 로직 분리
  chore: pubspec 패키지 버전 업데이트
- 커밋 전 dart format . 실행
- .env 파일은 .gitignore에 반드시 포함

## iOS 권한 (info.plist)

- NSCameraUsageDescription: 식단 및 운동 기록 영상 촬영
- NSMicrophoneUsageDescription: 영상 녹화 시 마이크 접근
- NSPhotoLibraryAddUsageDescription: 촬영 영상 저장

## pubspec.yaml 패키지

flutter_riverpod / riverpod_annotation / go_router
isar / isar_flutter_libs / isar_generator
camera / video_thumbnail / share_plus
dio / flutter_dotenv / shared_preferences
path_provider / intl


## 응답 언어

커밋 메시지, 주석 모두 한국어
