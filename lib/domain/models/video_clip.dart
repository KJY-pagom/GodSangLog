import 'package:isar/isar.dart';

part 'video_clip.g.dart';

/// 영상 클립 컬렉션
@Collection()
class VideoClip {
  Id id = Isar.autoIncrement;

  /// 영상 파일 경로 (앱 Document/clips/{timestamp}_{tag}.mp4)
  late String filePath;

  /// 썸네일 이미지 경로
  late String thumbnailPath;

  /// 영상 길이 (초)
  late int durationSeconds;

  /// 촬영 일시
  late DateTime timestamp;

  /// 태그 (meal / exercise)
  late String tag;
}
