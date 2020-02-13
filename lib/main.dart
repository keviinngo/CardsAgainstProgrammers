import 'package:cap/screens/join.dart';
import 'package:cap/screens/lobby.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cap/screens/home.dart';
import 'package:cap/screens/create.dart';
import 'package:cap/screens/game.dart';

// Runs MyApp.
void main() => runApp(RootScreen());

/// Main entrypoint. 
class RootScreen extends StatelessWidget {
  final MaterialColor customColor = MaterialColor(0xffc5133d, color);


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cards Against Programmers',
      //initialRoute: '/',
      onGenerateRoute: (RouteSettings settings) {
        switch(settings.name) {
        case '/':
          return CupertinoPageRoute(builder: (_) {
            return HomeScreen();
          });
          break;
        case '/join':
          return CupertinoPageRoute(builder: (_) {
            return JoinScreen();
          });
          break;
        case '/create':
          return CupertinoPageRoute(builder: (_) {
            return CreateScreen();
          });
          break;
        case '/lobby':
          return MaterialPageRoute(builder: (_) {
            return LobbyScreen(arguments: settings.arguments as Map<String, dynamic>);
          });
          break;
          case '/game':
          return MaterialPageRoute(builder:  (_) {
            return GameScreen(arguments: settings.arguments as Map<String, dynamic>);
          });
          break;
        }
        
      },
      theme: ThemeData(
        primarySwatch: customColor,
        scaffoldBackgroundColor: Color(0xfffafafa),
      )
    );
  }
}

// Custom material color.
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