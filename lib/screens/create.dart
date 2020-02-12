import 'package:cap/controllers/connectionController.dart';
import 'package:flutter/material.dart';


/// Interface to join a already running game.
class CreateScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

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
      inputFormatters: [],
      enableSuggestions: true,
      validator: (str) {
        return str.isEmpty ? "Need a name" : null;
      },
    );
  }

  Widget createButton(context) {
    return InkWell(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      onTap: (() {
        if (formKey.currentState.validate()) {
          Future<Connection> conn = Connection.createGame('${nameController.text}');
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
          border: Border.all(color: Colors.black, style:  BorderStyle.solid, width: 0.5),
          borderRadius: BorderRadius.all(Radius.circular(10))
        ),
        child: Center(
          child: Text(
            'Create',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
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
                Padding(padding: EdgeInsets.only(top: 40),),
                Text('ENTER YOUR NAME', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                Padding(padding: EdgeInsets.only(top: 10),),
                buildNameField(),
                createButton(context)
              ]
            ),
          )
        )
      ),
    );
  }
}