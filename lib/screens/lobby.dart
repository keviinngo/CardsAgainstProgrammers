import 'package:flutter/material.dart';


class LobbyScreen extends StatefulWidget {
  final Map<String, dynamic> arguments;

  LobbyScreen({
    @required this.arguments,
  });

  @override
  State<LobbyScreen> createState() => LobbyScreenState();
}


/// Interface to join a already running game.
class LobbyScreenState extends State<LobbyScreen> {
  final TextEditingController nameController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey kickYourselfSnackbarKey = GlobalKey();

  final int maxPlayers = 16;

  List<String> players = List<String>();
  String hostName;

  @override
  void initState() {
    super.initState();
    hostName = widget.arguments['username'];
    players = [
      widget.arguments['username'],
      'Tosha',
      'Von',
      'Renee',
      'Chet',
      'Stephany',
      'Lolita',
      'Roseanne',
      'Delphia',
      'Jacquline',
      'Un',
      'Martin',
      'Simonne',
    ];
  }

  Future<bool> confirmKick(BuildContext context, int index) async {
    if (players[index] == hostName) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('You cannot kick yourself.'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        key: kickYourselfSnackbarKey,
      ));
      return false;
    }

    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm'),
          content: Text('Are you sure you want to kick this user?\nThey will be able to rejoin.'),
          actions: [
            FlatButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
            FlatButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
          ],
        );
      }
    );
  }

  Widget buildItem(BuildContext context, int index) {
    return Dismissible(
      key: GlobalKey(),
      background: Container(
        color: Colors.red,
      ),
      onDismissed: (DismissDirection direction) {
        setState((){
          players.remove(players[index]);
        });
      },
      confirmDismiss: (direction) async => confirmKick(context,index),
      child: Column(
        children: [
          ListTile(
            title: Text(players[index]),
            subtitle: Text('Swipe to kick', style: TextStyle(fontSize: 10),),
          ),
          Divider(),
        ]
      )
    );
  }

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
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 400,
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(5),
                child: Text(
                  "PEKI", //TODO: Code here
                  style: TextStyle(
                    fontSize: 32,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              Divider(color: Colors.black,),
              Padding(
                padding: EdgeInsets.all(5),
                child: Text(
                  'Players (${players.length}/$maxPlayers)',
                  style:  TextStyle(
                    fontSize: 24,
                  ),
                ),
              ),
              Expanded(child: buildPlayerList()),
            ]
          )
        )
      ),
    );
  }
}