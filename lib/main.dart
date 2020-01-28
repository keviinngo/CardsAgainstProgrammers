import 'package:cap/screens/join.dart';
import 'package:flutter/material.dart';
import 'package:cap/screens/home.dart';

// Runs MyApp.
void main() => runApp(MyApp());

/// Main entrypoint. 
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cards Against Programmers',
      initialRoute: '/',
      routes: {
        // When navigating to the "/" route, build the HomePage widget.
        // 
        // List of all routes in the application.
        '/': (context) => HomePage(),
        '/join': (context) => JoinScreen(),
      },
      theme: ThemeData(
        backgroundColor: Colors.white
      )
    );
  }
}
