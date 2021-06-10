import 'package:clipboard_manager/clipboard_manager.dart';
import 'package:saiive.live/crypto/errors/TransactionError.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/helper/logger/LogHelper.dart';
import 'package:saiive.live/network/network_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TransactionFailScreen extends StatefulWidget {
  final String text;

  final String additional;
  final dynamic error;

  TransactionFailScreen(this.text, {this.additional, this.error});

  @override
  _TransactionFailScreenState createState() => _TransactionFailScreenState();
}

class _TransactionFailScreenState extends State<TransactionFailScreen> {
  String _errorText;

  String _stackTrace;

  transformError() {
    if (widget.error == null) {
      return;
    }

    if (widget.error is HttpException) {
      final httpError = widget.error as HttpException;
      _errorText = httpError.error.error;
    } else if (widget.error is TransactionError) {
      final txError = widget.error as TransactionError;
      _errorText = txError.error;
    } else {
      _errorText = widget.error.toString();
    }

    if (widget.error is Error) {
      _stackTrace = (widget.error as Error).stackTrace.toString();
    } else {
      _stackTrace = "";
    }

    LogHelper.instance.e(_errorText);
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
            widget.text,
            style: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.w800),
          ),
          if (widget.additional != null && widget.additional.isNotEmpty)
            Text(
              widget.additional,
              style: TextStyle(fontSize: 30, color: Colors.white),
            ),
          if (widget.error != null) SizedBox(height: 30),
          if (widget.error != null)
            Text(
              _errorText,
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          if (widget.error != null) SizedBox(height: 30),
          if (_stackTrace != null)
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
