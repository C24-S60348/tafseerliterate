import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_html/flutter_html.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/getlistsurah.dart' as getlist;
import '../services/baca.dart' as service;
import '../services/download_service.dart';

/// Remove numbering from unordered list items and clean up nested list structures
String _removeNumbersFromUnorderedLists(String html) {
  String result = html;

  // Remove wrapper <ol><li style="list-style-type: none"><ol>...</ol></li></ol> structures
  result = result.replaceAllMapped(
    RegExp(
      r'<ol[^>]*>\s*<li[^>]*style="list-style-type:\s*none"[^>]*>\s*(<ol[^>]*>.*?</ol>)\s*</li>\s*</ol>',
      dotAll: true,
      caseSensitive: false,
    ),
    (match) => match.group(1)!, // Keep only the inner <ol>
  );

  // Remove wrapper <ul><li style="list-style-type: none"><ul>...</ul></li></ul> structures
  result = result.replaceAllMapped(
    RegExp(
      r'<ul[^>]*>\s*<li[^>]*style="list-style-type:\s*none"[^>]*>\s*(<ul[^>]*>.*?</ul>)\s*</li>\s*</ul>',
      dotAll: true,
      caseSensitive: false,
    ),
    (match) => match.group(1)!, // Keep only the inner <ul>
  );

  // Process <ul> tags to remove numbers
  int maxIterations = 20;
  int iteration = 0;

  while (iteration < maxIterations) {
    // Find the innermost <ul>...</ul> block
    final match = RegExp(
      r'<ul[^>]*>((?:(?!<ul[^>]*>).)*?)</ul>',
      dotAll: true,
      caseSensitive: false,
    ).firstMatch(result);

    if (match == null) break;

    String fullMatch = match.group(0)!;
    String ulOpenTag = fullMatch.substring(0, fullMatch.indexOf('>') + 1);
    String ulContent = match.group(1)!;

    // Remove number patterns from <li> tags within this <ul>
    String cleanedContent = ulContent.replaceAllMapped(
      RegExp(r'(<li[^>]*>)\s*(\d+\.\s+)', caseSensitive: false),
      (m) => m.group(1)!,
    );

    result = result.replaceFirst(fullMatch, '$ulOpenTag$cleanedContent</ul>');
    iteration++;
  }

  return result;
}

/// Get proxied image URL for web to bypass CORS
String _getProxiedImageUrl(String imageUrl) {
  // Handle relative URLs by converting to absolute URLs
  String absoluteUrl = imageUrl;
  if (!imageUrl.startsWith('http://') && !imageUrl.startsWith('https://')) {
    // If it's a relative URL, prepend the base URL
    const baseUrl = 'https://tafseerliterate.wordpress.com';
    if (imageUrl.startsWith('/')) {
      absoluteUrl = '$baseUrl$imageUrl';
    } else {
      absoluteUrl = '$baseUrl/$imageUrl';
    }
  }

  if (kIsWeb) {
    // For web, use CORS proxy for images
    const corsProxy = 'https://afwanhaziq.vps.webdock.cloud/proxy?url=';
    return '$corsProxy$absoluteUrl';
  }
  // For mobile, use direct URL
  return absoluteUrl;
}

/// Process HTML content to proxy all image URLs for web
String _processHtmlForWeb(String htmlContent) {
  if (!kIsWeb) {
    // For mobile, return content as-is
    return htmlContent;
  }

  // For web, proxy all image URLs in the HTML
  // Replace src="..." in img tags
  final imgPattern = RegExp(
    r'<img([^>]*)\s+src="([^"]*)"([^>]*)>',
    caseSensitive: false,
  );

  return htmlContent.replaceAllMapped(imgPattern, (match) {
    final beforeSrc = match.group(1) ?? '';
    final originalSrc = match.group(2) ?? '';
    final afterSrc = match.group(3) ?? '';

    // Get proxied URL
    final proxiedSrc = _getProxiedImageUrl(originalSrc);

    return '<img$beforeSrc src="$proxiedSrc"$afterSrc>';
  });
}

/// Extension builder for network images with theme support and zoom capability
Widget Function(ExtensionContext) networkImageExtensionBuilderWithTheme(
  bool isDark,
) {
  return (ExtensionContext extensionContext) {
    final src = extensionContext.attributes['src'];
    if (src != null && src.isNotEmpty) {
      // Proxy the image URL for web to bypass CORS
      final proxiedUrl = _getProxiedImageUrl(src);

      return GestureDetector(
        onTap: () {
          // Get the BuildContext from the extension context
          final buildContext = extensionContext.buildContext;
          if (buildContext != null) {
            _showImageZoomDialog(buildContext, proxiedUrl, isDark);
          }
        },
        child: Image.network(
          proxiedUrl,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDark
                      ? Colors.deepPurple[300]!
                      : Color.fromARGB(255, 52, 21, 104),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            print('Error loading image from: $proxiedUrl');
            print('Error: $error');
            return Container(
              width: double.infinity,
              height: 200,
              color: Colors.grey[300],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, size: 48, color: Colors.grey[600]),
                  SizedBox(height: 8),
                    Text(
                      'Failed to load image',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                ],
              ),
            );
          },
        ),
      );
    }
    return SizedBox.shrink();
  };
}

