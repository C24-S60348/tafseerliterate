import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/baca.dart' as model;
import '../services/getlistsurah.dart' as getlist;
import '../models/tadabbur.dart' as surahlist;
import '../services/version_checker.dart';
import '../widgets/update_dialog.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Map<String, dynamic>? lastRead;
  bool isLoadingLastRead = true;

  @override
  void initState() {
    super.initState();
    _loadLastRead();
    _checkForUpdates();
  }
  
  void _checkForUpdates() async {
    // Wait a bit for the page to load
    await Future.delayed(Duration(seconds: 2));
    
    try {
      print('🔄 Auto-checking for updates on app start...');
      final notifications = await VersionChecker.checkForUpdate();
      
      print('📬 Found ${notifications.length} notification(s)');
      
      // Show all notifications (update first, then news) one by one
      if (notifications.isNotEmpty && mounted) {
        // Sort so updates come before news
        notifications.sort((a, b) {
          if (a.isNews == b.isNews) return 0;
          return a.isNews ? 1 : -1; // Updates (isNews=false) first
        });
        
        for (var i = 0; i < notifications.length; i++) {
          final notification = notifications[i];
          print('📢 Showing notification ${i + 1}/${notifications.length}: ${notification.title ?? (notification.isNews ? "News" : "Update")}');
          if (mounted) {
            await UpdateDialog.show(context, notification);
          }
        }
      } else {
        print('✅ No updates or news to show (or already dismissed)');
      }
    } catch (e) {
      print('❌ Error checking for updates: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload last read when returning to this page (only if not already loading)
    if (!isLoadingLastRead) {
      _loadLastRead();
    }
  }

  void _loadLastRead() async {
    try {
      final savedLastRead = await model.getLastRead();
      if (mounted) {
        setState(() {
          lastRead = savedLastRead;
          isLoadingLastRead = false;
        });
      }
    } catch (e) {
      print('Error loading last read: $e');
      if (mounted) {
        setState(() {
          isLoadingLastRead = false;
        });
      }
    }
  }

  void _navigateToLastRead() async {
    if (lastRead == null) return;
    
    try {
      final surahIndex = lastRead!['surahIndex'] as int;
      final pageIndex = lastRead!['pageIndex'] as int;
      final categoryUrl = lastRead!['categoryUrl'] as String?;
      
      // Get surah data from the service
      final surah = await getlist.GetListSurah.getSurahByIndex(surahIndex, categoryUrl: categoryUrl);
      if (surah != null && mounted) {
        // Get surah name and arabic name from surahlist
        final surahNumber = surahIndex + 1;
        String surahName = lastRead!['surahName'] as String? ?? '';
        String surahNameArab = '';
        
        // Try to get from surahlist
        if (surahNumber > 0 && surahNumber <= surahlist.surahList.length) {
          final surahData = surahlist.surahList[surahNumber - 1];
          surahName = surahData['name'] ?? surahName;
          surahNameArab = surahData['name_arab'] ?? '';
        }
        
        await Navigator.of(context).pushNamed('/baca', arguments: {
          'number': surahNumber.toString().padLeft(3, '0'),
          'name': surahName,
          'name_arab': surahNameArab,
          'surahIndex': surahIndex,
          'pageIndex': pageIndex,
          'pageTitle': lastRead!['pageTitle'] as String?,
          'category_url': categoryUrl,
        });
        
        // Reload last read after navigation
        _loadLastRead();
      }
    } catch (e) {
      print('Error navigating to last read: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Calculate button size to match the background image buttons
    // Based on the Kandungan.png image analysis:
    // - Buttons take up approximately 36% of width and 27% of height each
    // - With rounded corners matching the image
    var buttonsize = Size(screenWidth * 0.36, screenHeight * 0.27);
    var buttonstyle = ElevatedButton.styleFrom(
      minimumSize: buttonsize,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Colors.white,
    );
    
    return Scaffold(
      backgroundColor: Colors.black,
      // appBar: AppBar(
      //   title: Text('Celik Tafsir', style: TextStyle(color: Colors.white),),
      //   centerTitle: true,
      //   automaticallyImplyLeading: false, // Disables back button
      //   backgroundColor: Colors.black,
      // ),
      body: Container(
        color: Colors.black,
        height: screenHeight,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image.asset(
            //   'assets/images/bg.jpg',
            //   fit: BoxFit.cover,
            //   width: double.infinity,
            //   height: double.infinity,
            // ),
            Image.asset(
              'assets/images/Kandungan.png',
              fit: BoxFit.contain,
              alignment: Alignment.center,
            ),
            // Button to navigate to Kandungan 2 page (top right)
            Positioned(
              top: 40,
              right: 16,
              child: SafeArea(
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_forward,
                    color: Colors.black,
                    size: 28,
                  ),
                  onPressed: () {
                    // Navigate to mainpage2 with slide transition
                    Navigator.of(context).pushNamed('/mainpage2');
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: CircleBorder(),
                    shadowColor: Colors.black,
                    elevation: 5,
                  ),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: screenHeight * 0.22), // Top spacing to match image
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Tadabbur button (top-left, green)
                      ElevatedButton(
                        style: buttonstyle,
                        onPressed: () {
                          Navigator.of(context).pushNamed('/tadabbur');
                        },
                        child: SizedBox(),
                      ),
                      SizedBox(width: screenWidth * 0.04), // Spacing between buttons
                      // Bookmarks button (top-right, beige)
                      ElevatedButton(
                        style: buttonstyle,
                        onPressed: () {
                          Navigator.of(context).pushNamed('/bookmarks');
                        },
                        child: SizedBox(),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.015), // Spacing between rows
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Settings button (bottom-left, light purple)
                      ElevatedButton(
                        style: buttonstyle,
                        onPressed: () {
                          Navigator.of(context).pushNamed('/settings');
                        },
                        child: SizedBox(),
                      ),
                      SizedBox(width: screenWidth * 0.04), // Spacing between buttons
                      // Info button (bottom-right, brown)
                      ElevatedButton(
                        style: buttonstyle,
                        onPressed: () {
                          Navigator.of(context).pushNamed('/info');
                        },
                        child: SizedBox(),
                      ),
                    ],
                  ),
                  // Last Read Section - integrated into vertical layout
                  SizedBox(height: screenHeight * 0.04),
                  if (!isLoadingLastRead && lastRead != null)
                    LayoutBuilder(
                            builder: (context, constraints) {
                              // Responsive sizing based on screen dimensions to match background image
                              final horizontalMargin = screenWidth * 0.1; // 10% margin on each side
                              final ornamentSize = screenHeight * 0.06; // 6% of screen height
                              final containerHeight = screenHeight * 0.095; // 9.5% of screen height
                              final titleFontSize = screenHeight * 0.015; // 1.5% of screen height
                              final nameFontSize = screenHeight * 0.019; // 1.9% of screen height
                              final subtitleFontSize = screenHeight * 0.015; // 1.5% of screen height
                              
                              return GestureDetector(
                                onTap: _navigateToLastRead,
                                child: Container(
                                  margin: EdgeInsets.symmetric(
                                    horizontal: horizontalMargin,
                                    vertical: screenHeight * 0.015,
                                  ),
                                  constraints: BoxConstraints(
                                    minHeight: containerHeight * 0.85,
                                    maxHeight: containerHeight,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.03,
                                    vertical: screenHeight * 0.01,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF2C2C2C), // Dark grey matching the bottom bar in Kandungan.png
                                    borderRadius: BorderRadius.circular(20), // Fully rounded
                                    border: Border.all(
                                      color: Color(0xFF4A4A4A).withOpacity(0.3), // Subtle warm grey border
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.6),
                                        blurRadius: 12,
                                        spreadRadius: 1,
                                        offset: Offset(0, -3),
                                      ),
                                      BoxShadow(
                                        color: Color(0xFF3A3A3A).withOpacity(0.2),
                                        blurRadius: 6,
                                        spreadRadius: -1,
                                        offset: Offset(0, -1),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      // Silver floral ornament on the left
                                      Container(
                                        width: ornamentSize,
                                        height: ornamentSize,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: RadialGradient(
                                            colors: [
                                              Color(0xFFD4D4D4), // Silver-grey center matching Kandungan.png
                                              Color(0xFFB8B8B8), // Medium silver-grey
                                              Color(0xFF9C9C9C), // Darker silver-grey edge
                                            ],
                                            stops: [0.0, 0.6, 1.0],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Color(0xFFB8B8B8).withOpacity(0.5),
                                              blurRadius: 10,
                                              spreadRadius: 2,
                                              offset: Offset(0, 2),
                                            ),
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.3),
                                              blurRadius: 6,
                                              spreadRadius: -1,
                                              offset: Offset(0, -2),
                                            ),
                                          ],
                                        ),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            // Outer decorative rings
                                            Container(
                                              width: ornamentSize * 0.8,
                                              height: ornamentSize * 0.8,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Color(0xFFE0E0E0).withOpacity(0.5),
                                                  width: 1.5,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: ornamentSize * 0.7,
                                              height: ornamentSize * 0.7,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Color(0xFFE0E0E0).withOpacity(0.3),
                                                  width: 1,
                                                ),
                                              ),
                                            ),
                                            // Center floral pattern
                                            CustomPaint(
                                              size: Size(ornamentSize * 0.4, ornamentSize * 0.4),
                                              painter: FloralOrnamentPainter(),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: screenWidth * 0.03),
                                      // Text content with proper constraints
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Last Read',
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(0.7),
                                                fontSize: titleFontSize,
                                                fontWeight: FontWeight.w500,
                                                letterSpacing: 1.0,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: screenHeight * 0.003),
                                            // Text(
                                            //   lastRead!['surahName'] as String? ?? '',
                                            //   style: TextStyle(
                                            //     color: Colors.white,
                                            //     fontSize: nameFontSize,
                                            //     fontWeight: FontWeight.bold,
                                            //     letterSpacing: 0.3,
                                            //     height: 1.2,
                                            //   ),
                                            //   maxLines: 1,
                                            //   overflow: TextOverflow.ellipsis,
                                            // ),
                                            // SizedBox(height: screenHeight * 0.003),
                                            Builder(
                                              builder: (context) {
                                                if (lastRead!['pageTitle'] != null && 
                                                    (lastRead!['pageTitle'] as String).isNotEmpty) {
                                                  return Text(
                                                    lastRead!['pageTitle'] as String,
                                                    style: TextStyle(
                                                      color: Colors.white.withOpacity(0.9),
                                                      fontSize: subtitleFontSize,
                                                      fontWeight: FontWeight.w400,
                                                      height: 1.3,
                                                    ),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  );
                                                } else {
                                                  return Text(
                                                    'Page ${(lastRead!['pageIndex'] as int) + 1}',
                                                    style: TextStyle(
                                                      color: Colors.white.withOpacity(0.9),
                                                      fontSize: subtitleFontSize,
                                                      fontWeight: FontWeight.w400,
                                                      height: 1.3,
                                                    ),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  );
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: screenWidth * 0.02),
                                      // Arrow icon to indicate it's tappable
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.white.withOpacity(0.5),
                                        size: screenHeight * 0.02,
                                      ),
                                      SizedBox(width: screenWidth * 0.01),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for silver floral ornament with high detail
class FloralOrnamentPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3;

    // Outer decorative ring - silver-grey tone
    final outerRingPaint = Paint()
      ..color = Color(0xFFD4D4D4).withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius * 0.9, outerRingPaint);

    // Main petal paint - silver-grey matching Kandungan.png
    final petalPaint = Paint()
      ..color = Color(0xFFE0E0E0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Draw 8-petaled floral pattern
    for (int i = 0; i < 8; i++) {
      final angle = (i * 2 * math.pi) / 8;
      final petalStart = Offset(
        center.dx + radius * 0.25 * math.cos(angle),
        center.dy + radius * 0.25 * math.sin(angle),
      );
      final petalEnd = Offset(
        center.dx + radius * 0.85 * math.cos(angle),
        center.dy + radius * 0.85 * math.sin(angle),
      );

      // Draw petal line
      canvas.drawLine(petalStart, petalEnd, petalPaint);

      // Draw decorative dots at petal tips
      final dotPaint = Paint()
        ..color = Color(0xFFE0E0E0)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(petalEnd, 2.0, dotPaint);
    }

    // Inner decorative ring
    final innerRingPaint = Paint()
      ..color = Color(0xFFD4D4D4).withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius * 0.2, innerRingPaint);

    // Center circle with gradient effect
    final centerPaint = Paint()
      ..color = Color(0xFFE0E0E0).withOpacity(0.8)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.15, centerPaint);

    // Inner detail dots
    final detailDotPaint = Paint()
      ..color = Color(0xFFD4D4D4).withOpacity(0.6)
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 8; i++) {
      final angle = (i * 2 * math.pi) / 8;
      final dotPos = Offset(
        center.dx + radius * 0.35 * math.cos(angle),
        center.dy + radius * 0.35 * math.sin(angle),
      );
      canvas.drawCircle(dotPos, 1.5, detailDotPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
