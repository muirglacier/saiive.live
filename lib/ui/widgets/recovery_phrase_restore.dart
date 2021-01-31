import 'package:defichaindart/defichaindart.dart';
import 'package:defichainwallet/generated/l10n.dart';
import 'package:defichainwallet/helper/bip39/english.dart';
import 'package:defichainwallet/network/model/ivault.dart';
import 'package:defichainwallet/service_locator.dart';
import 'package:defichainwallet/util/sharedprefsutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tagging/flutter_tagging.dart';

class RestoreRecoveryPhraseScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RestoreRecoveryPhraseScreen();
  }
}

class PhraseTaggable extends Taggable {
  final String name;

  PhraseTaggable({this.name});

  @override
  List<Object> get props => [name];
}

class PhraseService {
  /// Mocks fetching language from network API with delay of 500ms.
  static List<PhraseTaggable> getLanguages(String query) {
    final words =
        WORDLIST_ENGLISH.where((element) => element.startsWith(query));
    var phraseList = List<PhraseTaggable>.empty(growable: true);

    words.forEach((element) {
      phraseList.add(PhraseTaggable(name: element));
    });

    return phraseList;
  }
}

class _RestoreRecoveryPhraseScreen extends State<RestoreRecoveryPhraseScreen> {
  List<PhraseTaggable> _selectedPhrases = [];
  bool _inputEnabled = true;

  String _phrase;
  bool _autoFocus = true;

  FocusNode _tagBoxFocus = FocusNode();

  @override
  void initState() {
    _selectedPhrases = [];

    var demoWords2 =
        "sample visa rain lab truly dwarf hospital uphold stereo ride combine arrest aspect exist oil just boy garment estate enable marriage coyote blue yellow";

    var items = demoWords2.split(" ");

    items.forEach((element) {
      _selectedPhrases.add(new PhraseTaggable(name: element));
    });

    _phrase = demoWords2;

    super.initState();
  }

  @override
  void dispose() {
    _selectedPhrases.clear();
    super.dispose();
  }

  Widget buildTagInput() {
    return FlutterTagging<PhraseTaggable>(
      initialItems: _selectedPhrases,
      textFieldConfiguration: TextFieldConfiguration(
        autofocus: _autoFocus,
        focusNode: _tagBoxFocus,
        decoration: InputDecoration(
            border: InputBorder.none,
            filled: true,
            fillColor: Theme.of(context).hintColor,
            labelText: S.of(context).wallet_restore_enterWords,
            enabled: _inputEnabled),
      ),
      findSuggestions: PhraseService.getLanguages,
      configureSuggestion: (phrase) {
        return SuggestionConfiguration(title: Text(phrase.name));
      },
      configureChip: (lang) {
        return ChipConfiguration(
            label: Text(lang.name),
            backgroundColor: Theme.of(context).primaryColor,
            labelStyle: TextStyle(color: Colors.white),
            deleteIconColor: Colors.white);
      },
      onChanged: () {
        // _tagBoxFocus.requestFocus();
        setState(() {
          _inputEnabled = _selectedPhrases.length <= 12;
          _phrase = _selectedPhrases.map((e) => e.name).join(" ");
          _autoFocus = true;
        });
      },
    );
  }

  Future saveSeed() async {
    await sl.get<SharedPrefsUtil>().setSeedBackedUp(true);
    await sl.get<IVault>().setSeed(_phrase);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.black, //change your color here
          ),
          backgroundColor: Theme.of(context).backgroundColor,
          brightness: Brightness.light,
          elevation: 0,
        ),
        body: SingleChildScrollView(
            child: Column(children: <Widget>[
          Padding(
              padding: EdgeInsets.only(top: 0, left: 10, right: 10),
              child: Container(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Container(
                  //     margin: const EdgeInsets.only(top: 00),
                  //     child: SizedBox(
                  //         height: height / 6,
                  //         child: Image.asset(
                  //           "assets/image/logo/logo.png",
                  //           fit: BoxFit.fill,
                  //         ))),
                  SizedBox(height: 20),
                  Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        S.of(context).wallet_restore_enterMnemonic,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20),
                      )),
                  SizedBox(height: 10),
                  Align(
                      alignment: Alignment.center,
                      child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          alignment: WrapAlignment.center,
                          runAlignment: WrapAlignment.center,
                          direction: Axis.horizontal,
                          children: [buildTagInput()])),
                  SizedBox(height: 50),
                  Container(
                      child: SizedBox(
                          width: 300,
                          child: RaisedButton(
                            child: Text(S.of(context).next),
                            color: Theme.of(context).backgroundColor,
                            onPressed: () async {
                              if (!validateMnemonic(_phrase)) {
                                ScaffoldMessenger.of(context)
                                  ..showSnackBar(SnackBar(
                                    content: Text(S
                                        .of(context)
                                        .wallet_restore_invalidMnemonic),
                                  ));
                              } else {
                                await saveSeed();
                                Navigator.of(context)
                                    .pushNamed("/intro_accounts_restore");
                              }
                            },
                          )))
                ],
              )))
        ])));
  }
}
