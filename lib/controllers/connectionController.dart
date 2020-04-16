import 'dart:async';
import 'dart:io';
import 'dart:convert';

const String SERVER_PROTOCOL = "wss://";
const String SERVER_ADDRESS = "cap.thebirk.net";
const String SERVER_PATH = "/game";
const int SERVER_PORT = 443;

/// All the possibe states the client can be in.
enum ConnectionState {
  waitingForHello,
  creatingGame,
  inLobby,
  joiningGame,
  inGame
}

///
/// An object with a connection to the server and all the relevant information for the game
/// 
class Connection {
  final WebSocket socket;
  ConnectionState state = ConnectionState.waitingForHello;
  List<dynamic> cards = List<dynamic>();
  String username;
  String code;
  bool isHost;
  bool inLobby;
  bool isValidCode;

  /// The callback that is called when a player joins the game.
  void Function(String) onJoin;
  /// The callback that is called when a player leaves the game.
  void Function(String) onLeft;
  /// The callback that is called when a game is created.
  void Function() onGameCreated;
  /// The callback that is called when you join a game.
  void Function(List<String>) onJoinedGame;
  /// The callback that is called when a player is kicked.
  void Function() onKicked;
  /// The callback that is called when the player gets a new hand of cards.
  void Function(List<dynamic>) onNewHand;
  /// The callback that is called when the game is starting.
  void Function() onStarted;
  /// The callback that is called when a new czard i chosen.
  void Function(String) onNewCzar;
  /// The callback that is called when new scores are set.
  void Function(Map<String, dynamic>) onNewScores;
  /// The callback is called when the player is promoted to host
  void Function() onPromoted;
  /// The callback is called when all players have submitted cards
  void Function(List<dynamic>) onSubmittedCards;
  /// The callback is called when a winner is picked
  void Function(String) onWinner;
  /// The callback is called when a new call card is sent
  void Function(String, int) onNewCallCard;
  /// Called when we receiece an "invalid_deck_id" message
  void Function() onInvalidDeckId;

  /// Connection constructor.
  /// 
  /// Takes in arguments [socket], [isHost] and [username].
  ///
  /// named argument [code]
  Connection(this.socket, this.isHost, this.username, {this.code, this.isValidCode}) {
    socket.listen(onData);
  }

  /// Sends an json object to the server.
  void sendJson(Object obj) {
    socket.addUtf8Text(utf8.encode(json.encode(obj)));
  }

  /// Callback that is called when data is recieved from the server.
  void onData(dynamic obj) {
    if (!(obj is String)) {
      socket.close();
      return;
    }

    String msg = obj as String;

    Map<String, Object> json;
    try {
      json = jsonDecode(msg);
    } catch(e) {
      sendJson({'message': 'invalid_json'});
      socket.close();
      return;
    }

    print(json);

    if (json['message'] == 'bye') {
      socket.close();
      return;
    }

    if (json['message'] == 'code_checked') {
      // Ignore this I guess
      return;
    }

    //TODO: This can get lost when tranistioning from Lobby to Game
    // Joined
    if (json['message'] == 'joined' && onJoin != null) {
      onJoin(json['username']);
    }

    // Left
    if (json['message'] == 'left' && onLeft != null) {
      onLeft(json['username']);
    }

    //Kicked
    if (json['message'] == 'kicked' && onKicked != null) {
      onKicked();
    }

    // Swtich case for each of the possible states of the game.
    switch (state) {
      case ConnectionState.waitingForHello:
        if (json['message'] != 'hello') {
          return;
        }

        if (isHost) {
          sendJson({'message': 'create_game', 'username': '$username'});
          state = ConnectionState.creatingGame;
        } else {
          sendJson({'message': 'join_game', 'code': '$code', 'username': '$username'});
          state = ConnectionState.joiningGame;
        }
        break;
      case ConnectionState.joiningGame:
        if (json['message'] != 'joined_game') {
          return;
        }

        // json['users']
        if (onJoinedGame != null) {
          List<String> users = [];
          for(dynamic user in json['users']) {
            users.add(user as String);
          }
          onJoinedGame(users);
        }

        state = ConnectionState.inLobby;
        inLobby = true;
        break;
      case ConnectionState.creatingGame:
        if (json['message'] != 'created_game') {
          return;
        }

        code = json['code'];
        // TODO: Verify code. Why? We trust the server dont we?
        onGameCreated();

        state = ConnectionState.inLobby;
        inLobby = true;
        break;
      case ConnectionState.inLobby:
        // Game starting
        if (json['message'] == 'game_starting' && onStarted != null) {
          onStarted();
          state = ConnectionState.inGame;
        }
        // Promoted to host by server
        if(json['message'] == 'promoted_to_host' && onPromoted != null) {
          onPromoted();
        }

        if(json['message'] == 'invalid_deck_id' && onInvalidDeckId != null) {
          onInvalidDeckId();
        }

        break;
      case ConnectionState.inGame:

        // Getting a new hand
        if (json['message'] == 'new_hand' && onNewHand != null) {
          cards = json['hand'] as List<dynamic>;
          onNewHand(cards);
        }

        // New card czar
        if (json['message'] == 'new_czar' && onNewCzar != null) {
          onNewCzar(json['username']);
        }

        if (json['message'] == 'new_call' && onNewCallCard != null) {
          onNewCallCard(json['text'], json['blanks']);
        }

        // New scores are set
        if (json['message'] == 'new_score' && onNewScores != null) {
          onNewScores(json['scores']);
        }

        if (json['message'] == 'submitted_cards' && onSubmittedCards != null) {
          onSubmittedCards(json['users']);
        }

        if (json['message'] == 'winner_announce' && onWinner != null) {
          onWinner(json['winner']);
        }

        break;
    }
  }

  /// function to kick specific username
  void kickPlayer (String username) {
    sendJson({"message": "kick_player", "username": username});
  }

  /// Creates a game and returns the new [Connection]
  static Future<Connection> createGame(String username) async {
    try {
      var socket = await WebSocket.connect("$SERVER_PROTOCOL$SERVER_ADDRESS:$SERVER_PORT$SERVER_PATH").timeout(Duration(seconds: 10));
      return Connection(socket, true, username);
    } catch(e) {
      return null;
    }
  }

  /// Joings a game and returns the new [Connection]
  static Future<Connection> joinGame(String username, String code) async {
    try {
      var socket = await WebSocket.connect("$SERVER_PROTOCOL$SERVER_ADDRESS:$SERVER_PORT$SERVER_PATH").timeout(Duration(seconds: 10));
      return Connection(socket, false, username, code: code);
    } catch(e) {
      return null;
    }
  }

  /// Checks if a code is valid. If it is the [Future<Connection>] yields a [Connection], otherwise it yields null
  static Future<Connection> checkCodeAndJoinGame(String username, String code) async {
    try {
      var socket = await WebSocket.connect("$SERVER_PROTOCOL$SERVER_ADDRESS:$SERVER_PORT$SERVER_PATH").timeout(Duration(seconds: 10));
      var completer = Completer<Connection>();

      socket.listen((data) async {
        var json = jsonDecode(data);
        print(json);

        if (json['message'] == 'code_checked') {
          if (json['is_valid']) {
            completer.complete(joinGame(username, code));
          } else {
            completer.complete(null);
          }
          socket.close();
        }
      }, onDone: () {
        if (!completer.isCompleted) {
          completer.complete(null);
        }
      });
      socket.addUtf8Text(utf8.encode('{"message":"code_is_valid","code":"$code"}'));

      return completer.future;
    } catch(e) {
      return null;
    }
  }
}