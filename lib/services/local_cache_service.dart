import 'package:hive_flutter/hive_flutter.dart';

class LocalCacheService {
  static const String _boxName = 'api_cache';

  static Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<Map>(_boxName);
    }
  }

  static T? read<T>(
    String key, {
    Duration? maxAge,
  }) {
    final box = Hive.box<Map>(_boxName);
    final entry = box.get(key);
    if (entry == null) {
      return null;
    }
    final timestamp = entry['timestamp'] as int?;
    if (maxAge != null && timestamp != null) {
      final cachedAt = DateTime.fromMillisecondsSinceEpoch(timestamp);
      if (DateTime.now().difference(cachedAt) > maxAge) {
        return null;
      }
    }
    return entry['data'] as T?;
  }

  static Future<void> write(String key, dynamic data) async {
    final box = Hive.box<Map>(_boxName);
    await box.put(key, {
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'data': data,
    });
  }

  static Future<void> remove(String key) async {
    final box = Hive.box<Map>(_boxName);
    await box.delete(key);
  }

  static Future<void> clear() async {
    final box = Hive.box<Map>(_boxName);
    await box.clear();
  }
}
