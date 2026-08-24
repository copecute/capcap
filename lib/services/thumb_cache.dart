import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';

class ThumbCache {
  static Directory? _dir;
  static final Map<String, Future<File?>> _inflight = {};

  static Future<Directory> directory() async {
    if (_dir != null) return _dir!;
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/thumb_cache');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    _dir = dir;
    return dir;
  }

  static String _safeId(String id) =>
      id.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');

  static Future<File?> forAsset(AssetEntity asset, {int size = 300}) {
    return _inflight.putIfAbsent(asset.id, () async {
      try {
        final dir = await directory();
        final file = File('${dir.path}/a_${_safeId(asset.id)}.jpg');
        if (await file.exists() && await file.length() > 0) {
          return file;
        }
        final data = await asset.thumbnailDataWithSize(
          ThumbnailSize(size, size),
        );
        if (data == null || data.isEmpty) return null;
        await file.writeAsBytes(data, flush: true);
        return file;
      } catch (_) {
        return null;
      } finally {
        _inflight.remove(asset.id);
      }
    });
  }

  static Future<String?> saveBytes(String name, Uint8List data) async {
    if (data.isEmpty) return null;
    final dir = await directory();
    final file = File('${dir.path}/$name.jpg');
    await file.writeAsBytes(data, flush: true);
    return file.path;
  }

  static Future<void> clear() async {
    _inflight.clear();
    final dir = _dir ??
        Directory(
          '${(await getApplicationDocumentsDirectory()).path}/thumb_cache',
        );
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
    _dir = null;
  }
}
