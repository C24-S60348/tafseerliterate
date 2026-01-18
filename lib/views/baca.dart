import 'package:flutter/material.dart';
import '../models/baca.dart' as model;
import '../services/getlistsurah.dart' as getlist;
import '../services/download_service.dart';
import '../utils/theme_helper.dart';

class BacaPage extends StatefulWidget {
  const BacaPage({super.key});

  @override
  _BacaPageState createState() => _BacaPageState();
}

class _BacaPageState extends State<BacaPage> {
  late Map<String, String> surahData;
  int currentPage = 0; // Changed to 0-based indexing
  int totalPages = 0;
  // bool isLoading = true;
  int surahIndex = 0; // Add surah index
  bool isBookmarked = false; // Add bookmark state
  bool _isInitialized = false; // Add initialization flag
  final ScrollController _scrollController = ScrollController();
  List<String>? _cachedTitles; // Cache titles to avoid calling service on navigation

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String? categoryUrl;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is Map<String, dynamic>) {
        surahData = args.cast<String, String>();
        surahIndex = args['surahIndex'] ?? 0;
        currentPage = args['pageIndex'] ?? 0;
        categoryUrl = args['category_url']?.toString();
        _isInitialized = true;
        _loadSurahContent();
        _checkBookmark(); // Check bookmark status when page loads
      }
    }
  }

  void _loadSurahContent() async {
    print('Loading surah content for index: $surahIndex');
    // Pass categoryUrl to ensure we get the correct variant (e.g., Baqarah Juzuk 2)
    final surah = await getlist.GetListSurah.getSurahByIndex(surahIndex, categoryUrl: categoryUrl);
    print('Surah data: $surah');
    
    if (surah != null) {
      final pages = surah['totalPages'];
      final titles = surah['titles'] as List<String>?;
      print('Total pages from surah: $pages');
      
      setState(() {
        totalPages = pages;
        _cachedTitles = titles; // Cache titles for navigation
        // isLoading = false;
      });
      
      print('Updated totalPages to: $totalPages');
      
      // Update page title if not already set from navigation
      if (surahData['pageTitle'] == null && _cachedTitles != null && currentPage < _cachedTitles!.length) {
        setState(() {
          surahData['pageTitle'] = _cachedTitles![currentPage];
        });
      }
      
      // Save last read
      _saveLastRead();
      
      // Start downloading this surah in background
      _downloadSurahInBackground();
    } else {
      print('Surah data is null for index: $surahIndex');
    }
  }

  void _downloadSurahInBackground() async {
    // try {
    //   // Check if surah is already downloaded
    //   final isDownloaded = await DownloadService.isSurahDownloaded(surahIndex, categoryUrl: categoryUrl);
      
    //   if (!isDownloaded) {
    //     // Get theme to determine snackbar color
    //     final themeName = await ThemeHelper.getThemeName();
    //     final isDark = themeName == 'Gelap';
        
    //     // Show a subtle notification that download is starting
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(
    //         content: Text(
    //           'Memuat kandungan...',
    //           style: TextStyle(color: Colors.white),
    //         ),
    //         duration: Duration(seconds: 2),
    //         backgroundColor: isDark ? Colors.grey[850] : Color.fromARGB(255, 52, 21, 104),
    //       ),
    //     );
        
    //     // Download in background with correct categoryUrl
    //     await DownloadService.downloadSurahPages(surahIndex, categoryUrl: categoryUrl);
        
    //     // Show completion notification
    //     if (mounted) {
    //       ScaffoldMessenger.of(context).showSnackBar(
    //         SnackBar(
    //           content: Text('Kandungan berjaya dimuatkan!'),
    //           duration: Duration(seconds: 2),
    //           backgroundColor: Colors.green,
    //         ),
    //       );
    //     }
        
    //     // Debug: Check cached pages
    //     await DownloadService.debugCachedPages(surahIndex, categoryUrl: categoryUrl);
    //   }
    // } catch (e) {
    //   print('Error memuat kandungan: $e');
    // }
    // Cache/download disabled for now
    // TODO: Re-enable after webapp is perfected
    print('Cache/download disabled - using direct fetch only');
  }

  void _updatePageTitle() {
    // Use cached titles directly without calling service
    if (_cachedTitles != null && currentPage >= 0 && currentPage < _cachedTitles!.length) {
      setState(() {
        surahData['pageTitle'] = _cachedTitles![currentPage];
      });
    }
  }

  void _nextPage() {
    if (currentPage < totalPages - 1) {
      setState(() {
        currentPage++;
      });
      _updatePageTitle(); // Update page title when navigating
      _checkBookmark(); // Check bookmark after page change
      _saveLastRead(); // Save last read when navigating
    }
  }

  void _previousPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
      });
      _updatePageTitle(); // Update page title when navigating
      _checkBookmark(); // Check bookmark after page change
      _saveLastRead(); // Save last read when navigating
    }
  }

  void _toggleBookmark() async {
    if (isBookmarked) {
      // Remove bookmark
      await model.removeBookmark(surahIndex, currentPage);
      _showBookmarkMessage('Bookmark removed');
    } else {
      // Add bookmark with category URL and page title
      await model.addBookmark(
        surahIndex, 
        currentPage, 
        categoryUrl: categoryUrl,
        pageTitle: surahData['pageTitle'] ?? surahData['name'],
      );
      _showBookmarkMessage('Bookmark added');
    }
    
    // Update UI state after bookmark operation
    _checkBookmark();
  }

  void _checkBookmark() async {
    final bookmarked = await model.isBookmarked(surahIndex, currentPage);
    if (mounted) {
      setState(() {
        isBookmarked = bookmarked;
      });
    }
  }

  void _saveLastRead() async {
    try {
      final pageTitle = surahData['pageTitle'] ?? surahData['name'] ?? '';
      await model.saveLastRead(
        surahIndex,
        currentPage,
        surahData['name'] ?? '',
        pageTitle,
        categoryUrl: categoryUrl,
      );
    } catch (e) {
      print('Error saving last read: $e');
    }
  }

  void _showBookmarkMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          surahData['pageTitle'] ?? surahData['name'] ?? '',
          textAlign: TextAlign.left,
          maxLines: 2,
          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        leading: Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            padding: EdgeInsets.only(left: 8),
            icon: Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        actions: [
          IconButton(
            onPressed: _toggleBookmark,
            onLongPress: () {
              Navigator.of(context).pushNamed('/bookmarks');
            },
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () async {
              final url = await getlist.GetListSurah.getSurahUrl(surahIndex, currentPage);
              await Navigator.of(context).pushNamed('/websitepage', arguments: {
                'url': url,
              });
              // Refresh bookmark status when returning from websitepage
              _checkBookmark();
            },
            icon: Icon(
              Icons.language,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: FutureBuilder<String>(
        future: ThemeHelper.getThemeName(),
        builder: (context, snapshot) {
          final themeName = snapshot.data ?? 'Light';
          final backgroundColor = ThemeHelper.getContentBackgroundColor(themeName);
          final textColor = ThemeHelper.getTextColor(themeName);
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
              Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 800), // Max width for larger screens
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Page indicator
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: totalPages == 0 ? Text(
                          'Page ${currentPage + 1}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ) : Text(
                          'Page ${currentPage + 1} of $totalPages',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                      Divider(color: textColor.withOpacity(0.3)),
                      
                      // Content area
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Scrollbar(
                            controller: _scrollController,
                            thumbVisibility: true,
                            thickness: 2.0,
                            radius: Radius.circular(4.0),
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              child: _buildSurahBodyWithTheme(
                                context, 
                                surahData, 
                                model.bodyContent(surahIndex, currentPage, isDark, textColor, categoryUrl),
                                textColor,
                                isDark,
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      // Navigation buttons
                      _buildPageIndicatorWithTheme(
                        currentPage, 
                        totalPages, 
                        _previousPage, 
                        _nextPage,
                        isDark,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Theme-aware surah body builder
  Widget _buildSurahBodyWithTheme(
    BuildContext context,
    Map<String, String> surahData,
    Widget bodyContent,
    Color textColor,
    bool isDark,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate bismillah width based on available space (respects max width constraint)
        final bismillahWidth = constraints.maxWidth * 0.7;
        
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
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: 20),
                  Image.asset(
                    isDark 
                      ? 'assets/images/bismillah_darkmode.png'
                      : 'assets/images/bismillah.png',
                    fit: BoxFit.contain,
                    width: bismillahWidth,
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),

            // Content placeholder
            bodyContent,
          ],
        );
      },
    );
  }

  // Theme-aware page indicator builder
  Widget _buildPageIndicatorWithTheme(
    int currentPage,
    int totalPages,
    Function() onPrevious,
    Function() onNext,
    bool isDark,
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
              backgroundColor: isDark ? Colors.blue[700] : Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
          ElevatedButton.icon(
            onPressed: currentPage < totalPages - 1 ? onNext : null,
            icon: Icon(Icons.arrow_forward),
            label: Text('Next'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Colors.blue[700] : Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
