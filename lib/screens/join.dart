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
        hintText: '0000',
        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
      ),
      inputFormatters: [
        WhitelistingTextInputFormatter(RegExp(r"[0-9]*")),
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

  Widget buildNameField() {
    return TextFormField(
      controller: nameController,
      maxLength: 20,
      maxLengthEnforced: true,
      textAlign: TextAlign.center,
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
        if (formKey.currentState.validate()) {
          print("Join ${codeController.text} as ${nameController.text}");
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
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                Text('ROOM CODE', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                Padding(padding: EdgeInsets.only(top: 10),),
                buildCodeField(),
                Padding(padding: EdgeInsets.only(top: 20),),
                Text('ENTER YOUR NAME', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                Padding(padding: EdgeInsets.only(top: 10),),
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