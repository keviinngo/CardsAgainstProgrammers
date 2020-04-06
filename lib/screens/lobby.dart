import 'package:cap/controllers/connectionController.dart';
import 'package:cap/util/cards.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Lobby settings.
class LobbySettings {
  int  scoreToWin = 5;
  bool check      = false;
  int  activeDeck = 0;
}


Widget buildDeckSelection(BuildContext context, Future<List<Deck>> allDecks) {
  return FutureBuilder<List<Deck>>(
    future: allDecks.timeout(Duration(seconds: 10)),
    builder: (context, snapshot) {
      List<Widget> children = [];

      if (snapshot.hasData) {
        if (snapshot.data == null) {
          children.add(Text("Failed to load decks. Try again later."));
          return Column(children: children);
        }

        for (var deck in snapshot.data) {
          children.add(ListTile(
            title: Text(
                deck.title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
              subtitle: Text(deck.description),
              onTap: () {
                print("We want: " + deck.title);
                //TODO: Do something with the thing we return
                Navigator.of(context).pop(deck.id);
              },
          ));
        }
      } else if (snapshot.hasError) {
        children.add(Text("Failed to load decks. Try again later."));
        return Column(children: children);
      } else {
        children.add(CircularProgressIndicator());
        return Column(children: children);
      }

      return Container(
        child: ListView.separated(
          itemCount: children.length,
          itemBuilder: (context, index) {
            return children[index];
          },
          separatorBuilder: (context, index) {
            return Divider();
          },
        ),
      );
    }
  );
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
                      SettingsDialogItem(
                        left: Text('Select deck'),
                        right: RaisedButton(
                          child: Text('Deck'),
                          onPressed: () {
                            var deck = showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text("Select a deck"),
                                  content: buildDeckSelection(context, getAllDecks()),
                                );
                              },
                            );

                            deck.then((deckid) {
                              if (deckid.runtimeType == int) {
                                settings.activeDeck = deckid;
                              }
                            });
                          },
                        ),
                      )
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
  final GlobalKey<AnimatedListState> playerListKey = GlobalKey();

  final Tween<Offset> slideIn = Tween<Offset>(begin: Offset(-1, 0), end: Offset.zero);
  final Tween<Offset> slideOut = Tween<Offset>(begin: Offset(1, 0), end: Offset.zero);

  final int maxPlayers = 16;

  List<String> players = List<String>();
  String userName;
  String lobbyCode;
  bool isHost;
  LobbySettings settings;
  Future<Connection> conn;
  bool willDispose = true;
  bool loading = true;

  @override
  /// Called when the Lobby widget is removed, close any remaining connections.
  void dispose() {
    super.dispose();
 
    if (willDispose) {
      conn.then((connection) {
        connection.sendJson({'message': 'leave_game'});
        connection.socket.close();
      });
    }
    willDispose = true;
  }

  @override
  void initState() {
    isHost = false;
    super.initState();
    settings = LobbySettings();

    userName = widget.arguments['username'];
    conn = widget.arguments['connection'];
    conn.then((connection) {
      isHost = connection.isHost;

      // connection.codeIsValidFuture.future.then((val) {
      //   if(!val) {
      //     Navigator.of(context).pushReplacementNamed('/join');
      //     showDialog(
      //       context: context,
      //       builder: (context) {
      //         return AlertDialog(
      //           content: Text('Invalid game code.'),
      //           actions: <Widget>[
      //             FlatButton(
      //               child: Text('Ok'),
      //               onPressed: () {
      //                 Navigator.of(context).pop();
      //               },
      //             )
      //           ],
      //         );
      //       }
      //     );
      //   }
      // });

      connection.onJoin = (username) {
        setState(() {
          players.add(username);
          playerListKey.currentState.insertItem(players.length-1);
        });
      };

      connection.onLeft = (username) {
        setState(() {
          int index = players.indexOf(username);
          players.remove(username);
          playerListKey.currentState.removeItem(index, (context, animation) {
            return buildItem(context, username, true, animation);
          });
        });
      };

      connection.onKicked = (){
        
          //Navigator.of(context).pushReplacementNamed('/');
          showDialog(context: context, barrierDismissible: false, builder: (context){
            return AlertDialog(
              title: Text('Kicked'),
              actions: <Widget>[
                RaisedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/');
                  },
                )
              ],
            );
          });
        
      };

      connection.onGameCreated = () {
        setState(() {
          players = [userName];
          lobbyCode = connection.code;
          loading = false;
        });
      };

      connection.onJoinedGame = (userList) {
        print('joined game');
        setState(() {
          players = userList;
          lobbyCode = connection.code;
          loading = false;
        });
      };
      connection.onStarted = () {
        willDispose = false;
        connection.onJoin = null;
        Navigator.of(context).pushReplacementNamed('/game',
        arguments: {
          'players': players,
          'isHost': isHost,
          'userName': userName,
          'conn': connection,
        });
      };
      connection.onPromoted = () {
        setState((){
          isHost = true;
        });
      };
    });
  }

  // 
  Future<bool> confirmKick(BuildContext context, String player) async {
    // Show snackbar if the player kicked is yourself.
    if (player == userName) {
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
  Widget buildItem(BuildContext context, String player, bool removed, Animation<double> animation) {
    // Swipable tile for each player.
    // TODO: not have dismissable for joining users.
    return Dismissible(
      key: GlobalKey(),
      resizeDuration: null,
      direction: DismissDirection.startToEnd,
      movementDuration: Duration(milliseconds: 200),

      background: Container(
        color: Colors.red,
        padding: EdgeInsets.only(left: 20),
        alignment: Alignment.centerLeft,
        child: Icon(Icons.gavel),
      ),
      onDismissed: (DismissDirection direction) {
        setState((){
          conn.then((connection){
            connection.kickPlayer(player);
          });
        });
      },
      confirmDismiss: (direction) async => confirmKick(context, player),
      child: SlideTransition(
        position: removed ? slideOut.animate(animation) : slideIn.animate(animation),
        child: Column(
          children: [
            Container(
              child: ListTile(
                title: Text(
                  player,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
                subtitle: isHost ? player != userName ? Text('Swipe to kick', style: TextStyle(fontSize: 10),) : null : null,
              )
            ),
            Divider(),
          ]
        )
      )
    );
  }

  /// [ListView] of players in the lobby.
  //TODO: Show an indication for users themselves
  Widget buildPlayerList() {
    return ClipRect(child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(2),
          topRight: Radius.circular(2),
        ),
        border: Border.fromBorderSide(BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: AnimatedList(
        key: playerListKey,
        shrinkWrap: false,
        scrollDirection: Axis.vertical,
        initialItemCount: players.length,
        itemBuilder: (context, index, animation) => buildItem(context, players[index], false, animation),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lobby'),
        actions: <Widget>[
          // Button to open the settings dialog.
          isHost ? IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return LobbySettingsDialog(settings);
                },
              );
            },
          ) : Container()
        ],
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 400,
          ),
          child: !loading ? Column(
            children: <Widget>[
              Padding(
                // Room code.
                padding: EdgeInsets.all(5),
                child: Text(
                  "Room code: $lobbyCode", //TODO: Code here
                  style: TextStyle(
                    fontSize: 32,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Divider(color: Colors.black,),
              // Playercount and start button.
              Padding(
                padding: EdgeInsets.all(5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Players (${players.length}/$maxPlayers)',
                      style:  TextStyle(
                        fontSize: 24,
                      ),
                    ),
                    // Shows startgame button only when the player is a host.
                    isHost ? startGame(conn) : Container(),
                  ],
                )
              ),
              // Listview of current players in the lobby.
              Expanded(child: buildPlayerList()),
            ]
          ) : CircularProgressIndicator(value: null)
        )
      ),
    );
  }

  /// Returns a button that sends the json message for starting the game.
  Widget startGame(Future<Connection> conn) {
    return RaisedButton(
      onPressed: players.length >= 2 ? () {
        conn.then((connection) {
          //TODO: send the deck we want to use
          connection.sendJson(
            {"message": "start_game"}
          );
        });
      } : null,
      child: Text('Start game'),
    );
  }
}
