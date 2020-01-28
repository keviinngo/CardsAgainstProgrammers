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
          aspectRatio: 88 / 63,
          child: FractionallySizedBox(
            widthFactor: 0.8,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            )
          )
        ),
      )
    );
  }
}