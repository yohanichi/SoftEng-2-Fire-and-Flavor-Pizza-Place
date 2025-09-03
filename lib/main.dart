import 'package:flutter/material.dart';
import 'dash.dart'; // ✅ Import your dash.dart

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fire and Flavor Pizza Place',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: dash(), // ✅ Set dash.dart as the homepage
      debugShowCheckedModeBanner: false,
    );
  }
}
