import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/generated/l10n.dart';

class AccountsAddScreen extends StatefulWidget {
  final ChainType chainType;

  AccountsAddScreen(this.chainType);

  @override
  State<StatefulWidget> createState() => _AccountsAddScreen();
}

class _AccountsAddScreen extends State<AccountsAddScreen> {
  @override
  initState() {
    super.initState();
  }

  _buildAccountAddScreen(BuildContext context) {
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight,
          title: Text(S.of(context).wallet_accounts_address_add),
          actions: [],
        ),
        body: _buildAccountAddScreen(context));
  }
}
