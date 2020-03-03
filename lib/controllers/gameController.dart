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
  void Function() updateState;
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
  /// True until we have a received cards for the first time
  bool connecting = true;

  //TODO: Cancel game when there is less than 3 players left
  //TODO: Show snackbar when someone is kicked

  //TODO: +Server, How do we handle disconnects mid-round?
  //               Likewise, how do we handle new czar mid-round?

  GameController(this.connection, this.updateState, this.userName, this.isHost) {
    connection.onSubmittedCards = (cards) {
      state = GameState.wait_for_czar_pick;
      submittedCards = cards;
      updateState();
    };

    connection.onWinner = (winner) {
      showCards = false;
      state = GameState.annoucing_winner;
      winnerUsername = winner;
      Future.delayed(Duration(seconds: 4), () {
        state = GameState.submit_cards;
        showCards = true;
        updateState();
      });
    };

    connection.onNewHand = (newCards) {
      showCards = true;
      connecting = false;
      hand = newCards;
      updateState();
    };

    connection.onNewCzar = (czar) {
      this.currentCzar = czar;
      if (czar == userName) {
        // TODO: Implement this.
        isCzar = true;
      } else {
        isCzar = false;
      }
      updateState();
    };

    connection.onNewScores = (scores) {
      players.clear();

      scores.forEach((player, score) {
        players.add(Player(player, score));
      });
      updateState();
    };
    
    connection.onJoin = (name) {
      this.players.add(Player(name, 0));
      updateState();
    };

    connection.onLeft = (name) {
      this.players.removeWhere((p) {
        return p.name == name;
      });
      updateState();
    };

    // Sets up all the new methods before sending ready signal
    connection.sendJson({"message": "ready_to_start"});

    state = GameState.submit_cards;
  }

  void submitCard(int index) {
      connection.sendJson({'message': 'submit_card', 'cards': [hand[index]['text']]});

      state = GameState.wait_for_others_to_submit;
      updateState();
  }
}