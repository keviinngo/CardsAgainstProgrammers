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
    /// Black titlecard with the text: Cards Against Programmers \n I want to _____ a game.
    return (
      SafeArea(
        // Will not draw out on top of notch.
        child: AspectRatio(
          // Aspect ratio of the card.
          aspectRatio: 1.8 / 1,
          child: FractionallySizedBox(
            widthFactor: 0.9,
            child: Container(
              constraints: BoxConstraints(
                //Max width of card.
                maxWidth: 500
              ),
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