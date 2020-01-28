import 'package:flutter/material.dart';


/// Interface to join a already running game.
class CreateScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create'),
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
                Padding(padding: EdgeInsets.only(top: 20),),
                buildNameField(),
                RaisedButton(
                  child: Text('Create'),
                  onPressed: () {
                    if (formKey.currentState.validate()) {
                      print("Create game as ${nameController.text}");
                    }
                  },
                ),
              ]
            ),
          )
        )
      ),
    );
  }
}