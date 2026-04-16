import 'dart:io';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../domain/models/video_clip.dart';
import '../../domain/models/daily_log.dart';
import '../local/isar_service.dart';

/// VideoClip 저장/삭제 레포지토리
class ClipRepository {
  Future<Isar> get _db => IsarService.getInstance();

  /// clips/ 디렉토리 경로 반환 (없으면 생성)
  Future<String> getClipsDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/clips');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir.path;
  }

  /// 클립 저장 후 DailyLog에 연결
  Future<VideoClip> saveClip({
    required DailyLog log,
    required String filePath, // 카메라 임시 경로
    required String thumbnailPath,
    required int durationSeconds,
    required String tag,
  }) async {
    // clips/ 디렉토리로 파일 이동
    final clipsDir = await getClipsDir();
    final ts = DateTime.now().millisecondsSinceEpoch;
    final finalPath = '$clipsDir/${ts}_$tag.mp4';
    await File(filePath).copy(finalPath);
    await File(filePath).delete();

    final isar = await _db;
    final clip = VideoClip()
      ..filePath = finalPath
      ..thumbnailPath = thumbnailPath
      ..durationSeconds = durationSeconds
      ..timestamp = DateTime.now()
      ..tag = tag;

    await isar.writeTxn(() async {
      await isar.videoClips.put(clip);
      log.clips.add(clip);
      await log.clips.save();
    });
    return clip;
  }

  /// 클립 삭제 (파일 + DB)
  Future<void> deleteClip(DailyLog log, VideoClip clip) async {
    final isar = await _db;
    // 파일 삭제
    final file = File(clip.filePath);
    if (file.existsSync()) file.deleteSync();
    final thumb = File(clip.thumbnailPath);
    if (thumb.existsSync()) thumb.deleteSync();

    await isar.writeTxn(() async {
      log.clips.remove(clip);
      await log.clips.save();
      await isar.videoClips.delete(clip.id);
    });
  }
}
