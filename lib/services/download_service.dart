import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'baca.dart';
import 'getlistsurah.dart';

class DownloadService {
  static const String _cacheKey = 'cached_surah_content';
  static const String _cacheVersionKey = 'cache_version';
  static const int _currentCacheVersion = 4; // Increment this when cache structure changes - v4: Sort by publication date
  
  /// Check and migrate cache if needed
  static Future<void> _checkCacheVersion() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedVersion = prefs.getInt(_cacheVersionKey) ?? 0;
    
    if (cachedVersion < _currentCacheVersion) {
      print('Cache version outdated ($cachedVersion < $_currentCacheVersion). Clearing cache...');
      await clearCache();
      await prefs.setInt(_cacheVersionKey, _currentCacheVersion);
      print('Cache cleared and version updated to $_currentCacheVersion');
    }
  }
  
  /// Generate cache key with categoryUrl hash to distinguish between different variants (e.g., Juzuk 1, 2, 3)
  static String _getCacheKey(int surahIndex, int pageIndex, String? categoryUrl) {
    if (categoryUrl == null || categoryUrl.isEmpty) {
      return '${surahIndex}_$pageIndex';
    }
    // Use hashCode of categoryUrl to create a unique identifier
    final urlHash = categoryUrl.hashCode.abs();
    return '${surahIndex}_${pageIndex}_$urlHash';
  }

  /// Download all pages for a specific surah
  static Future<void> downloadSurahPages(int surahIndex, {String? categoryUrl}) async {
    try {
      // Check cache version before accessing cache
      await _checkCacheVersion();
      
      final surah = await GetListSurah.getSurahByIndex(surahIndex, categoryUrl: categoryUrl);
      if (surah == null) {
        print('Surah $surahIndex not found');
        return;
      }
      
      final totalPages = surah['totalPages'] as int;
      final urls = List<String>.from(surah['urls'] as List);
      
      print('Downloading surah $surahIndex (categoryUrl: $categoryUrl): $totalPages pages');
      
      // Get cached content
      final cachedContent = await _getCachedContent();
      
      // Download each page
      for (int pageIndex = 0; pageIndex < totalPages; pageIndex++) {
        final url = urls[pageIndex];
        final cacheKey = _getCacheKey(surahIndex, pageIndex, categoryUrl);
        
        print('Processing page $pageIndex: $url (cacheKey: $cacheKey)');
        
        // Skip if already cached
        if (cachedContent.containsKey(cacheKey)) {
          print('Page $pageIndex already cached, skipping');
          continue;
        }
        
        try {
          print('Downloading page $pageIndex...');
          // Fetch content from URL
          final content = await BacaService.fetchContentFromUrl(url, 'entry-content');
          
          if (content != null) {
            // Parse HTML to text
            final textContent = BacaService.parseHtmlToText(content);
            
            // Cache the content
            cachedContent[cacheKey] = {
              'url': url,
              'htmlContent': content,
              'textContent': textContent,
              'downloadTime': DateTime.now().toIso8601String(),
              'categoryUrl': categoryUrl, // Store categoryUrl for reference
            };
            
            // Save to cache
            await _saveCachedContent(cachedContent);
            print('Page $pageIndex downloaded and cached successfully');
          } else {
            print('Failed to get content for page $pageIndex');
          }
        } catch (e) {
          print('Error downloading page $pageIndex: $e');
        }
      }
      
      print('Completed downloading surah $surahIndex');
      
    } catch (e) {
      print('Error downloading surah $surahIndex: $e');
    }
  }
  
  /// Get cached content for a specific page
  static Future<Map<String, dynamic>?> getCachedPage(int surahIndex, int pageIndex, {String? categoryUrl}) async {
    // Check cache version before accessing cache
    await _checkCacheVersion();
    
    final cachedContent = await _getCachedContent();
    final cacheKey = _getCacheKey(surahIndex, pageIndex, categoryUrl);
    return cachedContent[cacheKey];
  }
  
  /// Check if surah is fully downloaded
  static Future<bool> isSurahDownloaded(int surahIndex, {String? categoryUrl}) async {
    try {
      final surah = await GetListSurah.getSurahByIndex(surahIndex, categoryUrl: categoryUrl);
      if (surah == null) return false;
      
      final totalPages = surah['totalPages'] as int;
      final cachedContent = await _getCachedContent();
      
      for (int pageIndex = 0; pageIndex < totalPages; pageIndex++) {
        final cacheKey = _getCacheKey(surahIndex, pageIndex, categoryUrl);
        if (!cachedContent.containsKey(cacheKey)) {
          return false;
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Clear all cached content
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
  }
  
  /// Debug method to check cached pages for a surah
  static Future<void> debugCachedPages(int surahIndex, {String? categoryUrl}) async {
    final cachedContent = await _getCachedContent();
    final surah = await GetListSurah.getSurahByIndex(surahIndex, categoryUrl: categoryUrl);
    
    if (surah == null) {
      print('Surah $surahIndex not found');
      return;
    }
    
    final totalPages = surah['totalPages'] as int;
    print('Debug: Surah $surahIndex (categoryUrl: $categoryUrl) has $totalPages pages');
    
    for (int pageIndex = 0; pageIndex < totalPages; pageIndex++) {
      final cacheKey = _getCacheKey(surahIndex, pageIndex, categoryUrl);
      final isCached = cachedContent.containsKey(cacheKey);
      print('Page $pageIndex (cacheKey: $cacheKey): ${isCached ? 'CACHED' : 'NOT CACHED'}');
    }
  }
  
  /// Private methods
  static Future<Map<String, dynamic>> _getCachedContent() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedJson = prefs.getString(_cacheKey);
    
    if (cachedJson != null) {
      return jsonDecode(cachedJson);
    }
    return {};
  }
  
  static Future<void> _saveCachedContent(Map<String, dynamic> content) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, jsonEncode(content));
  }
}