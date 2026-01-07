import 'package:flutter/material.dart';

class MainPage2 extends StatefulWidget {
  const MainPage2({super.key});

  @override
  _MainPage2State createState() => _MainPage2State();
}

class _MainPage2State extends State<MainPage2> {
  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate button size to match the background image buttons
    // Using EXACT same values as mainpage for consistency
    var buttonSize = Size(screenWidth * 0.36, screenHeight * 0.27);
    var buttonStyle = ElevatedButton.styleFrom(
      minimumSize: buttonSize,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Colors.white,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        color: Colors.black,
        height: screenHeight,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image - Kandungan 2.png
            Image.asset(
              'assets/images/Kandungan 2.png',
              fit: BoxFit.contain,
              alignment: Alignment.center,
            ),
            // Back button to navigate back to mainpage with slide transition
            Positioned(
              top: 40,
              left: 16,
              child: SafeArea(
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black, size: 28),
                  onPressed: () {
                    // Navigate back to mainpage with slide transition
                    // The slide transition will automatically reverse (slide from left to right)
                    Navigator.of(context).pop();
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
            // 4 Clickable boxes positioned over the image
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: screenHeight * 0.22), // Top spacing - SAME as mainpage
                  // First row - 2 boxes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Glosari button (top-left, green)
                      ElevatedButton(
                        style: buttonStyle,
                        onPressed: () {
                          Navigator.of(context).pushNamed('/glosari');
                        },
                        child: SizedBox(),
                      ),
                      SizedBox(width: screenWidth * 0.04), // Spacing - SAME as mainpage
                      // Hujjah button (top-right, beige)
                      ElevatedButton(
                        style: buttonStyle,
                        onPressed: () {
                          Navigator.of(context).pushNamed('/hujjah');
                        },
                        child: SizedBox(),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.015), // Spacing - SAME as mainpage
                  // Second row - 2 boxes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Asmaul Husna button (bottom-left, light purple)
                      ElevatedButton(
                        style: buttonStyle,
                        onPressed: () {
                          Navigator.of(context).pushNamed('/asmaul-husna');
                        },
                        child: SizedBox(),
                      ),
                      SizedBox(width: screenWidth * 0.04), // Spacing - SAME as mainpage
                      // Asal Usul Tafsir button (bottom-right, brown)
                      ElevatedButton(
                        style: buttonStyle,
                        onPressed: () {
                          Navigator.of(context).pushNamed('/asal-usul-tafsir');
                        },
                        child: SizedBox(),
                      ),
                    ],
                  ),
                  // Hidden "Bacaan Terakhir" placeholder to match mainpage layout and centering
                  SizedBox(height: screenHeight * 0.04),
                  // Invisible placeholder with same height as "Bacaan Terakhir" in mainpage
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.1,
                      vertical: screenHeight * 0.015,
                    ),
                    constraints: BoxConstraints(
                      minHeight: screenHeight * 0.095 * 0.85,
                      maxHeight: screenHeight * 0.095,
                    ),
                    color: Colors.transparent, // Invisible
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
