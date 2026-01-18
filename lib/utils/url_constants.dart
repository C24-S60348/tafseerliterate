/// Centralized URL constants for the application
class UrlConstants {
  // Base URLs
  static const String wordpressUrl = 'https://tafseerliterate.wordpress.com';
  static const String proxyUrl = 'https://tafseerliterate.wordpress.com'; // Using same as wordpress for now
  
  // Category URLs
  static String get usulTafseerUrl => '$wordpressUrl/usul-tafseer/';
  static String get namesOfAllahUrl => '$wordpressUrl/99-names-of-allah/';
  static String get hujjahUrl => '$wordpressUrl/hujjah/';
  static String get glossaryUrl => '$wordpressUrl/glossary/';
  
  // Dynamic URLs
  static String getSurahCategoryUrl(String surahNumber) {
    return '$wordpressUrl/surah-${surahNumber.padLeft(3, '0')}-';
  }
  
  /// Check if a URL is from the tafseerliterate domain
  static bool isTafseerLiterateUrl(String url) {
    return url.contains('tafseerliterate.wordpress.com');
  }
}

