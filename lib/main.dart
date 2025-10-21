import 'package:flutter/material.dart';
import 'package:zaibal/screens/home_screen.dart';

void main() {
  runApp(const ZaibalApp());
}

class ZaibalApp extends StatelessWidget {
  const ZaibalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zaibal', // Название приложения
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(),
    );
  }
}