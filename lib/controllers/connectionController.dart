import 'dart:io';
import 'dart:convert';

const String SERVER_ADDRESS = "192.168.10.186";
const String SERVER_PATH = "/game";
const int SERVER_PORT = 8080;

enum ConnectionState {
  waitingForHello,
  creatingGame,
  inLobby,
  joiningGame,
}

class Connection {
  final WebSocket socket;
  ConnectionState state = ConnectionState.waitingForHello;
  List<Player> players = List<Player>();
  String username;
  String code;
  bool isHost;
  bool inLobby;

  void Function(String) onJoin;
  void Function(String) onLeft;
  void Function() onGameCreated;
  void Function(List<String>) onJoinedGame;

  Connection(this.socket, this.isHost, this.username, {this.code}) {
    socket.listen(onData);
  }

  void sendJson(Object obj) {
    socket.addUtf8Text(utf8.encode(json.encode(obj)));
  }

  void onData(dynamic obj) {
    if (!(obj is String)) {
      socket.close();
    }

    String msg = obj as String;

    Map<String, Object> json;
    try {
      json = jsonDecode(msg);
    } catch(e) {
      sendJson({'message': 'invalid_json'});
      socket.close();
    }

    if (json['message'] == 'bye') {
      socket.close();
    }

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
          onJoin(json['user']);
        }

        // Left
        if (json['message'] == 'left' && onLeft != null) {
          onLeft(json['user']);
        }

        // 
        // TODO: Handle this case.
        break;
    }
  }

  static Future<Connection> createGame(String username) async {
    var socket = await WebSocket.connect("ws://$SERVER_ADDRESS:$SERVER_PORT$SERVER_PATH");


    return Connection(socket, true, username);
  }

  static Future<Connection> joinGame(String username, String code) async {
    var socket = await WebSocket.connect("ws://$SERVER_ADDRESS:$SERVER_PORT$SERVER_PATH");


    return Connection(socket, false, username, code: code);
  }


}

class Player {
  String name;
  int score;
  
  Player(this.name, this.score);
}