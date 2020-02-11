import 'package:flutter/material.dart';

class GameScreen extends StatelessWidget {
  final Map<String, dynamic> arguments;

  GameScreen({@required this.arguments});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Text('skjer')
        ),
      ),
    );
  }
}