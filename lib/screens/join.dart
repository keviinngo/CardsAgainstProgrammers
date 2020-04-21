import 'package:cap/controllers/connectionController.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


/// TextInputFormatter that makes sure all letters are capitalized.
class UppercaseInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // Should we or should we not set `composing` on the returned value
    return TextEditingValue(text: newValue.text.toUpperCase(), selection: newValue.selection);
  }
}


/// Interface to join a already running game.
class JoinScreen extends StatelessWidget {
  final TextEditingController codeController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  Widget buildCodeField(BuildContext context) {
    return TextFormField(
      controller: codeController,
      maxLength: 4,
      maxLengthEnforced: true,
      textAlign: TextAlign.center,
      onEditingComplete: () {
        // Dismisses keyboard
        FocusScope.of(context).unfocus();
        joinGame(context);
      },
      decoration: InputDecoration(
        hintText: '----',
        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
      ),
      inputFormatters: [
        WhitelistingTextInputFormatter(RegExp(r"[A-Za-z]*")),
        UppercaseInputFormatter(),
      ],
      enableSuggestions: false,
      textCapitalization: TextCapitalization.characters,
      keyboardType: TextInputType.text,
      validator: (str) {
        return str.length != 4 ? "Room code too short" : null;
      },
    );
  }

  Widget buildNameField(BuildContext context) {
    return TextFormField(
      controller: nameController,
      maxLength: 20,
      maxLengthEnforced: true,
      textAlign: TextAlign.center,
      onEditingComplete: () {
        // Dismisses keyboard
        FocusScope.of(context).unfocus();
        joinGame(context);
      },
      decoration: InputDecoration(
        hintText: '----',
        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
      ),
      inputFormatters: [
        WhitelistingTextInputFormatter(RegExp(r"[A-Za-z]*")),
      ],
      enableSuggestions: true,
      validator: (str) {
        return str.isEmpty ? "Need a name" : null;
      },
    );
  }

  Widget joinButton(context) {
    return InkWell(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      onTap: (() {
        joinGame(context);
      }),
      child: Ink(
        width: 160,
        height: 90,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, style: BorderStyle.solid, width: 0.5),
          borderRadius: BorderRadius.all(Radius.circular(10))
        ),
        child: Center(
          child: Text(
            'Join',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        )
      )
    );
  }

  /// Sets in motion the action of joining a game
  void joinGame(BuildContext context) {
    if (formKey.currentState.validate()) {
      Future<Connection> conn = Connection.checkCodeAndJoinGame('${nameController.text}', '${codeController.text}');
      conn.then((connection) {
        if (connection != null) {
          Navigator.of(context).pushNamedAndRemoveUntil('/lobby', (route) => false, arguments: {
              'connection': conn,
              'username': nameController.text
          });
        } else {
          scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text('Could not connect to lobby'),
            duration: Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ));
        }
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('Join'),
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 400,
          ),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                Padding(padding: EdgeInsets.only(top: 40),),
                Text('ROOM CODE', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                Padding(padding: EdgeInsets.only(top: 10),),
                buildCodeField(context),
                Padding(padding: EdgeInsets.only(top: 20),),
                Text('ENTER YOUR NAME', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                Padding(padding: EdgeInsets.only(top: 10),),
                buildNameField(context),
                joinButton(context)
              ]
            ),
          )
        )
      ),
    );
  }
}