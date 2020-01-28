import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget{
  // The Homepagescreen. The first screen after opening up the app.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Flex(
          direction: Axis.vertical,
          children: <Widget>[
            Spacer(flex: 5),
            titleCard(),
            Spacer(flex: 10),
            joinButton(context),
            Spacer(flex: 5),
            createButton(context),
            Spacer(flex: 50)
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
          // Aspect ratio of the card
          aspectRatio: 1.8 / 1,
          child: FractionallySizedBox(
            widthFactor: 0.9,
            child: Container(
              constraints: BoxConstraints(
                // Max width of the container
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

  Widget joinButton(context) {
    return InkWell(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      onTap: (() {
        Navigator.pushReplacementNamed(context, '/join');
      }),
      child: Ink(
        width: 160,
        height: 90,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, style: BorderStyle.solid, width: 0.5),
          borderRadius: BorderRadius.all(Radius.circular(10))
        ),
        child: Center(
          child: Text(
            'Join',
            textAlign: TextAlign.center,
          ),
        )
      )
    );
  }

  Widget createButton(context) {
    return InkWell(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      onTap: (() {
        Navigator.pushReplacementNamed(context, '/create');
      }),
      child: Ink(
        width: 160,
        height: 90,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, style: BorderStyle.solid, width: 0.5),
          borderRadius: BorderRadius.all(Radius.circular(10))
        ),
        child: Center(
          child: Text(
            'Create',
            textAlign: TextAlign.center,
          ),
        )
      )
    );
  }
}