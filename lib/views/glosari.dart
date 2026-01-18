import 'package:flutter/material.dart';
import '../models/glosari.dart' as model;
import '../utils/theme_helper.dart';

class GlosariPage extends StatefulWidget {
  const GlosariPage({super.key});

  @override
  _GlosariPageState createState() => _GlosariPageState();
}

class _GlosariPageState extends State<GlosariPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isInitialized = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      _loadGlosariContent();
    }
  }

  void _loadGlosariContent() async {
    try {
      // Get theme to determine snackbar color
      final themeName = await ThemeHelper.getThemeName();
      final isDark = themeName == 'Dark';
      
      // Show a subtle notification that loading is starting
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Loading content...',
              style: TextStyle(color: Colors.white),
            ),
            duration: Duration(seconds: 2),
            backgroundColor: isDark ? Colors.grey[850] : const Color(0xFF7CB342),
          ),
        );
      }
      
      // Actually load the content to ensure it's fetched
      final content = await model.getGlosariContent();
      
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
    } catch (e) {
      print('Error loading content: $e');
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
        title: Text('Glossary', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              const url = 'https://tafseerliterate.wordpress.com/glossary/';
              await Navigator.of(context).pushNamed('/websitepage', arguments: {
                'url': url,
              });
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
                            child: _buildGlosariBodyWithTheme(
                              context, 
                              model.bodyContent(isDark, textColor),
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

  // Theme-aware glosari body builder
  Widget _buildGlosariBodyWithTheme(
    BuildContext context,
    Widget bodyContent,
    Color textColor,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Glosari header
        Center(
          child: Text(
            'Glossary',
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

