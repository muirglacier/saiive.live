import 'package:defichaindart/defichaindart.dart';
import 'package:saiive.live/crypto/model/wallet_account.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/helper/bip39/english.dart';
import 'package:saiive.live/ui/widgets/derivation_path_type_selector_widget.dart';
import 'package:saiive.live/ui/widgets/responsive.dart';
import 'package:flutter/material.dart';

class MnemonicSeedWidget extends StatefulWidget {
  final List<String> words;
  final Function(String, PathDerivationType pathDerivationType, bool singleWalletMode) onNext;
  final bool readOnly;
  final bool showNextButton;
  final bool showUseSingleAddressFeature;

  MnemonicSeedWidget({this.words = const [], @required this.onNext, this.readOnly = false, this.showNextButton = true, this.showUseSingleAddressFeature = false});

  @override
  State<StatefulWidget> createState() {
    return _MnemonicSeedWidget();
  }
}

class _MnemonicSeedWidget extends State<MnemonicSeedWidget> {
  Map<int, TextFormField> _textFields = new Map<int, TextFormField>();
  Map<int, TextEditingController> _textControllers = new Map<int, TextEditingController>();
  final _formKey = GlobalKey<FormState>();

  bool _useSingleAddressMode = true;

  PathDerivationType _pathDerivationType = PathDerivationType.FullNodeWallet;

  String getPhrase() {
    return _textFields.values.map((e) => e.controller.text).join(" ");
  }

  void importSeed() {
    if (_formKey.currentState.validate()) {
      var phrase = getPhrase();

      if (!validateMnemonic(phrase)) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(S.of(context).wallet_restore_invalidMnemonic),
        ));
        return;
      }

      widget.onNext(phrase, _pathDerivationType, _useSingleAddressMode);
    }
  }

  @override
  void initState() {
    super.initState();

    for (var i = 0; i < 24; i++) {
      _textControllers[i] = TextEditingController();
      _textControllers[i].text = widget.words.length > i ? widget.words[i] : "";
    }
  }

  Widget buildDerivationPathType(BuildContext context) {
    return DerivationPathTypeSelectorWidget(onChanged: (v) {
      setState(() {
        this._pathDerivationType = v;
      });
    });
  }

  Widget buildUseSingleAddressMode(BuildContext context) {
    return Row(children: [
      Checkbox(
        value: _useSingleAddressMode,
        onChanged: (v) async {
          setState(() {
            _useSingleAddressMode = v;
          });
        },
      ),
      Text(S.of(context).wallet_use_single_address_mode),
      Container(width: 10),
      Text(
        S.of(context).wallet_use_single_address_mode_info,
        style: TextStyle(fontSize: 10),
      )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final node = FocusScope.of(context);

    for (var i = 0; i < 24; i++) {
      var controller = _textControllers[i];
      var textField = TextFormField(
        controller: controller,
        readOnly: widget.readOnly,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        autocorrect: false,
        enableSuggestions: false,
        decoration: InputDecoration(
            prefixIcon: new Padding(
              padding: const EdgeInsets.only(top: 15, left: 5, right: 0, bottom: 15),
              child: Text((i + 1).toString()),
            ),
            hintText: S.of(context).wallet_restore_word_hint),
        textInputAction: i == 23 ? TextInputAction.done : TextInputAction.next,
        onEditingComplete: () => i == 23 ? importSeed() : node.nextFocus(),
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
                        if (widget.readOnly) buildUseSingleAddressMode(context),
                        if (widget.readOnly) SizedBox(height: 10),
                        if (widget.readOnly) buildDerivationPathType(context),
                        if (widget.readOnly) SizedBox(height: 10),
                        if (widget.showNextButton)
                          ElevatedButton(
                            child: Text(S.of(context).next),
                            onPressed: () async {
                              importSeed();
                            },
                          )
                      ])))));
    });
  }
}
