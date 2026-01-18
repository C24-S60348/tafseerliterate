import 'package:flutter/material.dart';
import '../services/getlistsurah.dart' as getlist;
import 'package:http/http.dart' as http;
import '../utils/theme_helper.dart';

class SurahPagesPage extends StatefulWidget {
  const SurahPagesPage({super.key});

  @override
  _SurahPagesPageState createState() => _SurahPagesPageState();
}

class _SurahPagesPageState extends State<SurahPagesPage> {
  late Map<String, String> surahData;
  int surahIndex = 0;
  List<Map<String, dynamic>> pages = [];
  bool isLoading = true;
  bool hasNoInternet = false;

  String? categoryUrl;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (isLoading) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is Map<String, dynamic>) {
        surahData = {
          'name': args['name']?.toString() ?? '',
          'name_arab': args['name_arab']?.toString() ?? '',
          'number': args['number']?.toString() ?? '',
        };
        surahIndex = args['surahIndex'] ?? 0;
        categoryUrl = args['category_url']?.toString();
        _loadPages();
      }
    }
  }

  Future<bool> _checkInternetConnection() async {
    try {
      final response = await http.get(Uri.parse('https://tafseerliterate.wordpress.com')).timeout(
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

  void _loadPages() async {
    // Check internet connection first
    final hasInternet = await _checkInternetConnection();
    
    // Pass categoryUrl to getSurahByIndex so each variant uses its specific URL
    final surah = await getlist.GetListSurah.getSurahByIndex(surahIndex, categoryUrl: categoryUrl);
    if (surah != null) {
      final urls = List<String>.from(surah['urls'] as List);
      final titles = surah['titles'] as List<String>?;
      final List<Map<String, dynamic>> pageList = [];

      for (int i = 0; i < urls.length; i++) {
        final url = urls[i];
        // Use cached title if available, otherwise extract from URL
        final title = (titles != null && i < titles.length) 
            ? titles[i] 
            : _extractTitleFromUrl(url);
        pageList.add({
          'index': i,
          'title': title,
          'url': url,
        });
      }

      setState(() {
        pages = pageList;
        isLoading = false;
        // If no pages and no internet, show message
        hasNoInternet = (!hasInternet && urls.isEmpty);
      });
    } else {
      // No surah data - check if it's because of no internet
      setState(() {
        pages = [];
        isLoading = false;
        hasNoInternet = !hasInternet;
      });
    }
  }

  String _extractTitleFromUrl(String url) {
    try {
      // Extract the last part of the URL (after the last /)
      final parts = url.split('/');
      // Filter out empty strings and get the last non-empty part
      final nonEmptyParts = parts.where((p) => p.isNotEmpty).toList();
      if (nonEmptyParts.isNotEmpty) {
        String title = nonEmptyParts.last;
        
        // Split by hyphens
        List<String> segments = title.split('-');
        
        // Process segments and join with spaces, but preserve hyphens between numbers
        List<String> processedSegments = [];
        for (int i = 0; i < segments.length; i++) {
          String segment = segments[i].trim();
          if (segment.isEmpty) continue;
          
          // Expand abbreviations
          if (segment.toLowerCase() == 'bah') {
            segment = 'bahagian';
          }
          
          // Capitalize first letter, rest lowercase
          if (segment.isNotEmpty) {
            segment = segment[0].toUpperCase() + segment.substring(1).toLowerCase();
          }
          
          processedSegments.add(segment);
          
          // If current and next segments are both numbers, add hyphen instead of space
          if (i < segments.length - 1) {
            String nextSegment = segments[i + 1].trim();
            if (_isNumeric(segment) && _isNumeric(nextSegment)) {
              processedSegments.add('-');
            } else {
              processedSegments.add(' ');
            }
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
    
    // Fallback: return page number
    return 'Halaman ${pages.length + 1}';
  }
  
  bool _isNumeric(String str) {
    if (str.isEmpty) return false;
    return RegExp(r'^\d+$').hasMatch(str);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${surahData['name']}',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/info');
            },
            icon: Icon(Icons.info_outline, color: Colors.white),
          ),
        ],
      ),
      body: FutureBuilder<String>(
        future: ThemeHelper.getThemeName(),
        builder: (context, snapshot) {
          final themeName = snapshot.data ?? 'Light';
          final textColor = ThemeHelper.getTextColor(themeName);
          final backgroundColor = ThemeHelper.getContentBackgroundColor(themeName);
          final isDark = themeName == 'Dark';
          
          return Stack(
            children: [
              // Background image with dark overlay in dark mode
              Image.asset(
                'assets/images/bg.jpg',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                color: isDark ? Colors.black54 : null,
                colorBlendMode: isDark ? BlendMode.darken : null,
              ),
              Container(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Column(
                        children: [
                          Text(
                            'Choose Page',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          SizedBox(height: 8),
                          isLoading 
                            ? SizedBox(height: 15,)
                            : hasNoInternet && pages.isEmpty
                              ? Text(
                                  'No internet connection',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.red[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : Text(
                                  'Total: ${pages.length} pages',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark ? Colors.grey[300] : Colors.black87,
                                  ),
                                ),
                        ],
                      ),
                    ),
                    Divider(color: textColor.withOpacity(0.3)),
                    SizedBox(height: 10),

                    // Pages list
                    Expanded(
                      child: isLoading
                          ? Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  const Color(0xFF7CB342),
                                ),
                              ),
                            )
                          : hasNoInternet && pages.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.wifi_off,
                                      size: 64,
                                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'No internet connection',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 32.0),
                                      child: Text(
                                        'Please check your internet connection and try again.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isDark ? Colors.grey[400] : Colors.black54,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : pages.isEmpty
                              ? Center(
                                  child: Text(
                                    'No pages available',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: isDark ? Colors.grey[400] : Colors.black54,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: pages.length,
                                  itemBuilder: (context, index) {
                                    final page = pages[index];
                                    // debugPrint('Page: ${page['title']}');
                                    return Card(
                                      margin: EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                        vertical: 4.0,
                                      ),
                                      elevation: 2,
                                      color: backgroundColor,
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: const Color(0xFF7CB342),
                                          child: Text(
                                            '${page['index'] + 1}',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          page['title'] as String,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: textColor,
                                          ),
                                        ),
                                        subtitle: Text(
                                          'Page ${page['index'] + 1}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDark ? Colors.grey[400] : Colors.black54,
                                          ),
                                        ),
                                        trailing: Icon(
                                          Icons.arrow_forward_ios,
                                          size: 16,
                                          color: textColor,
                                        ),
                                        onTap: () {
                                          Navigator.of(context).pushNamed('/baca', arguments: {
                                            ...surahData,
                                            'surahIndex': surahIndex,
                                            'pageIndex': page['index'],
                                            'pageTitle': page['title'],
                                            'category_url': categoryUrl,
                                          });
                                        },
                                      ),
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

