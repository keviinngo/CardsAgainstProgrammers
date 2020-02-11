import 'dart:async';
import 'dart:io';
import 'dart:convert';

const String SERVER_ADDRESS = "10.97.60.108";
const String SERVER_PATH = "/game";
const int SERVER_PORT = 8080;

/// All the possibe states the client can be in.
enum ConnectionState {
  waitingForHello,
  creatingGame,
  inLobby,
  joiningGame,
}

///
/// An object with a connection to the server and all the relevant information for the game
/// 
class Connection {
  final WebSocket socket;
  ConnectionState state = ConnectionState.waitingForHello;
  List<Player> players = List<Player>();
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
  /// The callback is called when a player is kicked.
  void Function() onKicked;

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

    print("${this.username}: ${json.toString()}");

    if (json['message'] == 'bye') {
      socket.close();
      return;
    }

    if (json['message'] == 'code_checked') {
      // Ignore this I guess
      return;
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
        // TODO: Handle this case.

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
        // TODO: Verify code.
        onGameCreated();

        state = ConnectionState.inLobby;
        inLobby = true;
        break;
      case ConnectionState.inLobby:
        // Game starting

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

        // 
        // TODO: Handle this case.
        break;
    }
  }

  /// function to kick specific username
  void kickPlayer (String username) {
    sendJson({"message": "kick_player", "username": username});
  }

  /// Creates a game and returns the new [Connection]
  static Future<Connection> createGame(String username) async {
    var socket = await WebSocket.connect("ws://$SERVER_ADDRESS:$SERVER_PORT$SERVER_PATH");


    return Connection(socket, true, username);
  }

  /// Joings a game and returns the new [Connection]
  static Future<Connection> joinGame(String username, String code) async {
    var socket = await WebSocket.connect("ws://$SERVER_ADDRESS:$SERVER_PORT$SERVER_PATH");


    return Connection(socket, false, username, code: code);
  }

  /// Checks if a code is valid. If it is the [Future<Connection>] yields a [Connection], otherwise it yields null
  static Future<Connection> checkCodeAndJoinGame(String username, String code) async {
    var socket = await WebSocket.connect("ws://$SERVER_ADDRESS:$SERVER_PORT$SERVER_PATH");

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
      print('checkAndJoinGame: check code session failed');
    });
    socket.addUtf8Text(utf8.encode('{"message":"code_is_valid","code":"$code"}'));

    return completer.future;
  }
}

/// Player class.
/// 
/// Contains the [name] and [score] of a player
class Player {
  String name;
  int score;
  
  Player(this.name, this.score);
}