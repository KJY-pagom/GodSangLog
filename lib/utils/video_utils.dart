import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';

/// 영상 썸네일 추출 헬퍼
class VideoUtils {
  /// 첫 프레임 썸네일 추출 → 저장 경로 반환
  static Future<String> extractThumbnail(String videoPath) async {
    final dir = await getApplicationDocumentsDirectory();
    final thumbsDir = Directory('${dir.path}/thumbs');
    if (!thumbsDir.existsSync()) thumbsDir.createSync(recursive: true);
    final thumbPath = await VideoThumbnail.thumbnailFile(
      video: videoPath,
      thumbnailPath: thumbsDir.path,
      imageFormat: ImageFormat.JPEG,
      maxHeight: 200,
      quality: 75,
    );
    return thumbPath ?? '';
  }

  /// RepaintBoundary를 JPEG로 캡처 → 워터마크 썸네일 경로 반환
  static Future<String> captureWatermarkedThumbnail(
    RenderRepaintBoundary boundary,
  ) async {
    final image = await boundary.toImage(pixelRatio: 1.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return '';

    final dir = await getApplicationDocumentsDirectory();
    final thumbsDir = Directory('${dir.path}/thumbs');
    if (!thumbsDir.existsSync()) thumbsDir.createSync(recursive: true);

    final ts = DateTime.now().millisecondsSinceEpoch;
    final filePath = '${thumbsDir.path}/${ts}_wm.png';
    await File(filePath).writeAsBytes(byteData.buffer.asUint8List());
    return filePath;
  }
}
