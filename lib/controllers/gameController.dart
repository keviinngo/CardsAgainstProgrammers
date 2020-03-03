import 'package:flutter/material.dart';

import "connectionController.dart";

enum GameState {
  submit_cards,
  wait_for_others_to_submit,
  wait_for_czar_pick,
  annoucing_winner,
}

class Player {
  String name;
  int score;

  Player(this.name, this.score);
}

class GameController {
  /// [State] controlled by this class
  State screen;
  /// Active [Connection] for this controller
  Connection connection;
  /// Current cards
  List<dynamic> hand = [];
  /// Current [GameState]
  GameState state;
  /// Submitted cards
  List<dynamic> submittedCards = [];
  /// Notifies the controlled screen to update
  void Function() setState;
  /// Most recent winner
  String winnerUsername;
  /// All players in the game
  List<Player> players = [];
  /// Current czar
  String currentCzar;
  /// Name of the local user
  String userName;
  /// If the local player is czar
  bool isCzar;
  /// Signigies if cards are loaded
  bool showCards;
  /// True if the local user is host
  bool isHost;

  GameController(this.connection, this.setState, this.userName, this.isHost) {
    connection.onSubmittedCards = (cards) {
      state = GameState.wait_for_czar_pick;
      submittedCards = cards;
      setState();
    };

    connection.onWinner = (winner) {
      state = GameState.annoucing_winner;
      winnerUsername = winner;
      Future.delayed(Duration(seconds: 4), () {
        state = GameState.submit_cards;
        setState();
      });
    };

    connection.onNewHand = (newCards) {
      showCards = true;
      hand = newCards;
      setState();
    };

    connection.onNewCzar = (czar) {
      this.currentCzar = czar;
      if (czar == userName) {
        // TODO: Implement this.
        isCzar = true;
      } else {
        isCzar = false;
      }
      setState();
    };

    connection.onNewScores = (scores) {
      players.clear();
      print(scores);

      scores.forEach((player, score) {
        print(player + " " + score.toString());
        players.add(Player(player, score));
      });
      setState();
    };
    
    connection.onJoin = (name) {
      this.players.add(Player(name, 0));
      setState();
    };

    connection.onLeft = (name) {
      this.players.removeWhere((p) {
        return p.name == name;
      });
      setState();
    };

    // Sets up all the new methods before sending ready signal
    connection.sendJson({"message": "ready_to_start"});

    state = GameState.submit_cards;
  }

  void submitCard(BuildContext context, int index) {
      connection.sendJson({'message': 'submit_card', 'cards': [hand[index]['text']]});

      state = GameState.wait_for_others_to_submit;
      setState();
  }
}