import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:flutter/foundation.dart' show kIsWeb;

class GetHujjah {
  static const String _baseUrl = 'https://tafseerliterate.wordpress.com';
  static const String _categoryUrl = 'https://tafseerliterate.wordpress.com/hujjah/';
  
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

  /// Check internet connection
  static Future<bool> _hasInternetConnection() async {
    try {
      final response = await http.get(Uri.parse(_getProxiedUrl(_baseUrl))).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw Exception('Connection timeout');
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Extract title from URL
  static String _extractTitleFromUrl(String url) {
    try {
      // Extract the last part of the URL (after the last /)
      final parts = url.split('/');
      // Filter out empty strings and get the last non-empty part
      final nonEmptyParts = parts.where((p) => p.isNotEmpty).toList();
      if (nonEmptyParts.isNotEmpty) {
        String title = nonEmptyParts.last;
        
        // Split by hyphens
        List<String> segments = title.split('-');
        
        // Process segments and join with spaces
        List<String> processedSegments = [];
        for (int i = 0; i < segments.length; i++) {
          String segment = segments[i].trim();
          if (segment.isEmpty) continue;
          
          // Capitalize first letter, rest lowercase
          if (segment.isNotEmpty) {
            segment = segment[0].toUpperCase() + segment.substring(1).toLowerCase();
          }
          
          processedSegments.add(segment);
          
          // Add space between segments (except for the last one)
          if (i < segments.length - 1) {
            processedSegments.add(' ');
          }
        }
        
        title = processedSegments.join('');
        
        // Clean up multiple spaces
        title = title.replaceAll(RegExp(r'\s+'), ' ');
        
        return title.trim();
      }
    } catch (e) {
      print('Error extracting title: $e');
    }
    
    return 'Untitled';
  }

  /// Scrape all post URLs and titles from the hujjah category page
  static Future<List<Map<String, String>>> scrapeHujjahPosts() async {
    final List<Map<String, String>> urlTitles = [];
    int page = 1;
    bool hasMorePages = true;
    
    while (hasMorePages) {
      try {
        // WordPress category pages typically use ?paged=X for pagination
        final url = page == 1 ? _categoryUrl : '$_categoryUrl?paged=$page';
        final response = await http.get(Uri.parse(_getProxiedUrl(url)));
        
        if (response.statusCode != 200) {
          break;
        }
        
        final document = html_parser.parse(response.body);
        
        // Find all post links - look for links that match post URL pattern
        // Post URLs typically match pattern: /YYYY/MM/DD/post-slug/
        final postUrlPattern = RegExp(r'/(\d{4})/(\d{2})/(\d{2})/[^/]+/$');
        final allLinks = document.querySelectorAll('a');
        
        bool foundNewLinks = false;
        for (var link in allLinks) {
          final href = link.attributes['href'];
          if (href != null) {
            // Convert relative URL to absolute
            final absoluteUrl = href.startsWith('http') ? href : '$_baseUrl$href';
            
            // Check if it's a post URL (matches date pattern) and is from tafseerliterate.wordpress.com
            final dateMatch = postUrlPattern.firstMatch(absoluteUrl);
            if (absoluteUrl.contains('tafseerliterate.wordpress.com') && 
                dateMatch != null &&
                !urlTitles.any((item) => item['url'] == absoluteUrl) &&
                !absoluteUrl.contains('/category/') &&
                !absoluteUrl.contains('/tag/') &&
                !absoluteUrl.contains('/author/') &&
                !absoluteUrl.contains('/page/')) {
              // Extract date from URL for sorting
              final year = dateMatch.group(1)!;
              final month = dateMatch.group(2)!;
              final day = dateMatch.group(3)!;
              final dateString = '$year$month$day';
              
              // Try to get title from link text, otherwise extract from URL
              String title = link.text.trim();
              if (title.isEmpty) {
                title = _extractTitleFromUrl(absoluteUrl);
              }
              
              urlTitles.add({
                'url': absoluteUrl,
                'title': title,
                'date': dateString, // Store date for sorting
              });
              foundNewLinks = true;
            }
          }
        }
        
        // Check if there's a next page link
        final nextPageLink = document.querySelector('a.next.page-numbers, .nav-next a, .pagination .next a, .pagination-next a');
        hasMorePages = foundNewLinks && nextPageLink != null;
        page++;
        
        // Safety limit to prevent infinite loops
        if (page > 100) {
          print('Warning: Reached page limit for hujjah category');
          break;
        }
        
        // If no new links found, stop
        if (!foundNewLinks) {
          hasMorePages = false;
        }
      } catch (e) {
        print('Error scraping page $page of hujjah category: $e');
        break;
      }
    }
    
    // Sort by date (chronologically) to maintain the website's intended order
    urlTitles.sort((a, b) {
      final dateA = a['date'] ?? '';
      final dateB = b['date'] ?? '';
      return dateA.compareTo(dateB);
    });
    
    return urlTitles;
  }

  /// Get all hujjah posts (with internet check)
  static Future<List<Map<String, String>>> getHujjahPosts() async {
    // Check if we have internet connection
    final hasInternet = await _hasInternetConnection();
    
    if (hasInternet) {
      try {
        print('Scraping hujjah posts from $_categoryUrl...');
        final posts = await scrapeHujjahPosts();
        print('Successfully scraped ${posts.length} hujjah posts');
        return posts;
      } catch (e) {
        print('Error scraping hujjah posts: $e');
        return [];
      }
    } else {
      print('No internet connection, cannot fetch hujjah posts');
      return [];
    }
  }
}

