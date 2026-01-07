import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io' show Platform;

class VersionChecker {
  static const String versionApiUrl = 'https://c24-s60348.github.io/api/celiktafsir/version.json';
  
  /// Get current app version from package info
  static Future<String> getCurrentVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final version = packageInfo.version;
      final buildNumber = packageInfo.buildNumber;
      
      print('📱 PackageInfo - version: $version, buildNumber: $buildNumber');
      print('📱 App name: ${packageInfo.appName}');
      print('📱 Package name: ${packageInfo.packageName}');
      
      // If version is empty, invalid, or default "1.0.0", use fallback
      if (version.isEmpty || version == '0.0.0' || version == '1.0.0') {
        print('⚠️ Invalid/default version detected ($version), using fallback');
        return '1.0.20'; // Use current version from pubspec.yaml as fallback
      }
      
      return version; // Gets version from pubspec.yaml
    } catch (e) {
      print('❌ Error getting package version: $e');
      return '1.0.20'; // Use current version from pubspec.yaml as fallback
    }
  }
  
  /// Check if a new version is available
  /// Set [forceCheck] to true to bypass the rate limiting (useful for manual checks)
  /// Returns a list of all notifications (updates + news) to show
  static Future<List<VersionInfo>> checkForUpdate({bool forceCheck = false}) async {
    try {
      // Get current version from app's pubspec.yaml (NOT from API)
      final currentVersion = await getCurrentVersion();
      print('🔍 Current app version: $currentVersion');
      
      final prefs = await SharedPreferences.getInstance();
      
      // Don't check too frequently - once per day (unless forced)
      if (!forceCheck) {
        final lastCheck = prefs.getInt('last_version_check') ?? 0;
        final now = DateTime.now().millisecondsSinceEpoch;
        
        // Check only once per day (86400000 ms = 24 hours)
        if (now - lastCheck < 86400000) {
          print('Version check skipped - checked recently');
          return [];
        }
      }
      
      print('Checking for app updates...');
      final response = await http.get(Uri.parse(versionApiUrl)).timeout(
        const Duration(seconds: 10),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> platforms = data['data'] ?? [];
        
        // Determine current platform
        String platformName;
        if (kIsWeb) {
          platformName = 'web';
        } else if (Platform.isAndroid) {
          platformName = 'android';
        } else if (Platform.isIOS) {
          platformName = 'ios';
        } else {
          return [];
        }
        
        // Save last check time
        final now = DateTime.now().millisecondsSinceEpoch;
        await prefs.setInt('last_version_check', now);
        
        // Find ALL matching entries for current platform
        final platformDataList = platforms.where((p) => p['name'] == platformName).toList();
        
        List<VersionInfo> notifications = [];
        
        for (var platformData in platformDataList) {
          final isNews = platformData['type'] == 'news';
          
          // Support multiple field names for version from API
          final serverVersion = platformData['latest_version'] ?? 
                               platformData['force_version'] ?? 
                               platformData['current_version'] ?? 
                               '1.0.0';
          
          // For news, always add. For updates, check if version is newer
          if (isNews || _isNewerVersion(serverVersion, currentVersion)) {
            notifications.add(VersionInfo(
              latestVersion: serverVersion, // From API
              currentVersion: currentVersion, // From app's pubspec.yaml (NOT from API)
              message: platformData['message'] ?? 'Versi baharu tersedia',
              downloadLink: platformData['link'] ?? '',
              releaseDate: platformData['release_date'],
              isNews: isNews,
              title: platformData['title'], // Optional custom title from API
            ));
          }
        }
        
        return notifications;
      }
      
      return [];
    } catch (e) {
      print('Error checking version: $e');
      return [];
    }
  }
  
  /// Compare two version strings (e.g., "1.0.3" vs "1.0.2")
  static bool _isNewerVersion(String serverVersion, String currentVersion) {
    try {
      final serverParts = serverVersion.split('.').map(int.parse).toList();
      final currentParts = currentVersion.split('.').map(int.parse).toList();
      
      // Pad with zeros if lengths differ
      while (serverParts.length < currentParts.length) {
        serverParts.add(0);
      }
      while (currentParts.length < serverParts.length) {
        currentParts.add(0);
      }
      
      for (int i = 0; i < serverParts.length; i++) {
        if (serverParts[i] > currentParts[i]) {
          return true;
        } else if (serverParts[i] < currentParts[i]) {
          return false;
        }
      }
      
      return false; // Versions are equal
    } catch (e) {
      print('Error comparing versions: $e');
      return false;
    }
  }
  
  /// Mark that user has dismissed the update notification
  static Future<void> dismissUpdate(String version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('dismissed_version', version);
  }
  
  /// Check if user has dismissed this version update
  static Future<bool> hasUserDismissedUpdate(String version) async {
    final prefs = await SharedPreferences.getInstance();
    final dismissedVersion = prefs.getString('dismissed_version');
    return dismissedVersion == version;
  }
}

class VersionInfo {
  final String latestVersion; // Version from API (server)
  final String currentVersion; // Version from app's pubspec.yaml (NOT from API)
  final String message;
  final String downloadLink;
  final String? releaseDate;
  final bool isNews; // True if this is a news/announcement, not a version update
  final String? title; // Optional custom title from API
  
  VersionInfo({
    required this.latestVersion,
    required this.currentVersion,
    required this.message,
    required this.downloadLink,
    this.releaseDate,
    this.isNews = false,
    this.title,
  });
  
  bool get isUpdateAvailable => latestVersion != currentVersion || isNews;
}

