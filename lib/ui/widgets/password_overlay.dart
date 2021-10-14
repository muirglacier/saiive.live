import 'dart:async';

import 'package:saiive.live/appstate_container.dart';
import 'package:flutter/material.dart';

class PasswordOverlay {
  BuildContext _context;
  TextEditingController _controller = TextEditingController();

  //final password = await PasswordOverlay.of(context).show();
  Future<String> show() async {
    await showDialog(
        context: _context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return Scaffold(
              appBar: AppBar(
                title: Text(
                  'Password',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Color(0xFF1EBCA3),
                foregroundColor: Colors.white,
                iconTheme: IconThemeData(color: Colors.white),
                automaticallyImplyLeading: false,
              ),
              backgroundColor: Color(0xFF1EBCA3),
              body: Center(
                  child: Padding(
                      padding: EdgeInsets.all(100),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.lock_outline, size: 50, color: Colors.white),
                        Text(
                          'Unlock Wallet',
                          style: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.w800),
                        ),
                        TextFormField(
                          controller: _controller,
                          obscureText: true,
                          enableSuggestions: false,
                          autocorrect: false,
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                            child: Text('Unlock', style: TextStyle(color: Colors.black)),
                            style: ElevatedButton.styleFrom(primary: StateContainer.of(context).curTheme.buttonColorSecondary),
                            onPressed: () {
                              Navigator.of(_context).pop();
                            })
                      ]))));
        });

    return _controller.text;
  }

  PasswordOverlay._create(this._context);

  factory PasswordOverlay.of(BuildContext context) {
    return PasswordOverlay._create(context);
  }
}
