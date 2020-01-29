import 'package:cap/screens/join.dart';
import 'package:cap/screens/lobby.dart';
import 'package:flutter/material.dart';
import 'package:cap/screens/home.dart';
import 'package:cap/screens/create.dart';

// Runs MyApp.
void main() => runApp(RootScreen());

/// Main entrypoint. 
class RootScreen extends StatelessWidget {
  final MaterialColor customColor = MaterialColor(0xffc5133d, color);
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
        primarySwatch: customColor
      )
      /*ThemeData(
        backgroundColor: Colors.white
        
      )*/
    );
  }
}

const Map<int, Color> color = {
  50:Color(0xffef5d7f),
  100:Color(0xffed456c),
  200:Color(0xffea2e5a),
  300:Color(0xffe81748),
  400:Color(0xffd11541),
  500:Color(0xffc5133d),
  600:Color(0xffba1239),
  700:Color(0xffa21032),
  800:Color(0xff8b0e2b),
  900:Color(0xff740b24)
};