import 'package:flutter/material.dart';
import '../models/asalusultafsir.dart' as model;
import '../utils/theme_helper.dart';

class BacaAsalUsulTafsirPage extends StatefulWidget {
  const BacaAsalUsulTafsirPage({super.key});

  @override
  _BacaAsalUsulTafsirPageState createState() => _BacaAsalUsulTafsirPageState();
}

class _BacaAsalUsulTafsirPageState extends State<BacaAsalUsulTafsirPage> {
  late Map<String, String> postData;
  bool _isInitialized = false;
  final ScrollController _scrollController = ScrollController();
  String? postUrl;
  String? postTitle;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is Map<String, dynamic>) {
        postData = args.cast<String, String>();
        postUrl = args['url']?.toString();
        postTitle = args['title']?.toString() ?? 'Ilmu Usul Tafsir';
        _isInitialized = true;
        _loadAsalUsulTafsirContent();
      }
    }
  }

  void _loadAsalUsulTafsirContent() async {
    try {
      // Get theme to determine snackbar color
      final themeName = await ThemeHelper.getThemeName();
      final isDark = themeName == 'Dark';
      
      // Show a subtle notification that loading is starting
      if (mounted && postUrl != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Loading content...',
              style: TextStyle(color: Colors.white),
            ),
            duration: Duration(seconds: 2),
            backgroundColor: isDark ? Colors.grey[850] : Color.fromARGB(255, 52, 21, 104),
          ),
        );
        
        // Actually load the content to ensure it's fetched
        final content = await model.getAsalUsulTafsirContent(postUrl!);
        
        // Show completion notification after content is loaded
        if (mounted) {
          if (content != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Content loaded successfully!'),
                duration: Duration(seconds: 2),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to load content'),
                duration: Duration(seconds: 2),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      print('Error loading usul tafsir content: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load content'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          postTitle ?? 'Ilmu Usul Tafsir',
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
        actions: [
          IconButton(
            onPressed: () async {
              if (postUrl != null) {
                await Navigator.of(context).pushNamed('/websitepage', arguments: {
                  'url': postUrl,
                });
              }
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
              Container(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [                    
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
                            child: _buildAsalUsulTafsirBodyWithTheme(
                              context, 
                              postTitle ?? 'Ilmu Usul Tafsir',
                              postUrl != null 
                                ? model.bodyContent(postUrl!, isDark, textColor)
                                : Center(
                                    child: Text(
                                      'No URL available',
                                      style: TextStyle(color: textColor),
                                    ),
                                  ),
                              textColor,
                              isDark,
                            ),
                          ),
                        ),
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

  // Theme-aware ilmu usul tafsir body builder
  Widget _buildAsalUsulTafsirBodyWithTheme(
    BuildContext context,
    String title,
    Widget bodyContent,
    Color textColor,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ilmu Usul Tafsir header
        Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
        SizedBox(height: 20),

        // Content placeholder
        bodyContent,
      ],
    );
  }
}

