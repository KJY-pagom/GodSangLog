import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../data/local/isar_service.dart';

/// Isar 인스턴스 Provider
final isarProvider = FutureProvider<Isar>((ref) => IsarService.getInstance());
