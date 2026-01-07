import 'package:flutter/material.dart';
import '../models/baca.dart' as model;
import '../services/getlistsurah.dart' as getlist;
import '../models/tadabbur.dart' as surahlist;
import '../utils/theme_helper.dart';

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({super.key});

  @override
  _BookmarksPageState createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  List<Map<String, dynamic>> bookmarks = [];
  bool isLoading = true;
  bool _isNavigating = false;
  final Map<int, Future<Map<String, dynamic>?>> _surahCache = {};

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  void _loadBookmarks() async {
    try {
      final savedBookmarks = await model.getBookmarks();
      setState(() {
        bookmarks = savedBookmarks;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading bookmarks: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _removeBookmark(int index) async {
    final bookmark = bookmarks[index];
    try {
      await model.removeBookmark(
        bookmark['surahIndex'], 
        bookmark['currentPage']
      );
      setState(() {
        bookmarks.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bookmark removed'),
          duration: Duration(seconds: 2),
          backgroundColor: const Color.fromARGB(255, 52, 21, 104),
        ),
      );
    } catch (e) {
      print('Error removing bookmark: $e');
    }
  }

  void _navigateToVerse(Map<String, dynamic> bookmark) async {
    // Prevent multiple simultaneous navigations
    if (_isNavigating) return;
    
    setState(() {
      _isNavigating = true;
    });
    
    try {
      // Get stored category URL from bookmark
      final categoryUrl = bookmark['categoryUrl'] as String?;
      
      // Get surah data from the service
      final surah = await getlist.GetListSurah.getSurahByIndex(bookmark['surahIndex'], categoryUrl: categoryUrl);
      if (surah != null) {
        await Navigator.of(context).pushNamed('/baca', arguments: {
          'number': surah['surahIndex'],
          'name': surahlist.surahList[surah['surahIndex']]['name'],
          'name_arab': surahlist.surahList[surah['surahIndex']]['name_arab'],
          'surahIndex': bookmark['surahIndex'],
          'pageIndex': bookmark['currentPage'],
          'category_url': categoryUrl,
        });
      }
    } catch (e) {
      print('Error navigating to verse: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isNavigating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bookmarks', style: TextStyle(color: Colors.white)),
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
              Container(
                padding: EdgeInsets.all(16.0),
                child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            const Color.fromARGB(255, 52, 21, 104),
                          ),
                        ),
                      )
                    : bookmarks.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.bookmark_border,
                                  size: 64,
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No bookmarks',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: isDark ? Colors.grey[300] : Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Bookmark pages while reading to see them here',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark ? Colors.grey[400] : Colors.grey[500],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: bookmarks.length,
                            itemBuilder: (context, index) {
                              final bookmark = bookmarks[index];
                              final surahIndex = bookmark['surahIndex'] as int;
                              
                              // Cache the future to avoid reloading when widget rebuilds
                              if (!_surahCache.containsKey(surahIndex)) {
                                _surahCache[surahIndex] = getlist.GetListSurah.getSurahByIndex(surahIndex);
                              }
                              
                              return FutureBuilder<Map<String, dynamic>?>(
                                key: ValueKey('surah_$surahIndex'),
                                future: _surahCache[surahIndex],
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return Card(
                                      margin: EdgeInsets.only(bottom: 12),
                                      color: backgroundColor,
                                      child: Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Row(
                                          children: [
                                            CircularProgressIndicator(),
                                            SizedBox(width: 16),
                                            Text('Loading...', style: TextStyle(color: textColor)),
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                  
                                  final surah = snapshot.data;
                                  if (surah == null) {
                                    return SizedBox.shrink();
                                  }
                                  
                                  return Card(
                                    margin: EdgeInsets.only(bottom: 12),
                                    elevation: 4,
                                    color: backgroundColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: InkWell(
                                      onTap: _isNavigating ? null : () => _navigateToVerse(bookmark),
                                      borderRadius: BorderRadius.circular(12),
                                      child: Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      // Show page title if available, otherwise show surah name
                                                      Text(
                                                        bookmark['pageTitle'] ?? '${surahlist.surahList[surah['surahIndex']]['name']} (${surahlist.surahList[surah['surahIndex']]['name_arab']})',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.bold,
                                                          color: isDark ? Colors.white : const Color.fromARGB(255, 52, 21, 104),
                                                        ),
                                                      ),
                                                      SizedBox(height: 4),
                                                      // Show surah name as subtitle if page title exists
                                                      if (bookmark['pageTitle'] != null)
                                                        Text(
                                                          '${surahlist.surahList[surah['surahIndex']]['name']} (${surahlist.surahList[surah['surahIndex']]['name_arab']})',
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                                                          ),
                                                        ),
                                                      if (bookmark['pageTitle'] != null)
                                                        SizedBox(height: 4),
                                                      Text(
                                                        'Page ${bookmark['currentPage'] + 1}',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: isDark ? Colors.grey[300] : Colors.grey[600],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                IconButton(
                                                  onPressed: () => _removeBookmark(index),
                                                  icon: Icon(
                                                    Icons.bookmark_remove,
                                                    color: Colors.red[400],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'Added ${_formatDate(DateTime.parse(bookmark['dateAdded']))}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: isDark ? Colors.grey[400] : Colors.grey[500],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? 'a week ago' : '$weeks weeks ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? 'a month ago' : '$months months ago';
    } else {
      return 'on ${date.day}/${date.month}/${date.year}';
    }
  }
}
