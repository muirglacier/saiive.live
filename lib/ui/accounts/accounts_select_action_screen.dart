import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/ui/utils/token_icon.dart';

typedef void AccountSelectionItemSelected(ChainType chainType);

class AccountsSelectActionScreen extends StatefulWidget {
  final AccountSelectionItemSelected onAction;
  AccountsSelectActionScreen(this.onAction);

  @override
  State<StatefulWidget> createState() => _AccountsSelectActionScreen();
}

class _AccountsSelectActionScreen extends State<AccountsSelectActionScreen> {
  Widget _buildEntry(BuildContext context, ChainType chain) {
    return Card(
        child: ListTile(
      leading: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [TokenIcon(ChainHelper.chainTypeString(chain))]),
      title: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Row(children: [Text(ChainHelper.chainTypeString(chain), style: Theme.of(context).textTheme.headline3)])
      ]),
      onTap: () {
        this.widget.onAction(chain);
      },
    ));
  }

  _buildAccountSelectActionScreen(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(10), child: Scrollbar(child: Padding(padding: EdgeInsets.only(right: 10), child: ListView(children: [_buildEntry(context, ChainType.DeFiChain)]))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight,
          title: Text(S.of(context).wallet_accounts_select_type),
          actions: [],
        ),
        body: _buildAccountSelectActionScreen(context));
  }
}
