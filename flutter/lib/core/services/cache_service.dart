import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

/// Entry in the cache with value, expiry, and metadata
class CacheEntry<T> {
  final T value;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String? etag;

  CacheEntry({
    required this.value,
    required this.createdAt,
    required this.expiresAt,
    this.etag,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Duration get age => DateTime.now().difference(createdAt);
  Duration get ttlRemaining => expiresAt.difference(DateTime.now());

  Map<String, dynamic> toJson(dynamic Function(T) valueSerializer) {
    return {
      'value': valueSerializer(value),
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'etag': etag,
    };
  }

  static CacheEntry<T>? fromJson<T>(
    Map<String, dynamic>? json,
    T Function(dynamic) valueDeserializer,
  ) {
    if (json == null) return null;
    try {
      return CacheEntry<T>(
        value: valueDeserializer(json['value']),
        createdAt: DateTime.parse(json['createdAt'] as String),
        expiresAt: DateTime.parse(json['expiresAt'] as String),
        etag: json['etag'] as String?,
      );
    } catch (_) {
      return null;
    }
  }
}

/// Cache service with memory and file-based persistence
/// Supports TTL, size limits, and cache invalidation patterns
class CacheService extends GetxService {
  static CacheService get instance => Get.find<CacheService>();

  // Memory cache
  final Map<String, CacheEntry<dynamic>> _memoryCache = {};

  // Configuration
  static const int maxMemoryEntries = 100;
  static const Duration defaultTtl = Duration(minutes: 5);
  static const Duration longTtl = Duration(hours: 1);
  static const Duration shortTtl = Duration(minutes: 1);

  // File cache directory
  Directory? _cacheDir;

  @override
  void onInit() {
    super.onInit();
    _initCacheDirectory();
  }

  Future<void> _initCacheDirectory() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      _cacheDir = Directory('${appDir.path}/cache');
      if (!await _cacheDir!.exists()) {
        await _cacheDir!.create(recursive: true);
      }
    } catch (_) {
      // File cache not available, memory-only mode
    }
  }

  /// Get an item from cache
  /// Returns null if not found or expired
  T? get<T>(String key) {
    final entry = _memoryCache[key];
    if (entry == null) return null;

    if (entry.isExpired) {
      _memoryCache.remove(key);
      return null;
    }

    return entry.value as T;
  }

  /// Get an item from cache with its metadata
  CacheEntry<T>? getEntry<T>(String key) {
    final entry = _memoryCache[key];
    if (entry == null) return null;

    if (entry.isExpired) {
      _memoryCache.remove(key);
      return null;
    }

    return entry as CacheEntry<T>;
  }

  /// Put an item in cache with optional TTL
  void put<T>(
    String key,
    T value, {
    Duration? ttl,
    String? etag,
  }) {
    final effectiveTtl = ttl ?? defaultTtl;
    final now = DateTime.now();

    _memoryCache[key] = CacheEntry<T>(
      value: value,
      createdAt: now,
      expiresAt: now.add(effectiveTtl),
      etag: etag,
    );

    // Enforce size limit
    _enforceMemoryLimit();
  }

  /// Get or fetch: returns cached value or executes fetcher
  Future<T> getOrFetch<T>(
    String key,
    Future<T> Function() fetcher, {
    Duration? ttl,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = get<T>(key);
      if (cached != null) return cached;
    }

    final value = await fetcher();
    put<T>(key, value, ttl: ttl);
    return value;
  }

  /// Remove an item from cache
  void remove(String key) {
    _memoryCache.remove(key);
  }

  /// Remove all items matching a pattern
  void removePattern(String pattern) {
    final regex = RegExp(pattern);
    _memoryCache.removeWhere((key, _) => regex.hasMatch(key));
  }

  /// Invalidate cache for a specific resource type
  /// e.g., invalidateResource('outfits') clears 'outfits/*'
  void invalidateResource(String resource) {
    removePattern('^$resource/');
    removePattern('^$resource\$');
  }

  /// Clear all cache entries
  void clear() {
    _memoryCache.clear();
  }

  /// Clear expired entries
  void clearExpired() {
    _memoryCache.removeWhere((_, entry) => entry.isExpired);
  }

  /// Enforce memory limit by removing oldest entries
  void _enforceMemoryLimit() {
    if (_memoryCache.length <= maxMemoryEntries) return;

    // Sort by creation time and remove oldest
    final entries = _memoryCache.entries.toList()
      ..sort((a, b) => a.value.createdAt.compareTo(b.value.createdAt));

    final toRemove = entries.length - maxMemoryEntries;
    for (var i = 0; i < toRemove; i++) {
      _memoryCache.remove(entries[i].key);
    }
  }

  // ===== File-based persistence for larger data =====

  /// Persist a value to file cache
  Future<void> persistToFile<T>(
    String key,
    T value,
    dynamic Function(T) serializer, {
    Duration? ttl,
  }) async {
    if (_cacheDir == null) return;

    final effectiveTtl = ttl ?? longTtl;
    final now = DateTime.now();
    final entry = CacheEntry<T>(
      value: value,
      createdAt: now,
      expiresAt: now.add(effectiveTtl),
    );

    try {
      final file = File('${_cacheDir!.path}/${_sanitizeKey(key)}.json');
      final json = entry.toJson(serializer);
      await file.writeAsString(jsonEncode(json));
    } catch (_) {
      // Silently fail on file write errors
    }
  }

  /// Read a value from file cache
  Future<T?> readFromFile<T>(
    String key,
    T Function(dynamic) deserializer,
  ) async {
    if (_cacheDir == null) return null;

    try {
      final file = File('${_cacheDir!.path}/${_sanitizeKey(key)}.json');
      if (!await file.exists()) return null;

      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      final entry = CacheEntry.fromJson<T>(json, deserializer);

      if (entry == null || entry.isExpired) {
        await file.delete();
        return null;
      }

      return entry.value;
    } catch (_) {
      return null;
    }
  }

  /// Clear file cache
  Future<void> clearFileCache() async {
    if (_cacheDir == null) return;

    try {
      if (await _cacheDir!.exists()) {
        await _cacheDir!.delete(recursive: true);
        await _cacheDir!.create(recursive: true);
      }
    } catch (_) {
      // Silently fail
    }
  }

  String _sanitizeKey(String key) {
    return key.replaceAll(RegExp(r'[^\w\-]'), '_');
  }

  // ===== Cache statistics =====

  int get memoryEntryCount => _memoryCache.length;

  Map<String, dynamic> get stats => {
    'memoryEntries': _memoryCache.length,
    'maxMemoryEntries': maxMemoryEntries,
    'keys': _memoryCache.keys.toList(),
  };
}

/// Extension for common cache key patterns
extension CacheKeys on String {
  /// Create a cache key for a list resource
  String get listKey => '$this/list';

  /// Create a cache key for a single resource
  String itemKey(String id) => '$this/$id';

  /// Create a cache key for a filtered list
  String filteredKey(Map<String, dynamic> filters) {
    final filterStr = filters.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');
    return '$this/list?$filterStr';
  }
}
