import 'package:flutter/material.dart';

import './empty_screen.dart';

class MessageScreen extends StatelessWidget {
  final String message;
  final Widget action;

  MessageScreen({@required this.message, @required this.action});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.height / 12),
        child: Column(
          children: <Widget>[
            EmptyScreen(message: message),
          ],
        ));
  }
}
