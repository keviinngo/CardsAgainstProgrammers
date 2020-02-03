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
  Completer<bool> codeIsValidFuture = Completer<bool>();

  /// The callback that is called when a player joins the game.
  void Function(String) onJoin;
  /// The callback that is called when a player leaves the game.
  void Function(String) onLeft;
  /// The callback that is called when a game is created.
  void Function() onGameCreated;
  /// The callback that is called when you join a game.
  void Function(List<String>) onJoinedGame;

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
      codeIsValidFuture.complete(json['is_valid']);
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
        if (json['message'] == 'invalid_lobby_code') {
          codeIsValidFuture.complete(false);
          return;
        }

        if (json['message'] != 'joined_game') {
          return;
        }

        codeIsValidFuture.complete(true);

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
          onJoin(json['user']);
        }

        // Left
        if (json['message'] == 'left' && onLeft != null) {
          onLeft(json['user']);
        }

        if (json['message'] == 'kicked' && onKicked != null) {
          onKicked();
        }

        // 
        // TODO: Handle this case.
        break;
    }
  }

  // check for code
  /*Future<bool> codeIsValid(String code) async {
    sendJson({'message': 'code_is_valid', 'code': code});
    codeIsValidFuture = Completer<bool>();

    return codeIsValidFuture.future;
  }*/

  static Future<Connection> createGame(String username) async {
    var socket = await WebSocket.connect("ws://$SERVER_ADDRESS:$SERVER_PORT$SERVER_PATH");


    return Connection(socket, true, username);
  }

  static Future<Connection> joinGame(String username, String code) async {
    var socket = await WebSocket.connect("ws://$SERVER_ADDRESS:$SERVER_PORT$SERVER_PATH");


    return Connection(socket, false, username, code: code);
  }

  static Future<Connection> checkCodeAndJoinGame(String username, String code) async {
    var socket = await WebSocket.connect("ws://$SERVER_ADDRESS:$SERVER_PORT$SERVER_PATH");

    var completer = Completer<Connection>();

    socket.addUtf8Text(utf8.encode('{"message":"code_is_valid","code":"$code"}'));
    socket.listen((data) async {
      var json = jsonDecode(utf8.decode(data));
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