import 'package:flutter/material.dart';
import 'package:saiive.live/crypto/model/wallet_account.dart';
import 'package:saiive.live/generated/l10n.dart';

class DerivationPathTypeSelectorWidget extends StatefulWidget {
  final ValueChanged<PathDerivationType> onChanged;
  final bool isExpanded;

  const DerivationPathTypeSelectorWidget({@required this.onChanged, this.isExpanded = false});

  @override
  State<StatefulWidget> createState() {
    return _DerivationPathTypeSelectorWidgetState();
  }
}

class _DerivationPathTypeSelectorWidgetState extends State<DerivationPathTypeSelectorWidget> {
  bool _isExpanded = false;

  PathDerivationType _pathDerivationType = PathDerivationType.FullNodeWallet;

  @override
  void initState() {
    super.initState();

    setState(() {
      _isExpanded = widget.isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionPanelList(
        expandedHeaderPadding: EdgeInsets.all(5),
        expansionCallback: (int index, bool isExpanded) {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        children: [
          ExpansionPanel(
              isExpanded: _isExpanded,
              headerBuilder: (context, isOpen) {
                return GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        S.of(context).details,
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ));
              },
              body: Column(children: <Widget>[
                Column(children: <Widget>[
                  Text(S.of(context).wallet_new_phrase_path_derivation_type),
                  ListTile(
                    title: Text(pathDerivationTypeString(PathDerivationType.FullNodeWallet)),
                    leading: Radio<PathDerivationType>(
                      value: PathDerivationType.FullNodeWallet,
                      groupValue: _pathDerivationType,
                      onChanged: (PathDerivationType value) {
                        setState(() {
                          _pathDerivationType = value;
                          widget.onChanged(value);
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: Text(pathDerivationTypeString(PathDerivationType.BIP32)),
                    leading: Radio<PathDerivationType>(
                      value: PathDerivationType.BIP32,
                      groupValue: _pathDerivationType,
                      onChanged: (PathDerivationType value) {
                        setState(() {
                          _pathDerivationType = value;
                          widget.onChanged(value);
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: Text(pathDerivationTypeString(PathDerivationType.BIP44)),
                    leading: Radio<PathDerivationType>(
                      value: PathDerivationType.BIP44,
                      groupValue: _pathDerivationType,
                      onChanged: (PathDerivationType value) {
                        setState(() {
                          _pathDerivationType = value;
                          widget.onChanged(value);
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: Text(pathDerivationTypeString(PathDerivationType.JellyfishBullshit)),
                    leading: Radio<PathDerivationType>(
                      value: PathDerivationType.JellyfishBullshit,
                      groupValue: _pathDerivationType,
                      onChanged: (PathDerivationType value) {
                        setState(() {
                          _pathDerivationType = value;
                          widget.onChanged(value);
                        });
                      },
                    ),
                  ),
                ])
              ]))
        ]);
  }
}
