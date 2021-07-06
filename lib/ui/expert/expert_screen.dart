import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/helper/balance.dart';
import 'package:saiive.live/network/model/account_balance.dart';
import 'package:saiive.live/ui/utils/fund_formatter.dart';
import 'package:saiive.live/ui/utils/token_icon.dart';
import 'package:saiive.live/ui/widgets/loading.dart';

class ExpertScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ExpertScreen();
}

class _ExpertScreen extends State<ExpertScreen> {
  List<AccountBalance> _balances;
  MixedAccountBalance _mixedAccountBalance;

  bool _isLoading = false;

  _init() async {
    setState(() {
      _isLoading = true;
    });
    _balances = await new BalanceHelper().getDisplayAccountBalance(onlyDfi: true);

    for (final bal in _balances) {
      if (bal is MixedAccountBalance) {
        _mixedAccountBalance = bal;
        break;
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  initState() {
    super.initState();

    _init();
  }

  _buildDfiBalance(BuildContext context) {
    if (_mixedAccountBalance == null) {
      return Container();
    }
    return Expanded(
        child: Card(
            child: ListTile(
                leading: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: [TokenIcon(_mixedAccountBalance.token)]),
                title: Column(children: [
                  Row(children: [
                    Text(
                      _mixedAccountBalance.token,
                      style: Theme.of(context).textTheme.headline3,
                    ),
                    Expanded(
                        child: AutoSizeText(
                      FundFormatter.format(_mixedAccountBalance.balanceDisplay),
                      style: Theme.of(context).textTheme.headline3,
                      textAlign: TextAlign.right,
                      maxLines: 1,
                    )),
                  ]),
                  Container(height: 10),
                  Row(children: [
                    Text(
                      'UTXO',
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    Expanded(
                        child: AutoSizeText(
                      FundFormatter.format(_mixedAccountBalance.utxoBalanceDisplay),
                      style: Theme.of(context).textTheme.bodyText1,
                      textAlign: TextAlign.right,
                      maxLines: 1,
                    )),
                  ]),
                  Row(children: [
                    Text(
                      'Token',
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    Expanded(
                        child: AutoSizeText(
                      FundFormatter.format(_mixedAccountBalance.tokenBalanceDisplay),
                      style: Theme.of(context).textTheme.bodyText1,
                      textAlign: TextAlign.right,
                      maxLines: 1,
                    )),
                  ]),
                ]))));
  }

  _buildExpertScreen(BuildContext context) {
    if (_isLoading) {
      return LoadingWidget(text: S.of(context).loading);
    }

    return Padding(padding: EdgeInsets.all(20), child: Row(children: [_buildDfiBalance(context), SizedBox(height: 20)]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("Expert mode")), body: SingleChildScrollView(child: _buildExpertScreen(context)));
  }
}
