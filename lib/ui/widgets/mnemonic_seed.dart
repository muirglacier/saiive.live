import 'package:defichaindart/defichaindart.dart';
import 'package:defichainwallet/generated/l10n.dart';
import 'package:defichainwallet/helper/bip39/english.dart';
import 'package:defichainwallet/ui/widgets/responsive.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MnemonicSeedWidget extends StatefulWidget {
  final List<String> words;
  final Function(String) onNext;
  final bool readOnly;
  final bool showNextButton;

  MnemonicSeedWidget({this.words = const [], @required this.onNext, this.readOnly = false, this.showNextButton = true});

  @override
  State<StatefulWidget> createState() {
    return _MnemonicSeedWidget();
  }
}

class _MnemonicSeedWidget extends State<MnemonicSeedWidget> {
  Map<int, TextFormField> _textFields = new Map<int, TextFormField>();
  final _formKey = GlobalKey<FormState>();

  String getPhrase() {
    return _textFields.values.map((e) => e.controller.text).join(" ");
  }

  @override
  Widget build(BuildContext context) {
    final node = FocusScope.of(context);

    for (var i = 0; i < 24; i++) {
      var controller = TextEditingController();
      var textField = TextFormField(
        controller: controller,
        readOnly: widget.readOnly,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
            prefixIcon: new Padding(
              padding: const EdgeInsets.only(top: 15, left: 5, right: 0, bottom: 15),
              child: Text((i + 1).toString()),
            ),
            hintText: S.of(context).wallet_restore_word_hint),
        textInputAction: i == 23 ? TextInputAction.done : TextInputAction.next,
        onEditingComplete: () => i == 23 ? node.unfocus() : node.nextFocus(),
        validator: (value) {
          if (value.isEmpty) {
            return S.of(context).wallet_restore_word_empty;
          }

          if (WORDLIST_ENGLISH.indexOf(value) == -1) {
            return S.of(context).wallet_restore_word_invalid;
          }

          return null;
        },
      );
      controller.text = widget.words.length > i ? widget.words[i] : "";

      _textFields[i] = textField;
    }

    return LayoutBuilder(builder: (_, builder) {
      var row = Responsive.buildResponsive<TextFormField>(context, _textFields.values.toList(), 300, (el) => el);

      return SingleChildScrollView(
          child: Card(
              child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Form(
                      autovalidateMode: AutovalidateMode.disabled,
                      key: _formKey,
                      child: Column(children: [
                        row,
                        Padding(padding: EdgeInsets.only(top: 30)),
                        if (widget.showNextButton)
                          ElevatedButton(
                            child: Text(S.of(context).next),
                            onPressed: () async {
                              if (_formKey.currentState.validate()) {
                                var phrase = getPhrase();

                                if (!validateMnemonic(phrase)) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text(S.of(context).wallet_restore_invalidMnemonic),
                                  ));
                                  return;
                                }

                                widget.onNext(phrase);
                              }
                            },
                          )
                      ])))));
    });
  }
}