/// Show image in a zoomable full-screen dialog
void _showImageZoomDialog(BuildContext context, String imageUrl, bool isDark) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.all(0),
        child: Stack(
          children: [
            // Zoomable image
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Center(
                child: Container(
                  color: Colors.white,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color.fromARGB(255, 52, 21, 104),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image,
                              size: 64,
                              color: Colors.grey[600],
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Failed to load image',
                              style: TextStyle(color: Colors.grey[800]),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            // Close button
            Positioned(
              top: 40,
              right: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Future<double> getFontSize() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getDouble('font_size') ?? 16.0;
}

Widget buildPageIndicator(
  int currentPage,
  int totalPages,
  Function() onPrevious,
  Function() onNext,
) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 16.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
          ElevatedButton.icon(
          onPressed: currentPage > 0 ? onPrevious : null,
          icon: Icon(Icons.arrow_back),
          label: Text('Previous'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
        ElevatedButton.icon(
          onPressed: currentPage < totalPages - 1 ? onNext : null,
          icon: Icon(Icons.arrow_forward),
          label: Text('Next'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    ),
  );
}

Widget buildSurahBody(
  BuildContext context,
  Map<String, String> surahData,
  Widget bodyContent, {
  bool isDark = false,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Surah header
      Center(
        child: Column(
          children: [
            Text(
              surahData['pageTitle'] ?? surahData['name'] ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Image.asset(
              isDark
                  ? 'assets/images/bismillah_darkmode.png'
                  : 'assets/images/bismillah.png',
              fit: BoxFit.contain,
              width: MediaQuery.of(context).size.width * 0.6,
            ),
          ],
        ),
      ),
      SizedBox(height: 30),

      // Content placeholder
      bodyContent,
    ],
  );
}

Widget bodyContent(
  surahIndex,
  currentPage, [
  bool isDark = false,
  Color? textColor,
  String? categoryUrl,
]) {
  return FutureBuilder<double>(
    future: getFontSize(),
    builder: (context, fontSizeSnapshot) {
      return FutureBuilder<String?>(
        future: _getPageContent(surahIndex, currentPage, categoryUrl: categoryUrl),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark
                          ? Colors.deepPurple[300]!
                          : Color.fromARGB(255, 52, 21, 104),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Text("Loading content..."),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 48, color: Colors.red),
                  SizedBox(height: 16),
                  Text("Failed to load content."),
                ],
              ),
            );
          } else if (snapshot.hasData) {
            final fontSize = fontSizeSnapshot.data ?? 16.0;
            // Remove numbers from unordered list items
            final cleanedHtml = _removeNumbersFromUnorderedLists(
              snapshot.data!,
            );

            return Html(
              data: cleanedHtml,
              style: {
                "body": Style(
                  fontSize: FontSize(fontSize),
                  textAlign: TextAlign.justify,
                  color: isDark ? Colors.white : null,
                ),
                "p": Style(
                  fontSize: FontSize(fontSize),
                  textAlign: TextAlign.justify,
                  color: isDark ? Colors.white : null,
                  // margin: Margins.only(top: 4, bottom: 4), // Reduce top and bottom spacing
                  // padding: HtmlPaddings.zero, // Remove padding
                ),
                "hr": Style(
                  margin: Margins.only(top: 12, bottom: 4), // Reduce spacing around hr
                ),
                "div": Style(color: isDark ? Colors.white : null),
                "span": Style(color: isDark ? Colors.white : null),
                "strong": Style(
                  color: isDark ? Colors.white : null,
                  fontWeight: FontWeight.bold,
                ),
                "b": Style(color: isDark ? Colors.white : null, fontWeight: FontWeight.bold),
                "em": Style(color: isDark ? Colors.white : null, fontStyle: FontStyle.italic),
                "i": Style(color: isDark ? Colors.white : null, fontStyle: FontStyle.italic),
                "u": Style(
                  color: isDark ? Colors.white : null,
                  textDecoration: TextDecoration.underline,
                ),
                "a": Style(
                  color: isDark ? Colors.white : null,
                  textDecoration: TextDecoration.underline,
                ),
                "ul": Style(
                  fontSize: FontSize(fontSize),
                  textAlign: TextAlign.justify,
                  listStyleType: ListStyleType.disc,
                  padding: HtmlPaddings.only(left: 20),
                  color: isDark ? Colors.white : null,
                ),
                "ol": Style(
                  fontSize: FontSize(fontSize),
                  textAlign: TextAlign.justify,
                  listStyleType: ListStyleType.none,
                  padding: HtmlPaddings.only(left: 20),
                  margin: Margins.zero,
                  display: Display.block,
                  color: isDark ? Colors.white : null,
                ),
                "li": Style(
                  fontSize: FontSize(fontSize),
                  textAlign: TextAlign.justify,
                  padding: HtmlPaddings.only(bottom: 8),
                  color: isDark ? Colors.white : null,
                ),
                "h1": Style(color: isDark ? Colors.white : null, fontWeight: FontWeight.bold),
                "h2": Style(color: isDark ? Colors.white : null, fontWeight: FontWeight.bold),
                "h3": Style(color: isDark ? Colors.white : null, fontWeight: FontWeight.bold),
                "h4": Style(color: isDark ? Colors.white : null, fontWeight: FontWeight.bold),
                "h5": Style(color: isDark ? Colors.white : null, fontWeight: FontWeight.bold),
                "h6": Style(color: isDark ? Colors.white : null, fontWeight: FontWeight.bold),
                "img": Style(
                  width: Width(double.infinity),
                  height: Height(200),
                ),
              },
              extensions: [
                TagExtension(
                  tagsToExtend: {"img"},
                  builder: networkImageExtensionBuilderWithTheme(isDark),
                ),
              ],
            );
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info, size: 48, color: Colors.red),
                  SizedBox(height: 16),
                  Text("Please connect to internet to load content"),
                ],
              ),
            );
          }
        },
      );
    },
  );
}

