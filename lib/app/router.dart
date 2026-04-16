import 'package:go_router/go_router.dart';
import '../presentation/today/today_screen.dart';
import '../presentation/record/camera/camera_screen.dart';
import '../presentation/record/food/food_search_screen.dart';
import '../presentation/record/food/food_add_screen.dart';
import '../presentation/record/food/recipe_screen.dart';
import '../presentation/record/exercise/exercise_record_screen.dart';
import '../presentation/calendar/calendar_screen.dart';
import '../presentation/settings/settings_screen.dart';
import '../data/remote/food_api.dart';

final appRouter = GoRouter(
  initialLocation: '/today',
  routes: [
    GoRoute(path: '/today', builder: (_, __) => const TodayScreen()),
    GoRoute(
      path: '/record/camera',
      builder: (_, state) {
        final tag = state.uri.queryParameters['tag'] ?? 'meal';
        return CameraScreen(tag: tag);
      },
    ),
    GoRoute(path: '/record/food', builder: (_, __) => const FoodSearchScreen()),
    GoRoute(
      path: '/record/food/add',
      builder: (_, state) {
        final item = state.extra as FoodItem;
        return FoodAddScreen(item: item);
      },
    ),
    GoRoute(path: '/record/recipe', builder: (_, __) => const RecipeScreen()),
    GoRoute(
      path: '/record/exercise',
      builder: (_, __) => const ExerciseRecordScreen(),
    ),
    GoRoute(path: '/calendar', builder: (_, __) => const CalendarScreen()),
    GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
  ],
);
