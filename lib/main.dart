import 'package:cap/screens/join.dart';
import 'package:cap/screens/lobby.dart';
import 'package:flutter/material.dart';
import 'package:cap/screens/home.dart';
import 'package:cap/screens/create.dart';

// Runs MyApp.
void main() => runApp(RootScreen());

/// Main entrypoint. 
class RootScreen extends StatelessWidget {
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
        '/': (context) => HomeScreen(),
        '/join': (context) => JoinScreen(),
        '/create': (context) => CreateScreen(),
        '/lobby': (context) => LobbyScreen(arguments: ModalRoute.of(context).settings.arguments as Map<String, dynamic>),
      },
      theme: ThemeData(
        primaryColor: Colors.black,
      )
      /*ThemeData(
        backgroundColor: Colors.white
        
      )*/
    );
  }
}
