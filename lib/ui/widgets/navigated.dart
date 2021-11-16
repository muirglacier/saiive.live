import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/helper/balance.dart';
import 'package:saiive.live/network/model/account_balance.dart';
import 'package:saiive.live/network/model/loan_vault.dart';
import 'package:saiive.live/network/model/loan_vault_collateral_amount.dart';
import 'package:saiive.live/ui/utils/fund_formatter.dart';
import 'package:saiive.live/ui/utils/token_icon.dart';
import 'package:saiive.live/ui/widgets/auto_resize_text.dart';
import 'package:saiive.live/ui/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class Navigated extends StatefulWidget {
  final navigationKey = GlobalKey();
  final scaffoldKey = GlobalKey();
  final Widget child;

  Navigated({this.child});

  @override
  State<StatefulWidget> createState() {
    return _Navigated();
  }
}

class _Navigated extends State<Navigated> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: widget.scaffoldKey,
      body: Container(
          color:
          StateContainer.of(context).curTheme.cardBackgroundColor,
          child: Navigator(
            onGenerateRoute: (RouteSettings settings) {
              return MaterialPageRoute(
                settings: settings,
                builder: (BuildContext context) {
                  return widget.child;
                },
              );
            },
          )),
    );
  }
}
