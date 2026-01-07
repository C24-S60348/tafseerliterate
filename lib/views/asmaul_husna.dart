import 'package:flutter/material.dart';
import '../services/getasmaulhusna.dart' as getasmaulhusna;
import 'package:http/http.dart' as http;
import '../utils/theme_helper.dart';

class AsmaulHusnaPage extends StatefulWidget {
  const AsmaulHusnaPage({super.key});

  @override
  _AsmaulHusnaPageState createState() => _AsmaulHusnaPageState();
}

class _AsmaulHusnaPageState extends State<AsmaulHusnaPage> {
  List<Map<String, dynamic>> pages = [];
  bool isLoading = true;
  bool hasNoInternet = false;

  @override
  void initState() {
    super.initState();
    _loadPages();
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
    
    try {
      // Get Asmaul Husna posts using the dedicated service
      final urlTitles = await getasmaulhusna.GetAsmaulHusna.getAsmaulHusnaPosts();
      
      final List<Map<String, dynamic>> pageList = [];
      for (int i = 0; i < urlTitles.length; i++) {
        final urlTitle = urlTitles[i];
        pageList.add({
          'index': i,
          'title': urlTitle['title'] ?? _extractTitleFromUrl(urlTitle['url'] ?? ''),
          'url': urlTitle['url'] ?? '',
        });
      }

      setState(() {
        pages = pageList;
        isLoading = false;
        // If no pages and no internet, show message
        hasNoInternet = (!hasInternet && urlTitles.isEmpty);
      });
    } catch (e) {
      print('Error loading Asmaul Husna pages: $e');
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
    return 'Page ${pages.length + 1}';
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
          '99 Names of Allah',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 52, 21, 104),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
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
                            'Select Page',
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
                                  Color.fromARGB(255, 52, 21, 104),
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
                                    return Card(
                                      margin: EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                        vertical: 4.0,
                                      ),
                                      elevation: 2,
                                      color: backgroundColor,
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: Color.fromARGB(255, 52, 21, 104),
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
                                          Navigator.of(context).pushNamed('/baca-asmaul-husna', arguments: {
                                            'url': page['url'],
                                            'title': page['title'],
                                            'pageIndex': page['index'],
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
