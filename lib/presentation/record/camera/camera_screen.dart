import 'dart:async';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderRepaintBoundary;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../../data/repository/clip_repository.dart';
import '../../../providers/camera_provider.dart';
import '../../../providers/daily_log_provider.dart';
import '../../../providers/preferences_provider.dart';
import '../../../utils/video_utils.dart';

class CameraScreen extends ConsumerStatefulWidget {
  final String tag;
  const CameraScreen({super.key, required this.tag});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  CameraController? _controller;
  Timer? _timer;
  late int _selectedDuration;

  /// RepaintBoundary 키 — 워터마크 썸네일 캡처용
  final _previewKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _selectedDuration = ref.read(recordDurationProvider);
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;
    _controller = CameraController(cameras.first, ResolutionPreset.high);
    await _controller!.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    await _controller!.startVideoRecording();
    ref.read(cameraProvider.notifier).startRecording(_selectedDuration);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      ref.read(cameraProvider.notifier).tick();
      final state = ref.read(cameraProvider);
      if (!state.isRecording) {
        _timer?.cancel();
        _stopRecording();
      }
    });
  }

  Future<void> _stopRecording() async {
    if (_controller == null || !_controller!.value.isRecordingVideo) return;
    final file = await _controller!.stopVideoRecording();
    ref.read(cameraProvider.notifier).stop();

    // 햅틱 피드백
    await HapticFeedback.heavyImpact();

    // 태그 선택 BottomSheet
    if (!mounted) return;
    final tag = await _showTagSheet();
    if (tag == null) return;

    // 썸네일 추출 — 워터마크 활성 시 RepaintBoundary 캡처, 아니면 첫 프레임
    final watermarkEnabled = ref.read(userProfileProvider).watermarkEnabled;
    String thumbPath;
    if (watermarkEnabled) {
      final renderObject = _previewKey.currentContext?.findRenderObject();
      if (renderObject is RenderRepaintBoundary) {
        thumbPath = await VideoUtils.captureWatermarkedThumbnail(renderObject);
      } else {
        thumbPath = await VideoUtils.extractThumbnail(file.path);
      }
    } else {
      thumbPath = await VideoUtils.extractThumbnail(file.path);
    }

    final log = ref.read(dailyLogProvider).valueOrNull;
    if (log == null) return;

    await ClipRepository().saveClip(
      log: log,
      filePath: file.path,
      thumbnailPath: thumbPath,
      durationSeconds: _selectedDuration,
      tag: tag,
    );

    if (!mounted) return;

    // 저장 완료 SnackBar + 공유 버튼
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('저장 완료'),
        action: SnackBarAction(
          label: '공유하기',
          onPressed: () => Share.shareXFiles([XFile(file.path)]),
        ),
        duration: const Duration(seconds: 4),
      ),
    );

    context.pop();
  }

  Future<String?> _showTagSheet() async {
    return showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(title: Text('어떤 기록인가요?')),
            ListTile(
              leading: const Icon(Icons.restaurant),
              title: const Text('식사'),
              onTap: () => Navigator.pop(ctx, 'meal'),
            ),
            ListTile(
              leading: const Icon(Icons.fitness_center),
              title: const Text('운동'),
              onTap: () => Navigator.pop(ctx, 'exercise'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final camState = ref.watch(cameraProvider);
    final duration = _selectedDuration;
    final watermarkEnabled = ref.watch(userProfileProvider).watermarkEnabled;

    // 워터마크용 칼로리 정보
    final logAsync = ref.watch(dailyLogProvider);
    final netCalories = logAsync.whenOrNull(
      data: (log) {
        if (log == null) return null;
        final intake = log.meals.fold<double>(0, (s, m) => s + m.calories);
        final burned = log.exercises.fold<double>(
          0,
          (s, e) => s + e.caloriesBurned,
        );
        return intake - burned;
      },
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 카메라 프리뷰 — 워터마크 활성 시 RepaintBoundary로 감쌈
          if (_controller != null && _controller!.value.isInitialized)
            watermarkEnabled
                ? RepaintBoundary(
                    key: _previewKey,
                    child: Stack(
                      children: [
                        SizedBox.expand(child: CameraPreview(_controller!)),
                        Positioned(
                          top: MediaQuery.of(context).padding.top + 12,
                          right: 12,
                          child: _WatermarkOverlay(netCalories: netCalories),
                        ),
                      ],
                    ),
                  )
                : Center(child: CameraPreview(_controller!))
          else
            const Center(child: CircularProgressIndicator(color: Colors.white)),

          // 원형 카운트다운
          if (camState.isRecording)
            Center(
              child: SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: camState.countdown / duration,
                      strokeWidth: 6,
                      color: Colors.white,
                    ),
                    Text(
                      '${camState.countdown}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 촬영 시간 선택 + 촬영 버튼
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [2, 5, 10].map((s) {
                    final selected = duration == s;
                    return GestureDetector(
                      onTap: () async {
                        setState(() => _selectedDuration = s);
                        final prefs = ref.read(preferencesProvider).valueOrNull;
                        if (prefs != null) {
                          await ref
                              .read(userProfileProvider.notifier)
                              .update(prefs: prefs, recordDuration: s);
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: selected ? Colors.white : Colors.white24,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$s초',
                          style: TextStyle(
                            color: selected ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: camState.isRecording ? null : _startRecording,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: camState.isRecording ? Colors.red : Colors.white,
                    ),
                    child: Icon(
                      camState.isRecording ? Icons.stop : Icons.videocam,
                      color: camState.isRecording ? Colors.white : Colors.black,
                      size: 32,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 닫기
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => context.pop(),
            ),
          ),
        ],
      ),
    );
  }
}

/// 카메라 프리뷰 위에 얹히는 워터마크 오버레이 위젯
class _WatermarkOverlay extends StatelessWidget {
  final double? netCalories;
  const _WatermarkOverlay({this.netCalories});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _WatermarkPainter(
        appName: '갓상로그',
        date: DateFormat('yyyy.MM.dd', 'ko').format(DateTime.now()),
        netCalories: netCalories,
      ),
      size: const Size(160, 52),
    );
  }
}

/// 앱 이름 + 날짜 + 칼로리를 반투명 배경 위에 그리는 CustomPainter
class _WatermarkPainter extends CustomPainter {
  final String appName;
  final String date;
  final double? netCalories;

  _WatermarkPainter({
    required this.appName,
    required this.date,
    this.netCalories,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 반투명 배경
    final bgPaint = Paint()..color = Colors.black.withValues(alpha: 0.45);
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(8),
    );
    canvas.drawRRect(rrect, bgPaint);

    const textStyle = TextStyle(
      color: Colors.white,
      fontSize: 11,
      fontWeight: FontWeight.w600,
      shadows: [Shadow(blurRadius: 2, color: Colors.black54)],
    );

    // 앱 이름
    _drawText(canvas, appName, textStyle, const Offset(8, 6));

    // 날짜
    _drawText(
      canvas,
      date,
      textStyle.copyWith(fontWeight: FontWeight.normal, fontSize: 10),
      const Offset(8, 22),
    );

    // 칼로리
    if (netCalories != null) {
      final kcalText = '${netCalories!.toInt()} kcal';
      _drawText(
        canvas,
        kcalText,
        textStyle.copyWith(color: const Color(0xFF69F0AE), fontSize: 10),
        const Offset(8, 37),
      );
    }
  }

  void _drawText(Canvas canvas, String text, TextStyle style, Offset offset) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_WatermarkPainter old) =>
      old.netCalories != netCalories ||
      old.date != date ||
      old.appName != appName;
}
