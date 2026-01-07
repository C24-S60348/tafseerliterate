
import 'package:flutter/material.dart';

/// Creates a slide transition route that slides from right to left
PageRoute<T> slideRoute<T extends Object?>(Widget page, {Object? arguments, Duration transitionDuration = const Duration(milliseconds: 300)}) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    settings: arguments != null ? RouteSettings(arguments: arguments) : null,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
    transitionDuration: transitionDuration,
  );
}

/// Navigate to a route with slide animation using a widget
Future<T?> navigateWithSlide<T extends Object?>(BuildContext context, Widget page, {Object? arguments}) {
  return Navigator.of(context).push<T>(
    slideRoute<T>(page, arguments: arguments),
  );
}

Widget myButton(BuildContext context, String text, Function() onPressed) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
    ),
    onPressed: () {
      //pushNamedAndRemoveUntil untuk menghapus semua route sebelumnya dan menampilkan route home
      //pushReplacementNamed untuk menghapus route sebelumnya dan menampilkan route home
      onPressed();
    },
    child: Text(text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),),
  );
}

Widget myButtonBlack(BuildContext context, String text, Function() onPressed) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color.fromARGB(255, 184, 233, 185),
    ),
    onPressed: () {
      //pushNamedAndRemoveUntil untuk menghapus semua route sebelumnya dan menampilkan route home
      //pushReplacementNamed untuk menghapus route sebelumnya dan menampilkan route home
      onPressed();
    },
    child: Text(text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),),
  );
}


