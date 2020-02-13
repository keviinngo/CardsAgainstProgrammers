import 'package:cap/screens/join.dart';
import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

class HomeScreen extends StatelessWidget{
  static const navigateToJoinKey = Key('navigateToJoin');
  static const navigateToCreateKey = Key('navigateToCreate');

  // The Homepagescreen. The first screen after opening up the app.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Flex(
          direction: Axis.vertical,
          children: <Widget>[
            Spacer(flex: 5),
            FadeIn(1.0, titleCard(context)),
            Spacer(flex: 10),
            FadeIn(2.33, joinButton(context)),
            Spacer(flex: 5),
            FadeIn(2.66, createButton(context)),
            Spacer(flex: 50)
          ],
        )
      ),
    );
  }

  /// Red titlecard with the text: Cards Against Programmers \n I want to _____ a game.
  Widget titleCard(context) {
    return (
      SafeArea(
        // Will not draw out on top of notch.
        child: Container(
          constraints: BoxConstraints(maxWidth: 500),
          child: AspectRatio(
          // Aspect ratio of the card
            aspectRatio: 1.8 / 1,
            child: FractionallySizedBox(
              heightFactor: 0.8,
              widthFactor: 0.9,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Center(
                  child: Text(
                    'Cards Against Programmers\nI want to _____ a game.',
                    style: TextStyle(color: Colors.white, fontSize: 27, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                )
              )
            )
          ),
        )
      )
    );
  }

  // TODO: Aspect ratio

  /// [InkWell] button that sends you to the join screen
  Widget joinButton(context) {
    return InkWell(
      key: navigateToJoinKey,
      borderRadius: BorderRadius.all(Radius.circular(10)),
      onTap: (() {
        Navigator.of(context).pushNamed('/join');
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
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
        )
      )
    );
  }

  /// [InkWell] button that sends you to the create screen
  Widget createButton(context) {
    return InkWell(
      key: navigateToCreateKey,
      borderRadius: BorderRadius.all(Radius.circular(10)),
      onTap: (() {
        Navigator.of(context).pushNamed('/create');
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
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
        )
      )
    );
  }
}

//A fade-in animation for the UI
class FadeIn extends StatelessWidget {
  final double delay;
  final Widget child;

  FadeIn(this.delay, this.child);

  @override
  Widget build(BuildContext context) {
    //Tweens multiple properties at once
    final tween = MultiTrackTween([
      //Setting opacity from invisible to fully visible
      Track("opacity")
        .add(Duration(milliseconds: 500), Tween(begin: 0.0, end: 1.0)),
      //Translate on the x-axis from displaced to unmodified
      Track("transelateX").add(
        Duration(milliseconds: 500), Tween(begin: 600.0, end: 0.0),
        curve: Curves.easeOut)
    ]);

    return ControlledAnimation(
      delay: Duration(milliseconds: (300 * delay).round()),
      duration: tween.duration,
      tween: tween,
      child: child,
      //building the animated scene
      builderWithChild: (context, child, animation) => Opacity(
        opacity: animation["opacity"],
        child: Transform.translate(
          offset: Offset(animation["transelateX"], 0), child: child),
      ),
    );
  }
}