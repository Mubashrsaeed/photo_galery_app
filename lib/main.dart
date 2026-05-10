import 'package:flutter/material.dart';
import 'package:photo_galery_app/bottom_navi_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
