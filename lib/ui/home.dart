import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen();

  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _showEmptyAlertDialog() {
    showDialog(
      //barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:  Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              child: Text("Restore Semonic Seed"),
              onPressed: _showEmptyAlertDialog,
            ),
            SizedBox(width: 5),
            RaisedButton(
              child: Text("Create Wallet"),
              onPressed: _showEmptyAlertDialog,
            ),
          ],
        ),
      )
    );
  }
}
