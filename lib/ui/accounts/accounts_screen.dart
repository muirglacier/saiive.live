import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/generated/l10n.dart';

class AccountsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AccountScreen();
}

class _AccountScreen extends State<AccountsScreen> {
  Widget _buildAccountPage(BuildContext context) {
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight, title: Text(S.of(context).wallet_accounts)), body: _buildAccountPage(context));
  }
}
