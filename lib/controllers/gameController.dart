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
  /// Signigies if cards are to be shown
  bool showCards = true;
  /// True if the local user is host
  bool isHost;
  /// True until we have a received cards for the first time
  bool connecting = true;
  /// List of snackbar messages to be displayed by the GameScreen
  List<String> snackMessages = [];
  /// Text for the active callCard
  String callCardText = "";
  /// Number of blanks in the current call card
  int callCardlBlanks = 0;
  /// Number of cards currently submitted, flushed when it reaches cardsToSubmit.length == callCardBlanks.
  List<dynamic> cardsToSubmit = [];

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
      connecting = false;
      hand = newCards;
      updateState();
    };

    connection.onNewCzar = (czar) {
      this.currentCzar = czar;
      if (czar == userName) {
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

    connection.onNewCallCard = (text, blanks) {
      callCardText = text;
      callCardlBlanks = blanks;
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
      snackMessages.add(name + " left the game");
      updateState();
    };

    // Sets up all the new methods before sending ready signal
    connection.sendJson({"message": "ready_to_start"});

    state = GameState.submit_cards;
  }

  void submitCard(int index) {
      cardsToSubmit.add(hand[index]['id']);

      if (cardsToSubmit.length == callCardlBlanks) {
        connection.sendJson({'message': 'submit_card', 'cards': cardsToSubmit});

        state = GameState.wait_for_others_to_submit;
        cardsToSubmit.clear();
      }

      updateState();
  }
}