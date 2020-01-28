import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget{
  // The Homepagescreen. The first screen after opening up the app.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            titleCard()
          ],
        )
      ),
    );
  }

  Widget titleCard() {
    return (
      SafeArea(
        child: AspectRatio(
          aspectRatio: 1.8 / 1,
          child: FractionallySizedBox(
            widthFactor: 0.9,
            child: Container(
              constraints: BoxConstraints(maxWidth: 500),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Center(
                child: Text(
                  'Cards Against Programmers\nI want to _____ a game.',
                  style: TextStyle(color: Colors.white, fontSize: 26), textAlign: TextAlign.center,
                ),
              )
            )
          )
        ),
      )
    );
  }
}