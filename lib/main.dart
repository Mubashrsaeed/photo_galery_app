import 'package:flutter/material.dart';
import 'package:photo_galery_app/bottom_navi_screen.dart';

void main() {
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return const Material(
      child: Center(
        child: Text(
          "Something went wrong",
          style: TextStyle(color: Colors.red),
        ),
      ),
    );
  };

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);

    debugPrint("FLUTTER ERROR: ${details.exception}");
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "photo Galery",
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: BottomNavScreen(),
    );
  }
}
