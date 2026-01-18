import 'package:flutter/material.dart';
import '../models/tadabbur.dart' as model;
import '../services/getlistsurah.dart' as getlist;
import '../utils/theme_helper.dart';

class TadabburPage extends StatefulWidget {
  const TadabburPage({super.key});

  @override
  _TadabburPageState createState() => _TadabburPageState();
}

class _TadabburPageState extends State<TadabburPage> {
  List<Map<String, String>> surahList = [];
  bool isLoading = true;

  List<Map<String, String>> filteredSurahList = [];

  @override
  void initState() {
    super.initState();
    _loadSurahNames();
  }

  void _loadSurahNames() async {
    if (!mounted) return;
    
    setState(() {
      isLoading = true;
    });
    
    try {
      final names = await getlist.GetListSurah.getSurahNames();
      
      // Check if widget is still mounted after async operation
      if (!mounted) return;
      
      // Ensure all maps are properly typed as Map<String, String>
      final convertedNames = names.map((item) {
        return Map<String, String>.from(item.map((key, value) => MapEntry(key, value.toString())));
      }).toList();
      
      setState(() {
        surahList = convertedNames;
        filteredSurahList = convertedNames;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading surah names: $e');
      
      // Check if widget is still mounted after error
      if (!mounted) return;
      
      // Fallback to hardcoded list if scraping fails
      // Add additional_text and category_url fields to fallback list
      final fallbackList = model.surahList.map((item) {
        final Map<String, String> newItem = Map<String, String>.from(item);
        if (!newItem.containsKey('additional_text')) {
          newItem['additional_text'] = '';
        }
        if (!newItem.containsKey('category_url')) {
          // Generate default category URL from surah number
          final number = newItem['number'] ?? '001';
          newItem['category_url'] = 'https://tafseerliterate.wordpress.com/surah-${number.padLeft(3, '0')}-';
        }
        return newItem;
      }).toList();
      
      setState(() {
        surahList = fallbackList;
        filteredSurahList = fallbackList;
        isLoading = false;
      });
    }
  }

  void _filterSurahs(String query) {
    if (!mounted) return;
    
    setState(() {
      filteredSurahList = surahList
          .where(
            (surah) =>
                surah['name']!.toLowerCase().contains(query.toLowerCase()) ||
                (surah['additional_text']?.isNotEmpty == true && 
                 surah['additional_text']!.toLowerCase().contains(query.toLowerCase())),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose Surah', style: TextStyle(color: Colors.white)),
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
                  constraints: BoxConstraints(maxWidth: 600), // Max width for larger screens
                  padding: EdgeInsets.all(16.0),
                  child: isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              const Color(0xFF7CB342),
                            ),
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Search field with theme support
                            _buildSearchFieldWithTheme(_filterSurahs, textColor, isDark),
                            SizedBox(height: 20),
                            Center(
                              child: Image.asset(
                                isDark 
                                  ? 'assets/images/bismillah_darkmode.png'
                                  : 'assets/images/bismillah.png',
                                fit: BoxFit.contain,
                                width: MediaQuery.of(context).size.width * 0.7,
                              ),
                            ),
                            Divider(color: textColor.withOpacity(0.3)),
                            SizedBox(height: 20),
                            Expanded(
                              child: ListView.builder(
                                itemCount: filteredSurahList.length,
                                itemBuilder: (context, index) {
                                  final filteredSurah = filteredSurahList[index];
                                  // Find the actual index in the original surahList
                                  // For juzuk variants, we need to find the main surah index
                                  final surahNumber = int.parse(filteredSurah['number']!);
                                  final actualIndex = surahNumber - 1; // Convert to 0-based index
                                  
                                  return Column(
                                    children: [
                                      _buildSurahButtonWithTheme(
                                        context,
                                        filteredSurah['number']!,
                                        filteredSurah['name']!,
                                        filteredSurah['additional_text'] ?? '',
                                        textColor,
                                        isDark,
                                        () {
                                          Navigator.of(context).pushNamed('/surahPages', arguments: {
                                            ...filteredSurah,
                                            'surahIndex': actualIndex,
                                          });
                                        },
                                      ),
                                      SizedBox(height: 10),
                                    ],
                                  );
                                },
                              ),
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

  // Theme-aware search field builder
  Widget _buildSearchFieldWithTheme(Function(String) onSearch, Color textColor, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: TextField(
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          hintText: 'Search Surah...',
          hintStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
          prefixIcon: Icon(Icons.search, color: textColor),
          filled: true,
          fillColor: ThemeHelper.getContentBackgroundColor(isDark ? 'Dark' : 'Light'),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32.0),
            borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32.0),
            borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32.0),
            borderSide: BorderSide(color: const Color(0xFF7CB342), width: 2),
          ),
        ),
        onChanged: (value) {
          onSearch(value);
        },
      ),
    );
  }

  // Theme-aware surah button builder
  Widget _buildSurahButtonWithTheme(
    BuildContext context,
    String nombor,
    String surah,
    String additionalText,
    Color textColor,
    bool isDark,
    Function() onPressed,
  ) {
    // Select image paths based on theme, with fallback to regular images
    final nomborImagePath = isDark 
        ? 'assets/images/nomborplace_darkmode.png' 
        : 'assets/images/nomborplace.png';
    final surahImagePath = isDark 
        ? 'assets/images/surahplace_darkmode.png' 
        : 'assets/images/surahplace.png';
    
    // Use LayoutBuilder to get the constrained width
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate widths based on available space (respects max width constraint)
        final nomborWidth = constraints.maxWidth * 0.15;
        final surahWidth = constraints.maxWidth * 0.7;
        
        return GestureDetector(
          onTap: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    nomborImagePath,
                    fit: BoxFit.contain,
                    width: nomborWidth,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback to regular image if dark mode image not found
                      return Image.asset(
                        'assets/images/nomborplace.png',
                        fit: BoxFit.contain,
                        width: nomborWidth,
                      );
                    },
                  ),
                  Text(nombor, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                ],
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    surahImagePath,
                    fit: BoxFit.contain,
                    width: surahWidth,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback to regular image if dark mode image not found
                      return Image.asset(
                        'assets/images/surahplace.png',
                        fit: BoxFit.contain,
                        width: surahWidth,
                      );
                    },
                  ),
                  // If there's additional text, show it below; otherwise center the surah name
                  additionalText.isNotEmpty
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(surah, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                            Text(additionalText, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor)),
                          ],
                        )
                      : Text(surah, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
