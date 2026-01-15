import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:flutter/foundation.dart' show kIsWeb;

class BacaService {
  static const String baseUrl = 'https://tafseerliterate.wordpress.com';
  
  // CORS Proxy for Web - using custom proxy server
  static const String _corsProxy = 'https://afwanhaziq.vps.webdock.cloud/proxy?url=';
  
  /// Get the URL with CORS proxy if running on web
  static String _getProxiedUrl(String url) {
    if (kIsWeb) {
      // For web, use custom CORS proxy
      return '$_corsProxy$url';
    }
    // For mobile, use direct URL (no CORS restrictions)
    return url;
  }

  /// Fetches HTML content from a URL and extracts data from element with specified class
  static Future<String?> fetchContentFromUrl(
    String url,
    String className,
  ) async {
    try {
      final response = await http.get(Uri.parse(_getProxiedUrl(url)));

      if (response.statusCode == 200) {
        final document = html_parser.parse(response.body);
        final element = document.querySelector('.$className');

        if (element != null) {
          // Remove unwanted elements (sharing buttons, like widgets, etc.)
          // Remove jp-post-flair div which contains sharing buttons
          final shareElements = element.querySelectorAll('#jp-post-flair, .sharedaddy, .sd-sharing-enabled, .jetpack-likes-widget-wrapper');
          for (var shareElement in shareElements) {
            shareElement.remove();
          }
          
          // Return the cleaned HTML content
          return element.innerHtml;
        }
      }
    } catch (e) {
      print('Error fetching content: $e');
    }
    return null;
  }

  /// Parses HTML content and extracts text
  static String parseHtmlToText(String htmlContent) {
    final document = html_parser.parse(htmlContent);
    return document.body?.text ?? '';
  }

}
