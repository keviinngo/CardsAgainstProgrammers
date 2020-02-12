import 'package:cap/controllers/connectionController.dart';
import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  final Map<String, dynamic> arguments;

  GameScreen({@required this.arguments});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>{
  List<dynamic> cards;

  List<Player> players = List<Player>();
  String userName;
  bool isHost;
  Future<Connection> conn;
  bool isCzar;
  bool showCards = false;

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

    userName = widget.arguments['userName'];
    isHost = widget.arguments['isHost'];
    conn = widget.arguments['conn'];
    for (String playerName in widget.arguments['players']) {
      players.add(Player(playerName, 0));
    }

    conn.then((connection) {
      connection.onNewHand = (newCards) {
        setState(() {
          showCards = true;
          cards = newCards;
        });
      };

      connection.onNewCzar = (czar) {
        if (czar == userName) {
          // TODO: Implement this.
          isCzar = true;
        } else {
          isCzar = false;
        }
      };

      connection.onNewScores = (scores) {
        setState(() {
          players.clear();

          scores.forEach((player, score) {
            players.add(Player(player, score));
          });
        });
      };

      connection.sendJson({"message": "ready_to_start"});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: showCards ? ListView.builder(
          itemCount: cards.length,
          itemBuilder: (BuildContext context, int index) {
            return buildList(index);
          } 
        ) : Container(),
      ),
    );
  }

  Widget buildList(int index) {
    return Row(
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
    );
  }
}