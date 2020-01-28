import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


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
    );
  }

  Widget buildNameField() {
    return TextFormField(
      controller: nameController,
      maxLength: 32,
      maxLengthEnforced: true,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        hintText: 'Name',
        border: OutlineInputBorder(),
      ),
      inputFormatters: [
        WhitelistingTextInputFormatter(RegExp(r"[\p{Letter}]*", unicode: true)),
      ],
      enableSuggestions: true,
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
          child: Column(
            children: [
              Padding(padding: EdgeInsets.only(top: 40),),
              buildCodeField(),
              buildNameField(),
              RaisedButton(
                child: Text('Join'),
                onPressed: () {
                  print("Join ${codeController.text} as ${nameController.text}");
                },
              )
            ]
          ),
        )
      ),
    );
  }
}