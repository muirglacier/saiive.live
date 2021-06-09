import 'package:clipboard_manager/clipboard_manager.dart';
import 'package:saiive.live/crypto/errors/TransactionError.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/helper/logger/LogHelper.dart';
import 'package:saiive.live/network/network_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TransactionFailScreen extends StatelessWidget {
  final String text;

  final String additional;
  final dynamic error;

  String _errorText;
  String _stackTrace;

  TransactionFailScreen(this.text, {this.additional, this.error});

  transformError() {
    if (error == null) {
      return;
    }

    if (error is HttpException) {
      final httpError = error as HttpException;
      _errorText = httpError.error.error;
    } else if (error is TransactionError) {
      final txError = error as TransactionError;
      _errorText = txError.error;
    } else {
      _errorText = error.toString();
    }

    LogHelper.instance.e(_errorText);

    _stackTrace = error.stackTrace.toString();
  }

  @override
  Widget build(BuildContext context) {
    transformError();

    return Scaffold(
        appBar: AppBar(
          title: Text(
            S.of(context).wallet_operation_failed,
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        body: Center(
            child: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.error_outline_outlined, size: 50),
          Text(
            text,
            style: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.w800),
          ),
          if (additional != null && additional.isNotEmpty)
            Text(
              additional,
              style: TextStyle(fontSize: 30, color: Colors.white),
            ),
          if (error != null) SizedBox(height: 30),
          if (error != null)
            Text(
              _errorText,
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          if (error != null) SizedBox(height: 30),
          if (error != null)
            SelectableText(
              _stackTrace,
              style: TextStyle(color: Colors.white, fontSize: 10),
            ),
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  ClipboardManager.copyToClipBoard(_stackTrace).then((result) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(S.of(context).receive_address_copied_to_clipboard),
                    ));
                  });
                  Clipboard.setData(new ClipboardData(text: _stackTrace));
                },
                child: Icon(Icons.copy, size: 26.0, color: Colors.white),
              ))
        ])));
  }
}