/// Get content for a specific page (cached or fetch)
Future<String?> _getPageContent(int surahIndex, int pageIndex, {String? categoryUrl}) async {
  // Cache disabled for now - always fetch from URL
  // TODO: Re-enable cache after webapp is perfected
  
  // Fetch from URL
  final url = await getlist.GetListSurah.getSurahUrl(surahIndex, pageIndex, categoryUrl: categoryUrl);
  if (url != null) {
    final content = await service.BacaService.fetchContentFromUrl(
      url,
      'entry-content',
    );
    if (content != null) {
      // Process HTML content to proxy images for web
      return _processHtmlForWeb(content);
    }
  }

  return null;
}

// Database functions for bookmarks
Future<List<Map<String, dynamic>>> getBookmarks() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final bookmarksJson = prefs.getString('bookmarks');
    if (bookmarksJson != null) {
      final List<dynamic> bookmarksList = json.decode(bookmarksJson);
      return bookmarksList.cast<Map<String, dynamic>>();
    }
    return [];
  } catch (e) {
    print('Error getting bookmarks: $e');
    return [];
  }
}

Future<void> saveBookmarks(List<Map<String, dynamic>> bookmarks) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final bookmarksJson = json.encode(bookmarks);
    await prefs.setString('bookmarks', bookmarksJson);
  } catch (e) {
    print('Error saving bookmarks: $e');
  }
}

Future<void> addBookmark(
  int surahIndex,
  int currentPage, {
  String? categoryUrl,
  String? pageTitle,
}) async {
  try {
    final bookmark = {
      'surahIndex': surahIndex,
      'currentPage': currentPage,
      'categoryUrl': categoryUrl,
      'pageTitle': pageTitle,
      'dateAdded': DateTime.now().toIso8601String(),
    };
    final bookmarks = await getBookmarks();

    // Check if bookmark already exists
    final existingIndex = bookmarks.indexWhere(
      (b) => b['surahIndex'] == surahIndex && b['currentPage'] == currentPage,
    );

    if (existingIndex == -1) {
      bookmarks.add(bookmark);
      await saveBookmarks(bookmarks);
    }
  } catch (e) {
    print('Error adding bookmark: $e');
  }
}

Future<void> removeBookmark(int surahIndex, int currentPage) async {
  try {
    final bookmarks = await getBookmarks();
    bookmarks.removeWhere(
      (b) => b['surahIndex'] == surahIndex && b['currentPage'] == currentPage,
    );
    await saveBookmarks(bookmarks);
  } catch (e) {
    print('Error removing bookmark: $e');
  }
}

Future<bool> isBookmarked(int surahIndex, int currentPage) async {
  try {
    final bookmarks = await getBookmarks();
    return bookmarks.any(
      (b) => b['surahIndex'] == surahIndex && b['currentPage'] == currentPage,
    );
  } catch (e) {
    print('Error checking bookmark: $e');
    return false;
  }
}

// Database functions for last read
Future<Map<String, dynamic>?> getLastRead() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final lastReadJson = prefs.getString('lastRead');
    if (lastReadJson != null) {
      final Map<String, dynamic> lastRead = json.decode(lastReadJson);
      return lastRead;
    }
    return null;
  } catch (e) {
    print('Error getting last read: $e');
    return null;
  }
}

Future<void> saveLastRead(
  int surahIndex,
  int pageIndex,
  String surahName,
  String? pageTitle, {
  String? categoryUrl,
}) async {
  try {
    final lastRead = {
      'surahIndex': surahIndex,
      'pageIndex': pageIndex,
      'surahName': surahName,
      'pageTitle': pageTitle ?? '',
      'categoryUrl': categoryUrl,
      'lastReadDate': DateTime.now().toIso8601String(),
    };
    final prefs = await SharedPreferences.getInstance();
    final lastReadJson = json.encode(lastRead);
    await prefs.setString('lastRead', lastReadJson);
  } catch (e) {
    print('Error saving last read: $e');
  }
}
