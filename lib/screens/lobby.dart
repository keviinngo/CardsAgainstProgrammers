import 'package:cap/controllers/connectionController.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Lobby settings.
class LobbySettings {
  int scoreToWin = 5;
  bool check = false;
}

/// Dialog item for [LobbySettingsDialog].
class SettingsDialogItem extends StatelessWidget {
  final Widget left;
  final Widget right;

  SettingsDialogItem({@required this.left, @required this.right});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(15), 
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          left,
          right,
        ]
      )
    );
  }
}

/// Dialog for editing lobby settings.
class LobbySettingsDialog extends StatefulWidget {
  final LobbySettings settings;

  LobbySettingsDialog(this.settings);

  @override
  State<LobbySettingsDialog> createState() => LobbySettingsDialogState();
}


class LobbySettingsDialogState extends State<LobbySettingsDialog> {
  final TextEditingController scoreToWinController = TextEditingController();

  bool check;
  LobbySettings settings;

  void initState() {
    super.initState();
    
    this.settings = widget.settings;
    check = false;
  }

  @override
  Widget build(BuildContext context) {
    scoreToWinController.text = settings.scoreToWin.toString();
    return Dialog(
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Container(
          child: FractionallySizedBox(
            heightFactor: 0.7,
            child: Column(
              children: [
                Text(
                  'Game Settings',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  )
                ),
                Divider(),
                Expanded(
                  flex: 2,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      SettingsDialogItem(
                        left: Text('Score required to win'),
                        right: Container(
                          width: 40,
                          child: TextField(
                            textAlign: TextAlign.right,
                            controller: scoreToWinController,
                            keyboardType: TextInputType.numberWithOptions(signed: false, decimal: false),
                            inputFormatters: [
                              WhitelistingTextInputFormatter(RegExp(r"[0-9]+")),
                            ],
                            onChanged: (val) {
                              settings.scoreToWin = int.parse(val);
                            },
                          )
                        )
                      ),
                      SettingsDialogItem(
                        left: Text('Pick a new host'),
                        right: RaisedButton(
                          child: Text('Pick'),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return SimpleDialog(
                                  children: <Widget>[Text('Hello')],
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  )
                ),
                Divider(),
                Align(
                  alignment: Alignment.centerRight,
                  child: RaisedButton(
                    color: Colors.blue,
                    textColor: Colors.white,
                    child: Text('Save'),
                    onPressed: () {
                      //TODO: Have a way to cancel changes.
                      // Probably a cancel button, plus only doing changes after 'Save'
                      Navigator.of(context).pop();
                    },
                  ),
                )
              ],
            )
          )
        )
      )
    );
  }
}

class LobbyScreen extends StatefulWidget {
  final Map<String, dynamic> arguments;

  LobbyScreen({
    @required this.arguments,
  });

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}


class _LobbyScreenState extends State<LobbyScreen> {
  final TextEditingController nameController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey kickYourselfSnackbarKey = GlobalKey();

  final int maxPlayers = 16;

  List<String> players = List<String>();
  String hostName;
  String lobbyCode;
  LobbySettings settings;
  Future<Connection> conn;

  @override
  void initState() {
    super.initState();
    settings = LobbySettings();

    hostName = widget.arguments['username'];
    conn = widget.arguments['connection'];
    conn.then((connection) {
      connection.onJoin = (username) {
        setState(() {
          players.add(username);
        });
      };

      connection.onLeft = (username) {
        setState(() {
          players.remove(username);
        });
      };

      connection.onGameCreated = () {
        setState(() {
          players = [hostName];
          lobbyCode = connection.code;
        });
      };

      connection.onJoinedGame = (userList) {
        setState(() {
          players = userList;
        });
      };
    });
  }

  // 
  Future<bool> confirmKick(BuildContext context, int index) async {
    // Show snackbar if the player kicked is yourself.
    if (players[index] == hostName) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('You cannot kick yourself.'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        key: kickYourselfSnackbarKey,
      ));
      return false;
    }

    // Kick player dialog.
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Kick player'),
          content: Container( child: 
            Text('Are you sure you want to kick this player?\n\nThey will be able to rejoin.'), 
          ),
          actions: [
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            FlatButton(
              child: Text('Kick'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      }
    );
  }

  // Individual item in the [buildPlayerList] [ListView]
  Widget buildItem(BuildContext context, int index) {
    // Swipable tile for each player.
    // TODO: not have dismissable for joining users.
    return Dismissible(
      key: GlobalKey(),
      resizeDuration: Duration(milliseconds: 200),

      background: Container(
        color: Colors.red,
        padding: EdgeInsets.only(left: 20),
        alignment: Alignment.centerLeft,
        child: Icon(Icons.gavel),
      ),
      onDismissed: (DismissDirection direction) {
        setState((){
          players.remove(players[index]);
        });
      },
      confirmDismiss: (direction) async => confirmKick(context,index),
      child: Column(
        children: [
          Container(
            child: ListTile(
              title: Text(
                players[index],
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
              subtitle: players[index] != hostName ? Text('Swipe to kick', style: TextStyle(fontSize: 10),) : null,
            )
          ),
          Divider(),
        ]
      )
    );
  }

  // [ListView] of players in the lobby.
  Widget buildPlayerList() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(2),
          topRight: Radius.circular(2),
        ),
        border: Border.fromBorderSide(BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: ListView.builder(
        shrinkWrap: false,
        scrollDirection: Axis.vertical,
        itemCount: players.length,
        itemBuilder: (context, index) => buildItem(context, index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lobby'),
        actions: <Widget>[
          // Button to open the settings dialog.
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return LobbySettingsDialog(settings);
                },
              );
            },
          )
        ],
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 400,
          ),
          child: Column(
            children: <Widget>[
              Padding(
                // Room code.
                padding: EdgeInsets.all(5),
                child: Text(
                  "$lobbyCode", //TODO: Code here
                  style: TextStyle(
                    fontSize: 32,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              Divider(color: Colors.black,),
              // Playercount and start button.
              Padding(
                padding: EdgeInsets.all(5),
                child: Row(
                  children: [
                    Text(
                      'Players (${players.length}/$maxPlayers)',
                      style:  TextStyle(
                        fontSize: 24,
                      ),
                    ),
                    //TODO: Probably better with a grid layout or something!
                    Container(height: 40, child: VerticalDivider(color: Colors.black,)),
                    RaisedButton(
                      child: Text('Start Game'),
                      onPressed: () {
                        print('GOGOGOG');
                      },
                    ),
                  ],
                )
              ),
              // Listview of current players in the lobby.
              Expanded(child: buildPlayerList()),
            ]
          )
        )
      ),
    );
  }
}