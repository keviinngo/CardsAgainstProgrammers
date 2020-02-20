import 'dart:math';

import 'package:cap/controllers/connectionController.dart';
import 'package:flutter/material.dart';

enum GameState {
  submit_cards,
  wait_for_others_to_submit,
  wait_for_czar_pick,
  annoucing_winner,
}

class GameScreen extends StatefulWidget {
  /// Arguments from the previous screen
  final Map<String, dynamic> arguments;

  GameScreen({@required this.arguments});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>{
  /// A list of cards the player has
  List<dynamic> cards;
  /// A list of submitted cards
  List<dynamic> submittedCards;
  /// List of players with their name and score
  List<Player> players = List<Player>();
  /// Player's name
  String userName;
  /// Indicates if the player is a host or not
  bool isHost;
  /// The connection to the server
  Future<Connection> conn;
  /// Indicates if the player is the Czar or not
  bool isCzar;
  /// Indicates if we should draw the cards on screen or not
  bool showCards = false;
  /// Indicates the current state of the game
  GameState state = GameState.submit_cards;
  /// Name of the current czar
  String currentCzar;
  /// Name of the user that won the current round
  String winnerUsername;

  @override
  /// Called when the Lobby widget is removed, close any remaining connections.
  void dispose() {
    super.dispose();
 

    conn.then((connection) {
      connection.sendJson({'message': 'leave_game'});
      connection.socket.close();
    });
  }

  @override
  void initState() {
    super.initState();

    // Gets necessary data from previous screen
    userName = widget.arguments['userName'];
    isHost = widget.arguments['isHost'];
    conn = widget.arguments['conn'];
    for (String playerName in widget.arguments['players']) {
      players.add(Player(playerName, 0));
    }

    conn.then((connection) {
      connection.onSubmittedCards = (cards) {
        setState(() {
          state = GameState.wait_for_czar_pick;
          submittedCards = cards;
        });
      };

      connection.onWinner = (winner) {
        setState(() {
          state = GameState.annoucing_winner;
          winnerUsername = winner;

        });
        Future.delayed(Duration(seconds: 4), () {
          setState(() {
            state = GameState.submit_cards;
          });
        });
      };

      connection.onNewHand = (newCards) {
        setState(() {
          showCards = true;
          cards = newCards;
        });
      };

      connection.onNewCzar = (czar) {
        setState(() {
          this.currentCzar = czar;
          if (czar == userName) {
            // TODO: Implement this.
            isCzar = true;
          } else {
            isCzar = false;
          }
        });
      };

      connection.onNewScores = (scores) {
        setState(() {
          players.clear();

          scores.forEach((player, score) {
            players.add(Player(player, score));
          });
        });
      };
      
      connection.onJoin = (name) {
        setState(() {
          this.players.add(Player(name, 0));
        });
      };

      connection.onLeft = (name) {
        setState(() {
          this.players.removeWhere((p) {
            return p.name == name;
          });
        });
      };

      // Sets up all the new methods before sending ready signal
      connection.sendJson({"message": "ready_to_start"});

      state = GameState.submit_cards;
    });
  }

  Widget buildCard({@required String text, @required Color color, @required Color textColor}) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.4,
      margin: EdgeInsets.fromLTRB(8, 0, 8, 5),
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.circular(8),
        color: color,
      ),
      child: RawMaterialButton(
        onPressed: () {
          print("buttons!!");
        },
        child: Container(
          margin: EdgeInsets.all(2),
          child: Text(
            text,
            style: TextStyle(color: textColor)
          ),
        ),
      )
    );
  }

  Widget buildScoreboard() {
    var rows = <TableRow>[];

    //TODO: Make it possible for the host to kick users here
    for (var player in players) {
      var prefix = "";

      if (isHost && userName == player.name) {
        prefix += "🔨";
      }
      if (currentCzar == player.name) {
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

  void pickWinner(int index) {
    conn.then((c) {
      c.sendJson({'message': 'picked_winner', 'winner': submittedCards[index]['id']});
    });
  }

  Widget buildCzarCard(BuildContext context, int index) {
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
          state == GameState.wait_for_czar_pick && currentCzar == userName
            ? () => pickWinner(index)
            : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          margin: EdgeInsets.all(8 ),
          decoration: BoxDecoration(
          ),
          child: Text(
            submittedCards[index]['text'],
            softWrap: true,
            style: TextStyle(
              fontWeight: FontWeight.bold
            ),
          ),
        ),
      )
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
        itemCount: submittedCards.length,
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
              return buildList(context, index);
            },
            itemCount: cards.length,
          ),
        )
      ],
    );
    return showCards
      ? (!shade
        ? main
        : Container(
          decoration: BoxDecoration(
            color: Colors.black38.withAlpha(128)
          ),
          child: main,  
        ))
      : CircularProgressIndicator(value: null,);
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
    switch(state) {
      case GameState.submit_cards:
        if (this.currentCzar == this.userName) {
          return Text('You are the card czar');
        } else {
          return Text('Pick a card');
        }
        break;
      case GameState.wait_for_others_to_submit:
        return Text('Waiting for everyone else');
        break;
      case GameState.wait_for_czar_pick:
        return Text('The card czar is picking a card');
        break;
      case GameState.annoucing_winner:
        return Text('The winner is ' + winnerUsername);
        break;
    }  

    return Container();
  }

  @override
  Widget build(BuildContext context) {
    final scoreboard = buildScoreboard();
    final hand = buildHand(shade: this.userName == this.currentCzar);
    final callingCard = buildCallingCard("We can discuss ________ at the stand-up meeting.");

    return WillPopScope(
      onWillPop: () async { return false; },
      child: Scaffold(
        drawer: Drawer(
          child: SafeArea(
            child: Container(
              child: Column(
                children: <Widget>[
                  scoreboard,
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
                state == GameState.wait_for_czar_pick
                  ? buildCzarHand()
                  : hand
              ],
            )
          )
        )
      ),
    );
  }

  void submitCard(BuildContext context, int index) {
    conn.then((c) {
      c.sendJson({'message': 'submit_card', 'cards': [this.cards[index]['text']]});

      setState(() {
        state = GameState.wait_for_others_to_submit;
      });
    });
  }

  // The list of cards to be shown
  Widget buildList(BuildContext context, int index) {
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
          state == GameState.submit_cards && currentCzar != userName
            ? () => submitCard(context, index)
            : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          margin: EdgeInsets.all(8 ),
          decoration: BoxDecoration(
          ),
          child: Text(
            cards[index].values.toList()[0],
            softWrap: true,
            style: TextStyle(
              fontWeight: FontWeight.bold
            ),
          ),
        ),
      )
    );

    /*return Row(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: BorderRadius.circular(15),
            color: Colors.white
          ),
          child: Text(cards[index].values.toList()[0]),
        )
      ],
    );*/
  }
}