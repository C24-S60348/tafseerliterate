import 'package:flutter/material.dart';
import '../services/getasalusultafsir.dart' as getasalusultafsir;
import '../utils/theme_helper.dart';
import 'package:http/http.dart' as http;

class AsalUsulTafsirPage extends StatefulWidget {
  const AsalUsulTafsirPage({super.key});

  @override
  _AsalUsulTafsirPageState createState() => _AsalUsulTafsirPageState();
}

class _AsalUsulTafsirPageState extends State<AsalUsulTafsirPage> {
  List<Map<String, String>> posts = [];
  bool isLoading = true;
  bool hasNoInternet = false;

  @override
  void initState() {
    super.initState();
    _loadPosts();
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

  void _loadPosts() async {
    // Check internet connection first
    final hasInternet = await _checkInternetConnection();
    
    final postList = await getasalusultafsir.GetAsalUsulTafsir.getAsalUsulTafsirPosts();
    
    setState(() {
      posts = postList;
      isLoading = false;
      hasNoInternet = !hasInternet;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Usul Tafsir', style: TextStyle(color: Colors.white)),
        centerTitle: true,
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
                            'Select Article',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          SizedBox(height: 8),
                          isLoading 
                            ? SizedBox(height: 15,)
                            : hasNoInternet && posts.isEmpty
                              ? Text(
                                  'No internet connection',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.red[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : Text(
                                  'Total: ${posts.length} articles',
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

                    // Posts list
                    Expanded(
                      child: isLoading
                          ? Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  const Color(0xFF7CB342),
                                ),
                              ),
                            )
                          : hasNoInternet && posts.isEmpty
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
                            : posts.isEmpty
                              ? Center(
                                  child: Text(
                                    'No articles available',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: isDark ? Colors.grey[400] : Colors.black54,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: posts.length,
                                  itemBuilder: (context, index) {
                                    final post = posts[index];
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
                                            '${index + 1}',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          post['title'] ?? 'Untitled',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: textColor,
                                          ),
                                        ),
                                        subtitle: Text(
                                          'Article ${index + 1}',
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
                                          Navigator.of(context).pushNamed('/baca-asal-usul-tafsir', arguments: {
                                            'url': post['url'],
                                            'title': post['title'],
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

