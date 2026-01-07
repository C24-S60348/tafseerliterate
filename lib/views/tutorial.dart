import '../utils/uihelper.dart';
import 'package:flutter/material.dart';

class Tutorial extends StatelessWidget {
  const Tutorial({super.key});

  @override
  Widget build(BuildContext context) {
    return const TutorialContent();
  }
}

// Standalone page that can be used within the main app
class TutorialContent extends StatefulWidget {
  const TutorialContent({super.key});

  @override
  _TutorialContentState createState() => _TutorialContentState();
}

class _TutorialContentState extends State<TutorialContent> {
  final PageController _pageController = PageController();
  int _pageViewIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 253, 255, 251),
      appBar: AppBar(
        title: Text("Tutorial / Cara penggunaan", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 253, 255, 251),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back, color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          // SizedBox(
          //   width: double.infinity,
          //   child: Center(
          //     child: Text("Tutorial / Cara penggunaan", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
          //   ),
          // ),
          Container(
            height: MediaQuery.of(context).size.height * 0.8,
            color: Colors.transparent, // Adding a background color
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _pageViewIndex = index;
                });
              },
              children: [
                Image.asset("assets/images/tutorial4.png", fit: BoxFit.contain,),
                Image.asset("assets/images/tutorial5.png", fit: BoxFit.contain),
                Image.asset("assets/images/tutorial6.png", fit: BoxFit.contain),
                Image.asset("assets/images/tutorial7.png", fit: BoxFit.contain),
                Image.asset("assets/images/tutorial8.png", fit: BoxFit.contain),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          if (_pageViewIndex != 4) // Assuming last page index is 2
           SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: ElevatedButton(
                onPressed: () {
                  _pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Geser", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward),
                  ],
                ),
              )
            )
          else 
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: myButton(context, "Selesai", () {
                  Navigator.of(context).pushNamed('/mainpage');
                })

            )
        ],
      ),
    );
  }
}
