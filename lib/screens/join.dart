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

  Widget buildCodeField() {
    return TextFormField(
      controller: codeController,
      maxLength: 4,
      maxLengthEnforced: true,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        hintText: 'Code',
        border: OutlineInputBorder(),
      ),
      inputFormatters: [
        WhitelistingTextInputFormatter(RegExp(r"[A-Za-z]*")),
        UppercaseInputFormatter(),
      ],
      enableSuggestions: false,
      textCapitalization: TextCapitalization.characters,
      keyboardType: TextInputType.text,
      validator: (str) {
        return str.length != 4 ? "Code too short" : null;
      },
    );
  }

  Widget buildNameField() {
    return TextFormField(
      controller: nameController,
      maxLength: 64,
      maxLengthEnforced: true,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        hintText: 'Name',
        border: OutlineInputBorder(),
      ),
      inputFormatters: [],
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
        if (formKey.currentState.validate()) {
          Future<Connection> conn = Connection.joinGame('${nameController.text}', '${codeController.text}');
          Navigator.of(context).pushReplacementNamed(
            '/lobby',
            arguments: {
              'connection': conn,
              'username': nameController.text
            }
          );
        }
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
          ),
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                buildCodeField(),
                Padding(padding: EdgeInsets.only(top: 20),),
                buildNameField(),
                joinButton(context)
              ]
            ),
          )
        )
      ),
    );
  }
}