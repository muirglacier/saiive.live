import 'package:defichainwallet/generated/l10n.dart';
import 'package:defichainwallet/ui/wallet/recovery_phrase_test.dart';
import 'package:flutter/material.dart';

class RecoveryPhraseDisplayScreen extends StatefulWidget {
  final String mnemonic;
  final bool showNextButton;

  RecoveryPhraseDisplayScreen(this.mnemonic, {this.showNextButton = true});

  @override
  State<StatefulWidget> createState() {
    return _RecoveryPhraseDisplayScreen();
  }
}

class _RecoveryPhraseDisplayScreen extends State<RecoveryPhraseDisplayScreen> {
  buildChips(List<String> input) {
    return input
        .asMap()
        .map((i, element) => MapEntry(
            i,
            Container(
              child: Chip(
                label: Text(element),
                avatar: CircleAvatar(
                    child: Text(
                      (i + 1).toString(),
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Theme.of(context).primaryColor),
              ),
            )))
        .values
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final mnemonic = widget.mnemonic;
    final split = mnemonic.split(" ");

    return Scaffold(
        appBar: AppBar(title: Text(S.of(context).wallet_recovery_phrase_title)),
        body: Padding(
            padding: EdgeInsets.all(10),
            child: Container(
                child: Column(children: [
              Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    S.of(context).wallet_new_phrase_info,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20),
                  )),
              SizedBox(height: 10),
              Container(
                  child: Align(
                      alignment: Alignment.center,
                      child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          alignment: WrapAlignment.center,
                          runAlignment: WrapAlignment.center,
                          direction: Axis.horizontal,
                          children: buildChips(split)))),
              SizedBox(height: 50),
              if (widget.showNextButton)
                Container(
                    child: SizedBox(
                        width: 300,
                        child: ElevatedButton(
                          child: Text(S.of(context).next),
                          style: ElevatedButton.styleFrom(primary: Theme.of(context).backgroundColor),
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => RecoveryPhraseTestScreen(split)));
                          },
                        )))
            ]))));
  }
}
