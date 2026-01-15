import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/baca.dart' as service;

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

/// Normalize excessive font sizes in inline styles
String _normalizeFontSizes(String htmlContent) {
  // Remove or limit excessive font-size percentages (> 150%)
  // Replace font-size: XXX% where XXX > 150 with font-size: 150%
  htmlContent = htmlContent.replaceAllMapped(
    RegExp(r'font-size:\s*([2-9]\d{2,}|1[6-9]\d|15[1-9])%', caseSensitive: false),
    (match) => 'font-size: 150%', // Cap at 150%
  );
  
  // Also handle font-size with 'xx-large', 'xxx-large', etc.
  htmlContent = htmlContent.replaceAll(RegExp(r'font-size:\s*x{2,}-large', caseSensitive: false), 'font-size: large');
  
  return htmlContent;
}

/// Process HTML content to proxy all image URLs for web
String _processHtmlForWeb(String htmlContent) {
  if (!kIsWeb) {
    // For mobile, return content as-is
    return htmlContent;
  }
  
  // For web, proxy all image URLs in the HTML
  // Replace src="..." in img tags
  final imgPattern = RegExp(r'<img([^>]*)\s+src="([^"]*)"([^>]*)>', caseSensitive: false);
  
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
Widget Function(ExtensionContext) networkImageExtensionBuilderWithTheme(bool isDark) {
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
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDark ? Colors.deepPurple[300]! : Color.fromARGB(255, 52, 21, 104),
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
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDark ? Colors.deepPurple[300]! : Colors.white,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image, size: 64, color: Colors.white),
                          SizedBox(height: 16),
                          Text(
                            'Failed to load image',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            // Close button
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            // Zoom hint text
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
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

/// Get content for the glossary page
Future<String?> _getGlosariContent() async {
  const url = 'https://celiktafsir.net/glosari-blog/';
  final content = await service.BacaService.fetchContentFromUrl(url, 'entry-content');
  if (content != null) {
    // First normalize excessive font sizes
    String processedContent = _normalizeFontSizes(content);
    // Then process HTML content to proxy images for web
    return _processHtmlForWeb(processedContent);
  }
  return null;
}

/// Get content for the glossary page (public access)
Future<String?> getGlosariContent() async {
  return _getGlosariContent();
}

Widget bodyContent([bool isDark = false, Color? textColor]) {
  return FutureBuilder<double>(
    future: getFontSize(),
    builder: (context, fontSizeSnapshot) {
      return FutureBuilder<String?>(
        future: _getGlosariContent(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark ? Colors.deepPurple[300]! : Color.fromARGB(255, 52, 21, 104),
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
            final cleanedHtml = _removeNumbersFromUnorderedLists(snapshot.data!);
            
            // Get text color - only apply in dark mode to preserve original API colors in light theme
            final htmlTextColor = isDark ? Colors.white : null;
            
            // Helper function to create Style with optional color
            Style createStyle({
              FontSize? fontSize,
              TextAlign? textAlign,
              Color? color,
              FontWeight? fontWeight,
              FontStyle? fontStyle,
              TextDecoration? textDecoration,
              ListStyleType? listStyleType,
              HtmlPaddings? padding,
              Margins? margin,
              Display? display,
            }) {
              return Style(
                fontSize: fontSize,
                textAlign: textAlign,
                color: color,
                fontWeight: fontWeight,
                fontStyle: fontStyle,
                textDecoration: textDecoration,
                listStyleType: listStyleType,
                padding: padding,
                margin: margin,
                display: display,
              );
            }
            
            return Html(
              data: cleanedHtml,
              style: {
                "body": createStyle(
                  fontSize: FontSize(fontSize),
                  textAlign: TextAlign.justify,
                  color: htmlTextColor,
                ),
                "p": createStyle(
                  fontSize: FontSize(fontSize),
                  textAlign: TextAlign.justify,
                  color: htmlTextColor,
                ),
                "div": createStyle(
                  color: htmlTextColor,
                ),
                "span": createStyle(
                  color: htmlTextColor,
                ),
                "strong": createStyle(
                  color: htmlTextColor,
                  fontWeight: FontWeight.bold,
                ),
                "b": createStyle(
                  color: htmlTextColor,
                  fontWeight: FontWeight.bold,
                ),
                "em": createStyle(
                  color: htmlTextColor,
                  fontStyle: FontStyle.italic,
                ),
                "i": createStyle(
                  color: htmlTextColor,
                  fontStyle: FontStyle.italic,
                ),
                "u": createStyle(
                  color: htmlTextColor,
                  textDecoration: TextDecoration.underline,
                ),
                "a": createStyle(
                  color: htmlTextColor,
                  textDecoration: TextDecoration.underline,
                ),
                "ul": createStyle(
                  fontSize: FontSize(fontSize),
                  textAlign: TextAlign.justify,
                  listStyleType: ListStyleType.disc,
                  padding: HtmlPaddings.only(left: 20),
                  color: htmlTextColor,
                ),
                "ol": createStyle(
                  fontSize: FontSize(fontSize),
                  textAlign: TextAlign.justify,
                  listStyleType: ListStyleType.none,
                  padding: HtmlPaddings.only(left: 20),
                  margin: Margins.zero,
                  display: Display.block,
                  color: htmlTextColor,
                ),
                "li": createStyle(
                  fontSize: FontSize(fontSize),
                  textAlign: TextAlign.justify,
                  padding: HtmlPaddings.only(bottom: 8),
                  color: htmlTextColor,
                ),
                "h1": createStyle(
                  color: htmlTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: FontSize(fontSize * 1.5),
                ),
                "h2": createStyle(
                  color: htmlTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: FontSize(fontSize * 1.3),
                ),
                "h3": createStyle(
                  color: htmlTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: FontSize(fontSize * 1.2),
                ),
                "h4": createStyle(
                  color: htmlTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: FontSize(fontSize * 1.1),
                ),
                "h5": createStyle(
                  color: htmlTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: FontSize(fontSize),
                ),
                "h6": createStyle(
                  color: htmlTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: FontSize(fontSize * 0.9),
                ),
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

