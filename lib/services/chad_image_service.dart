import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/chad_evolution.dart';

/// Chad 이미지 캐싱 및 최적화 서비스
class ChadImageService {
  static final ChadImageService _instance = ChadImageService._internal();
  factory ChadImageService() => _instance;
  ChadImageService._internal();

  // 메모리 캐시 (LRU 방식)
  final Map<String, ImageProvider> _memoryCache = {};
  final List<String> _cacheOrder = [];
  static const int _maxMemoryCacheSize = 10; // 최대 10개 이미지 메모리 캐시

  // 디스크 캐시 디렉토리
  Directory? _cacheDirectory;
  
  // 이미지 로딩 상태 추적
  final Map<String, Future<ImageProvider>> _loadingImages = {};

  /// 서비스 초기화
  Future<void> initialize() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      _cacheDirectory = Directory('${appDir.path}/chad_images');
      
      if (!await _cacheDirectory!.exists()) {
        await _cacheDirectory!.create(recursive: true);
      }
      
      debugPrint('ChadImageService 초기화 완료: ${_cacheDirectory!.path}');
    } catch (e) {
      debugPrint('ChadImageService 초기화 오류: $e');
    }
  }

  /// Chad 이미지 경로 생성
  String _getChadImagePath(ChadEvolutionStage stage) {
    switch (stage) {
      case ChadEvolutionStage.sleepCapChad:
        return 'assets/images/수면모자차드.jpg';
      case ChadEvolutionStage.basicChad:
        return 'assets/images/기본차드.jpg';
      case ChadEvolutionStage.coffeeChad:
        return 'assets/images/커피차드.png';
      case ChadEvolutionStage.frontFacingChad:
        return 'assets/images/정면차드.jpg';
      case ChadEvolutionStage.sunglassesChad:
        return 'assets/images/썬글차드.jpg';
      case ChadEvolutionStage.glowingEyesChad:
        return 'assets/images/눈빔차드.jpg';
      case ChadEvolutionStage.doubleChad:
        return 'assets/images/더블차드.jpg';
    }
  }

  /// 캐시 키 생성
  String _generateCacheKey(ChadEvolutionStage stage, {int? size}) {
    final sizeStr = size != null ? '_${size}x$size' : '';
    return '${stage.name}$sizeStr';
  }

  /// 디스크 캐시 파일 경로 생성
  String _getDiskCachePath(String cacheKey) {
    final hash = md5.convert(utf8.encode(cacheKey)).toString();
    return '${_cacheDirectory!.path}/$hash.png';
  }

  /// 메모리 캐시에서 이미지 가져오기
  ImageProvider? _getFromMemoryCache(String cacheKey) {
    if (_memoryCache.containsKey(cacheKey)) {
      // LRU: 최근 사용된 항목을 맨 뒤로 이동
      _cacheOrder.remove(cacheKey);
      _cacheOrder.add(cacheKey);
      return _memoryCache[cacheKey];
    }
    return null;
  }

  /// 메모리 캐시에 이미지 저장
  void _saveToMemoryCache(String cacheKey, ImageProvider imageProvider) {
    // 캐시 크기 제한 확인
    if (_memoryCache.length >= _maxMemoryCacheSize) {
      // 가장 오래된 항목 제거 (LRU)
      final oldestKey = _cacheOrder.removeAt(0);
      _memoryCache.remove(oldestKey);
    }
    
    _memoryCache[cacheKey] = imageProvider;
    _cacheOrder.add(cacheKey);
  }

  /// 디스크 캐시에서 이미지 가져오기
  Future<ImageProvider?> _getFromDiskCache(String cacheKey) async {
    try {
      final filePath = _getDiskCachePath(cacheKey);
      final file = File(filePath);
      
      if (await file.exists()) {
        final imageProvider = FileImage(file);
        _saveToMemoryCache(cacheKey, imageProvider);
        return imageProvider;
      }
    } catch (e) {
      debugPrint('디스크 캐시에서 이미지 로드 오류: $e');
    }
    return null;
  }

  /// 디스크 캐시에 이미지 저장
  Future<void> _saveToDiskCache(String cacheKey, Uint8List imageData) async {
    try {
      final filePath = _getDiskCachePath(cacheKey);
      final file = File(filePath);
      await file.writeAsBytes(imageData);
      debugPrint('디스크 캐시에 이미지 저장: $filePath');
    } catch (e) {
      debugPrint('디스크 캐시에 이미지 저장 오류: $e');
    }
  }

  /// 이미지 리사이즈
  Future<Uint8List> _resizeImage(Uint8List imageData, int targetSize) async {
    try {
      final codec = await ui.instantiateImageCodec(
        imageData,
        targetWidth: targetSize,
        targetHeight: targetSize,
      );
      final frame = await codec.getNextFrame();
      final resizedImageData = await frame.image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      return resizedImageData!.buffer.asUint8List();
    } catch (e) {
      debugPrint('이미지 리사이즈 오류: $e');
      return imageData; // 원본 반환
    }
  }

  /// Chad 이미지 로드 (최적화된 버전)
  Future<ImageProvider> getChadImage(
    ChadEvolutionStage stage, {
    int? targetSize,
    bool preload = false,
  }) async {
    final cacheKey = _generateCacheKey(stage, size: targetSize);
    
    // 이미 로딩 중인 경우 기존 Future 반환
    if (_loadingImages.containsKey(cacheKey)) {
      return await _loadingImages[cacheKey]!;
    }

    // 메모리 캐시 확인
    final memoryImage = _getFromMemoryCache(cacheKey);
    if (memoryImage != null) {
      return memoryImage;
    }

    // 로딩 Future 생성 및 저장
    final loadingFuture = _loadImageFromSource(stage, targetSize, cacheKey);
    _loadingImages[cacheKey] = loadingFuture;

    try {
      final result = await loadingFuture;
      return result;
    } finally {
      // 로딩 완료 후 Future 제거
      _loadingImages.remove(cacheKey);
    }
  }

  /// 소스에서 이미지 로드
  Future<ImageProvider> _loadImageFromSource(
    ChadEvolutionStage stage,
    int? targetSize,
    String cacheKey,
  ) async {
    // 디스크 캐시 확인
    final diskImage = await _getFromDiskCache(cacheKey);
    if (diskImage != null) {
      return diskImage;
    }

    // 원본 에셋에서 로드
    final assetPath = _getChadImagePath(stage);
    final assetData = await rootBundle.load(assetPath);
    Uint8List imageData = assetData.buffer.asUint8List();

    // 리사이즈가 필요한 경우
    if (targetSize != null) {
      imageData = await _resizeImage(imageData, targetSize);
    }

    // 디스크 캐시에 저장
    await _saveToDiskCache(cacheKey, imageData);

    // 메모리 이미지 생성 및 캐시 저장
    final imageProvider = MemoryImage(imageData);
    _saveToMemoryCache(cacheKey, imageProvider);

    return imageProvider;
  }

  /// 모든 Chad 이미지 프리로드
  Future<void> preloadAllChadImages({int? targetSize}) async {
    final futures = <Future>[];
    
    for (final stage in ChadEvolutionStage.values) {
      futures.add(
        getChadImage(stage, targetSize: targetSize, preload: true)
          .catchError((e) {
            debugPrint('Chad 이미지 프리로드 오류 ($stage): $e');
          }),
      );
    }
    
    await Future.wait(futures);
    debugPrint('모든 Chad 이미지 프리로드 완료');
  }

  /// 특정 단계들의 이미지 프리로드 (다음 진화 준비)
  Future<void> preloadUpcomingChadImages(
    ChadEvolutionStage currentStage, {
    int? targetSize,
  }) async {
    final currentIndex = currentStage.index;
    final futures = <Future>[];
    
    // 현재 단계 + 다음 2단계까지 프리로드
    for (int i = currentIndex; i < currentIndex + 3 && i < ChadEvolutionStage.values.length; i++) {
      final stage = ChadEvolutionStage.values[i];
      futures.add(
        getChadImage(stage, targetSize: targetSize, preload: true)
          .catchError((e) {
            debugPrint('Chad 이미지 프리로드 오류 ($stage): $e');
          }),
      );
    }
    
    await Future.wait(futures);
    debugPrint('다음 Chad 이미지들 프리로드 완료');
  }

  /// 캐시 크기 가져오기
  Future<int> getCacheSize() async {
    try {
      if (_cacheDirectory == null || !await _cacheDirectory!.exists()) {
        return 0;
      }
      
      int totalSize = 0;
      await for (final entity in _cacheDirectory!.list()) {
        if (entity is File) {
          final stat = await entity.stat();
          totalSize += stat.size;
        }
      }
      return totalSize;
    } catch (e) {
      debugPrint('캐시 크기 계산 오류: $e');
      return 0;
    }
  }

  /// 캐시 정리
  Future<void> clearCache({bool memoryOnly = false}) async {
    try {
      // 메모리 캐시 정리
      _memoryCache.clear();
      _cacheOrder.clear();
      
      if (!memoryOnly && _cacheDirectory != null) {
        // 디스크 캐시 정리
        if (await _cacheDirectory!.exists()) {
          await for (final entity in _cacheDirectory!.list()) {
            if (entity is File) {
              await entity.delete();
            }
          }
        }
      }
      
      debugPrint('Chad 이미지 캐시 정리 완료 (메모리만: $memoryOnly)');
    } catch (e) {
      debugPrint('캐시 정리 오류: $e');
    }
  }

  /// 캐시 통계 정보
  Map<String, dynamic> getCacheStats() {
    return {
      'memoryCache': {
        'size': _memoryCache.length,
        'maxSize': _maxMemoryCacheSize,
        'keys': _cacheOrder.toList(),
      },
      'loadingImages': _loadingImages.length,
    };
  }

  /// 메모리 정리 (앱이 백그라운드로 갈 때 호출)
  void onMemoryPressure() {
    // 메모리 캐시의 절반 정리
    final removeCount = (_memoryCache.length / 2).ceil();
    for (int i = 0; i < removeCount && _cacheOrder.isNotEmpty; i++) {
      final oldestKey = _cacheOrder.removeAt(0);
      _memoryCache.remove(oldestKey);
    }
    debugPrint('메모리 압박으로 인한 Chad 이미지 캐시 정리: $removeCount개 제거');
  }
} 