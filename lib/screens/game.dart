import 'dart:math';

import 'package:cap/controllers/connectionController.dart';
import 'package:cap/controllers/gameController.dart';
import 'package:flutter/material.dart';


class GameScreen extends StatefulWidget {
  /// Arguments from the previous screen
  final Map<String, dynamic> arguments;

  GameScreen({@required this.arguments});

  @override
  State<GameScreen> createState() => GameScreenState();
}

class GameScreenState extends State<GameScreen>{
  GameController controller;
  Connection connection;
  BuildContext scaffoldContext;
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  /// Called when the Lobby widget is removed, close any remaining connections.
  void dispose() {
    super.dispose();

    connection.sendJson({'message': 'leave_game'});
    connection.socket.close();
  }

  void updateState() {
    for (String msg in controller.snackMessages) {
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(msg),
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ));
    }
    controller.snackMessages.clear();

    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    // Gets necessary data from previous screen
    String userName = widget.arguments['userName'];
    bool isHost = widget.arguments['isHost'];
    connection = widget.arguments['conn'];
    List<Player> players = [];
    for (String playerName in widget.arguments['players']) {
      players.add(Player(playerName, 0));
    }

    controller = GameController(connection, updateState, userName, isHost, );
  }

  void pickWinner(int index) {
    connection.sendJson({'message': 'picked_winner', 'winner': controller.submittedCards[index]['id']});
  }

  Widget buildSingleCzarCard(BuildContext context, int index, String text) {
    return Container(
      width: 200,
      margin: EdgeInsets.fromLTRB(8, 0, 8, 5),
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.circular(8),
        //color: Colors.white
      ),
      child: InkWell(
        onTap: 
          controller.state == GameState.wait_for_czar_pick && controller.currentCzar == controller.userName
            ? () => pickWinner(index)
            : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          margin: EdgeInsets.all(8 ),
          decoration: BoxDecoration(
          ),
          child: Text(
            text,
            softWrap: true,
            style: TextStyle(
              fontWeight: FontWeight.bold
            ),
          ),
        ),
      )
    );
  }

  Widget buildCzarCard(BuildContext context, int index) {
    List<Widget> cards = [];
    for (var card in controller.submittedCards[index]['cards']) {
      cards.add(buildSingleCzarCard(context, index, card));
    }

    return Container(
      width: 200,
      margin: EdgeInsets.fromLTRB(8, 0, 8, 5),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: cards,
      ),
    );
  }

  Widget buildCzarHand() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.2,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return buildCzarCard(context, index);
        },
        itemCount: controller.submittedCards.length,
      ),
    );
  }

  Widget buildHand({bool shade = false}) {
    final main = Column(
      children: <Widget>[
        Divider(),
        Container(
          height: MediaQuery.of(context).size.height * 0.2,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return buildCard(context, index);
            },
            itemCount: controller.hand.length,
          ),
        )
      ],
    );
    return controller.showCards
      ? (!shade
        ? main
        : Container(
          decoration: BoxDecoration(
            color: Colors.black38.withAlpha(128)
          ),
          child: main,  
        ))
      : (controller.connecting
        ? CircularProgressIndicator(value: null,)
        : Container());
  }

  Widget buildCallingCard(String text) {
    return Container(
      width: min(MediaQuery.of(context).size.width, 500),
      height: MediaQuery.of(context).size.height * 0.4,
      margin: EdgeInsets.fromLTRB(8, 0, 8, 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).primaryColor,
      ),
      child: Container(
        margin: EdgeInsets.all(32),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 27,
            fontWeight: FontWeight.bold,
          )
        ),
      ),
    );
  }

  Widget buildStatus() {
    switch(controller.state) {
      case GameState.submit_cards:
        if (controller.currentCzar == controller.userName) {
          return Text('You are the card czar');
        } else {
          return Text('Pick a card');
        }
        break;
      case GameState.wait_for_others_to_submit:
        return Text('Waiting for everyone else');
        break;
      case GameState.wait_for_czar_pick:
        if (controller.currentCzar == controller.userName) {
          return Text('Pick the card you like the most');
        } else {
          return Text('The card czar is picking a card');
        }
        break;
      case GameState.annoucing_winner:
        return Text('The winner is ' + controller.winnerUsername);
        break;
    }  

    return Container();
  }

  Widget buildScoreboard() {
    var rows = <TableRow>[];

    //TODO: Make it possible for the host to kick users here
    for (var player in controller.players) {
      var prefix = "";

      if (controller.isHost && controller.userName == player.name) {
        prefix += "🔨";
      }
      if (controller.currentCzar == player.name) {
        prefix += "👑";
      }

      if (prefix != "") {
        prefix += " ";
      }

      rows.add(
        TableRow(
          children: [
            Center(child: Text(prefix + player.name)),
            Center(child: Text(player.score.toString())),
          ],
        )
      );
    }
    
    return Container(
      child: Column(
        children: <Widget>[
          Text("Players"),
          Divider(),
          Table(
            children: rows,
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scoreboard = buildScoreboard();
    final hand = buildHand(shade: controller.userName == controller.currentCzar);
    final callingCard = buildCallingCard(controller.callCardText);

    return WillPopScope(
      onWillPop: () async { return false; },
      child: Scaffold(
        key: scaffoldKey,
        drawer: Drawer(
          child: SafeArea(
            child: Container(
              child: Column(
                children: <Widget>[
                  scoreboard
                ],
              ),
            )
          )
        ),
        body: Center(
          // SafeArea to nok draw under notch
          child: SafeArea(
            child: Flex(
              direction: Axis.vertical,
              children: <Widget>[
                Padding(padding: EdgeInsets.only(top: 16)),
                callingCard,
                buildStatus(),
                Spacer(),
                controller.state == GameState.wait_for_czar_pick
                  ? buildCzarHand()
                  : hand
              ],
            )
          )
        )
      ),
    );
  }

  // The list of cards to be shown
  Widget buildCard(BuildContext context, int index) {
    return Container(
      width: 200,
      margin: EdgeInsets.fromLTRB(8, 0, 8, 5),
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.circular(8),
        //color: Colors.white
      ),
      child: InkWell(
        onTap: 
          controller.state == GameState.submit_cards && controller.currentCzar != controller.userName
            ? () => controller.submitCard(index)
            : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          margin: EdgeInsets.all(8 ),
          decoration: BoxDecoration(
          ),
          child: Text(
            controller.hand[index].values.toList()[0],
            softWrap: true,
            style: TextStyle(
              fontWeight: FontWeight.bold
            ),
          ),
        ),
      )
    );
  }
}