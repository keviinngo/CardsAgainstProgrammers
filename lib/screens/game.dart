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

    // Gets necessary data from previous screen
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

      // Sets up all the new methods before sending ready signal
      connection.sendJson({"message": "ready_to_start"});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SafeArea(
          child: Flex(
            direction: Axis.vertical,
            children: <Widget>[
              Container(
                child: Text('skjer', textAlign: TextAlign.center,),
              ),
              Spacer(),
              showCards ? Container(
                height: MediaQuery.of(context).size.height * 0.2,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return buildList(context, index);
                  },
                  itemCount: cards.length,
                ),
              ) : CircularProgressIndicator(value: null,)
            ],
          )
        )
      )
    );
  }

  // The list of cards to be shown
  Widget buildList(BuildContext context, int index) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.2,
      margin: EdgeInsets.fromLTRB(8, 0, 8, 5),
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white
      ),
      child: Container(
        margin: EdgeInsets.all(2),
        child: Text(cards[index].values.toList()[0]),
      ),
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