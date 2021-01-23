import 'package:defichainwallet/generated/l10n.dart';
import 'package:defichainwallet/helper/constants.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

class RecoveryPhraseTestScreen extends StatefulWidget {
  final List<String> mnemonic;

  RecoveryPhraseTestScreen(this.mnemonic);

  @override
  State<StatefulWidget> createState() {
    return _RecoveryPhraseTestScreen();
  }
}

class _RecoveryPhraseTestScreen extends State<RecoveryPhraseTestScreen> {
  final _formKey = GlobalKey<FormState>();

  _RecoveryPhraseTestScreen();

  List<int> getRandomForTest(int randomCount, List<String> phrase) {
    List<int> ret = [];
    final random = Random.secure();

    int i = 0;
    while (i < 4) {
      final next = random.nextInt(phrase.length - 1);

      if (!ret.contains(next)) {
        ret.add(next);
        i++;
      }
    }

    ret.sort();
    return ret;
  }

  buildInputs(List<int> inputs, Map<int, TextEditingController> controller) {
    return inputs
        .asMap()
        .map((i, element) => MapEntry(
            i,
            Container(
              child: Column(children: <Widget>[
                Text(
                    "#" +
                        (element + 1).toString() +
                        S.of(context).wallet_new_test_word,
                    textAlign: TextAlign.left,
                    style: TextStyle(color: Theme.of(context).hintColor)),
                Padding(
                    padding: EdgeInsets.all(10),
                    child: TextFormField(
                        autofocus: i == 0,
                        controller: controller[element],
                        validator: (value) {
                          if (value != widget.mnemonic[element])
                            return S.of(context).wallet_new_test_invalid;
                          return null;
                        },
                        onEditingComplete: () => {},
                        decoration: InputDecoration(
                          fillColor: Theme.of(context).highlightColor,
                          filled: true,
                          border: InputBorder.none,
                          labelText: S.of(context).wallet_new_test_put1 +
                              (element + 1).toString() +
                              S.of(context).wallet_new_test_put2,
                        )))
              ]),
            )))
        .values
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final randomWordsToTest = getRandomForTest(4, widget.mnemonic);

    final textEditControllerMap = new Map<int, TextEditingController>();

    randomWordsToTest.forEach((a) =>
        textEditControllerMap.putIfAbsent(a, () => TextEditingController()));

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: Text(S.of(context).wallet_recovery_phrase_test_title),
          actions: <Widget>[
            InkWell(
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();

                  await prefs.setString(
                      DefiChainConstants.MnemonicKey, widget.mnemonic.join(" "));
                  await prefs.setInt(DefiChainConstants.WorkingAccountKey, 0);
                  await prefs.setBool(
                      DefiChainConstants.RecoveryPhraseTested, false);

                  //RecoveryPhraseBackupSettings.backupWalletAlreadyShown = true;

                  // Navigator.of(context).pushReplacementNamed("walletPage");
                },
                child: Padding(
                    padding: EdgeInsets.only(top: 15, right: 15),
                    child: Text(
                      S.of(context).later,
                      textScaleFactor: 1.5,
                      style: new TextStyle(fontSize: 12.0),
                    )))
          ],
        ),
        body: SingleChildScrollView(
            child: Padding(
                padding: EdgeInsets.all(5),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.start,
                    verticalDirection: VerticalDirection.down,
                    children: [
                      Text(S.of(context).wallet_new_test_confirm,
                          style: TextStyle(fontFamily: "Popins", fontSize: 20),
                          textAlign: TextAlign.center),
                      SizedBox(height: 10),
                      Text(S.of(context).wallet_new_test_confirm_info,
                          style: TextStyle(color: Theme.of(context).hintColor),
                          textAlign: TextAlign.center),
                      SizedBox(height: 20),
                      Form(
                          key: _formKey,
                          child: Column(
                              children: buildInputs(
                                  randomWordsToTest, textEditControllerMap))),
                      SizedBox(height: 20),
                      Container(
                          child: SizedBox(
                              width: 300,
                              child: RaisedButton(
                                child: Text(S.of(context).next),
                                color: Theme.of(context).backgroundColor,
                                onPressed: () async {
                                  final prefs =
                                      await SharedPreferences.getInstance();

                                  if (_formKey.currentState.validate()) {
                                    await prefs.setString(
                                        DefiChainConstants.MnemonicKey,
                                        widget.mnemonic.join(" "));
                                    await prefs.setInt(
                                        DefiChainConstants.WorkingAccountKey,
                                        0);
                                    await prefs.setBool(
                                        DefiChainConstants.RecoveryPhraseTested,
                                        true);

                                    // Navigator.of(context)
                                    //     .pushReplacementNamed("walletPage");
                                  }
                                },
                              )))
                    ]))));
  }
}
