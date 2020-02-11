import 'package:cap/controllers/connectionController.dart';
import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  final Map<String, dynamic> arguments;

  GameScreen({@required this.arguments});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>{
  List<Map<String, dynamic>> cards;

  List<Player> players = List<Player>();
  String userName;
  bool isHost;
  Future<Connection> conn;

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
        cards = newCards;
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Text('I am player $userName')
        ),
      ),
    );
  }
}