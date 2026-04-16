import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'preferences_provider.dart';

/// 카메라 촬영 상태
class CameraState {
  final bool isRecording;
  final int countdown; // 남은 초

  const CameraState({this.isRecording = false, this.countdown = 0});

  CameraState copyWith({bool? isRecording, int? countdown}) {
    return CameraState(
      isRecording: isRecording ?? this.isRecording,
      countdown: countdown ?? this.countdown,
    );
  }
}

class CameraNotifier extends Notifier<CameraState> {
  @override
  CameraState build() => const CameraState();

  void startRecording(int durationSeconds) {
    state = CameraState(isRecording: true, countdown: durationSeconds);
  }

  void tick() {
    if (state.countdown > 0) {
      state = state.copyWith(countdown: state.countdown - 1);
    }
    if (state.countdown == 0) {
      state = const CameraState();
    }
  }

  void stop() => state = const CameraState();
}

final cameraProvider = NotifierProvider<CameraNotifier, CameraState>(
  CameraNotifier.new,
);

/// 현재 선택된 촬영 시간 (SharedPreferences 동기화)
final recordDurationProvider = Provider<int>(
  (ref) => ref.watch(userProfileProvider).recordDuration,
);
