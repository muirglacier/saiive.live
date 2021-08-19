import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:saiive.live/crypto/model/wallet_address.dart';
import 'package:saiive.live/crypto/wallet/defichain/defichain_wallet.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/helper/balance.dart';
import 'package:saiive.live/helper/constants.dart';
import 'package:saiive.live/network/events/wallet_sync_start_event.dart';
import 'package:saiive.live/network/model/account_balance.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/ui/accounts/account_select_address_widget.dart';
import 'package:saiive.live/ui/utils/authentication_helper.dart';
import 'package:saiive.live/ui/utils/fund_formatter.dart';
import 'package:saiive.live/ui/utils/token_icon.dart';
import 'package:saiive.live/ui/utils/transaction_fail.dart';
import 'package:saiive.live/ui/utils/transaction_success.dart';
import 'package:saiive.live/ui/widgets/loading.dart';
import 'package:saiive.live/ui/widgets/loading_overlay.dart';
import 'package:wakelock/wakelock.dart';

enum ExpertScreenAction { AccountToUtxo, UtxoToAccount }

class ExpertScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ExpertScreen();
}

class _ExpertScreen extends State<ExpertScreen> {
  List<AccountBalance> _balances;
  MixedAccountBalance _mixedAccountBalance;

  ExpertScreenAction _action = ExpertScreenAction.AccountToUtxo;

  bool _isLoading = false;

  WalletAddress _toAddress;
  var _amountController = TextEditingController(text: '1');

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

  Future _doAction(StreamController<String> stream) async {
    try {
      Wakelock.enable();

      final amount = double.parse(_amountController.text);
      final totalAmount = (amount * DefiChainConstants.COIN).toInt();
      final wallet = sl.get<DeFiChainWallet>();
      await wallet.ensureUtxoUnsafe(loadingStream: stream);

      if (_action == ExpertScreenAction.UtxoToAccount) {
        await wallet.prepareAccount(_toAddress.publicKey, totalAmount, loadingStream: stream, force: true);
      } else {
        final tx = await wallet.prepareAccountToUtxosTransactions(_toAddress.publicKey, totalAmount, loadingStream: stream, force: true);
        for (final txHex in tx.item1) {
          await wallet.createRawTxAndWait(txHex);
        }
      }

      EventTaxiImpl.singleton().fire(WalletSyncStartEvent());

      await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => TransactionSuccessScreen("", S.of(context).wallet_operation_success),
      ));

      Navigator.of(context).pop();
    } catch (e) {
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => TransactionFailScreen(S.of(context).wallet_operation_failed, error: e),
      ));
    } finally {
      Wakelock.disable();
    }
  }

  @override
  initState() {
    super.initState();

    _init();
  }

  Future _handleSetMax() async {
    setState(() {
      if (_action == ExpertScreenAction.AccountToUtxo) {
        _amountController.text = _mixedAccountBalance.tokenBalanceDisplay.toString();
      } else {
        _amountController.text = _mixedAccountBalance.utxoBalanceDisplay.toString();
      }
    });
  }

  _getActionDisplayName(ExpertScreenAction action) {
    switch (action) {
      case ExpertScreenAction.AccountToUtxo:
        return "AccountToUtxo";
      case ExpertScreenAction.UtxoToAccount:
        return "UtxoToAccount";
    }

    return null;
  }

  _buildDfiBalance(BuildContext context) {
    if (_mixedAccountBalance == null) {
      return Container();
    }
    return Card(
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
              ])
            ])));
  }

  _buildActionWidget(BuildContext context) {
    return Card(
        child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(children: [
              Container(
                  child: DropdownButton<ExpertScreenAction>(
                isExpanded: true,
                value: _action,
                items: ExpertScreenAction.values.map((e) {
                  return new DropdownMenuItem<ExpertScreenAction>(
                    value: e,
                    child: Text(_getActionDisplayName(e)),
                  );
                }).toList(),
                onChanged: (ExpertScreenAction val) {
                  setState(() {
                    _action = val;
                    _amountController.text = "1";
                  });
                },
              )),
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Expanded(
                    flex: 1,
                    child: Container(
                        child: TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(hintText: S.of(context).wallet_send_amount),
                    ))),
                SizedBox(width: 20),
                ButtonTheme(
                    height: 30,
                    minWidth: 40,
                    child: ElevatedButton(
                        child: Text(S.of(context).liquidity_add_max),
                        onPressed: () async {
                          await _handleSetMax();
                        }))
              ]),
              AccountSelectAddressWidget(
                  label: Text(S.of(context).dex_to_address, style: Theme.of(context).inputDecorationTheme.hintStyle),
                  onChanged: (newValue) {
                    setState(() {
                      _toAddress = newValue;
                    });
                  }),
              ElevatedButton(
                child: Text(S.of(context).send),
                onPressed: _toAddress != null
                    ? () async {
                        await sl.get<AuthenticationHelper>().forceAuth(context, () async {
                          final streamController = new StreamController<String>();
                          final overlay = LoadingOverlay.of(context, loadingText: streamController.stream);

                          overlay.during(_doAction(streamController));
                        });
                      }
                    : null,
              )
            ])));
  }

  _buildExpertScreen(BuildContext context) {
    if (_isLoading) {
      return Padding(padding: EdgeInsets.all(20), child: Center(child: LoadingWidget(text: S.of(context).loading)));
    }

    return Padding(
        padding: EdgeInsets.all(20),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [_buildDfiBalance(context), SizedBox(height: 20), _buildActionWidget(context)]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("Expert mode")), body: SingleChildScrollView(child: _buildExpertScreen(context)));
  }
}
