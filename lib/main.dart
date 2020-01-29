import 'package:cap/screens/join.dart';
import 'package:cap/screens/lobby.dart';
import 'package:flutter/material.dart';
import 'package:cap/screens/home.dart';
import 'package:cap/screens/create.dart';

// Runs MyApp.
void main() => runApp(RootScreen());

/// Main entrypoint. 
class RootScreen extends StatelessWidget {
  MaterialColor customColor = MaterialColor(0xFFC5133D, color);
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
  50:Color.fromRGBO(197, 19, 61, .1),
  100:Color.fromRGBO(197, 19, 61, .2),
  200:Color.fromRGBO(197, 19, 61, .3),
  300:Color.fromRGBO(197, 19, 61, .4),
  400:Color.fromRGBO(197, 19, 61, .5),
  500:Color.fromRGBO(197, 19, 61, .6),
  600:Color.fromRGBO(197, 19, 61, .7),
  700:Color.fromRGBO(197, 19, 61, .8),
  800:Color.fromRGBO(197, 19, 61, .9),
  900:Color.fromRGBO(197, 19, 61, 1),
};