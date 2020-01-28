import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget{
  // The Homepagescreen. The first screen after opening up the app.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            titleCard(),
            joinButton()
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

  Widget joinButton() {
    return(
      Container(
        margin: EdgeInsets.all(12),
        height: 50,
        width: 100,
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            color: Colors.black, blurRadius: 4, offset: Offset(0, 2)
          ),
        ]),
        child: Material(
          color: Colors.black,
          child: InkWell(
              onTap: () {},
            child: Center(
             child: Text("Test",
              style: TextStyle(color: Colors.white),
              ),
            )
          )
        )
      )
    );
  }
}