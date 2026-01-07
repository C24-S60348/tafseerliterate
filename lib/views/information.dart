import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../utils/uihelper.dart';
import '../utils/theme_helper.dart';

class InformationPage extends StatefulWidget {
  const InformationPage({super.key});

  @override
  _InformationPageState createState() => _InformationPageState();
}

class _InformationPageState extends State<InformationPage> {
  String _version = 'Loading...';
  String _buildNumber = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _version = packageInfo.version;
        _buildNumber = packageInfo.buildNumber;
      });
    } catch (e) {
      setState(() {
        _version = 'Unknown';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Information', style: TextStyle(color: Colors.white)),
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
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'About the App',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        SizedBox(height: 10),

                        Divider(color: textColor.withOpacity(0.3)),
                        
                        Text(
                          'The Qur\'an is the word of Allah ‎ﷻ to His servants. As believers, we yearn for His guidance and seek the most practical ways to study and draw closer to Him.\n\n'
                          'Tafseer Literate App was developed with the hope of helping users find Qur\'anic tafseer with an accessible writing style that relates to our daily challenges. Using modern technology, this app ensures that we can read and reflect on Qur\'anic tafseer anytime, anywhere.\n\n'
                          'All original content for this app comes from the website: https://tafseerliterate.wordpress.com\n\n'
                          'Key features of Tafseer Literate:\n'
                          '▪Can be read Online or Offline\n'
                          '▪Multiple color themes to suit user preference\n'
                          '▪Bookmark last read page\n'
                          '▪Tutorial on how to use the app provided\n'
                          '▪Accessible and thoughtful tafseer language\n'
                          '▪Quick navigation between surahs\n'
                          '▪Copy & paste tafseer text.\n\n'
                          'May this app guide our souls with guidance from the Qur\'an.\n\n'
                          'This content is provided for educational purposes, based on authentic Ahlus Sunnah wal Jamaah tafseer, and is not intended to replace reference to original texts or authoritative fatwa.',
                          style: TextStyle(
                            fontSize: 16,
                            color: textColor,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                        SizedBox(height: 10),
                        Divider(color: textColor.withOpacity(0.3)),
                        SizedBox(height: 10),
                        Text(
                          'Version: $_version${_buildNumber.isNotEmpty ? " ($_buildNumber)" : ""}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        SizedBox(height: 10),
                        Divider(color: textColor.withOpacity(0.3)),
                        SizedBox(height: 10),
                        Text(
                          'For any questions or suggestions, please contact: ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            launchUrl(Uri.parse('mailto:tafseerliterate@gmail.com'));
                          },
                          child: Center(
                            child: Text(
                              'tafseerliterate@gmail.com',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color.fromARGB(255, 51, 135, 54),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Divider(color: textColor.withOpacity(0.3)),
                        GestureDetector(
                          onTap: () {
                            launchUrl(Uri.parse('https://tafseerliterate.wordpress.com'));
                          },
                          child: Center(
                            child: Text(
                              'tafseerliterate.wordpress.com',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 51, 135, 54),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Center(
                          child: myButtonBlack(context, 'Tutorial', () {
                            Navigator.of(context).pushNamed('/tutorial');
                          },),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
