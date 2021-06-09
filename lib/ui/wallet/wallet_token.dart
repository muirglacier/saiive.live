import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/helper/balance.dart';
import 'package:saiive.live/helper/constants.dart';
import 'package:saiive.live/network/model/account_balance.dart';
import 'package:saiive.live/network/model/account_history.dart';
import 'package:saiive.live/network/model/transaction.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/services/wallet_service.dart';
import 'package:saiive.live/ui/wallet/wallet_receive.dart';
import 'package:saiive.live/ui/wallet/wallet_send.dart';
import 'package:saiive.live/ui/widgets/buttons.dart';
import 'package:saiive.live/ui/widgets/loading.dart';
import 'package:saiive.live/util/sharedprefsutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class WalletTokenScreen extends StatefulWidget {
  final String token;
  final ChainType chainType;
  final String displayName;
  final AccountBalance accountBalance;
  WalletTokenScreen(this.token, this.chainType, this.displayName, this.accountBalance);

  @override
  State<StatefulWidget> createState() {
    return _WalletTokenScreen();
  }
}

class _WalletTokenScreen extends State<WalletTokenScreen> with TickerProviderStateMixin {
  AccountBalance _balance;
  bool _balanceLoaded = false;
  bool _balanceRefreshing = false;
  bool _transactionIncludingRewards = false;
  AnimationController _controller;

  bool _transactionsLoading = false;
  List<Transaction> _transactions = [];
  List<AccountHistory> _history = [];

  ChainNet _chainNet;

  Future loadAccountHistory({bool includingRewards = false}) async {
    setState(() {
      _transactionsLoading = true;
    });

    var history = await sl.get<IWalletService>().getAccountHistory(widget.chainType, widget.token, includingRewards);

    setState(() {
      _history = history;
      _transactionsLoading = false;
    });
  }

  Future loadAccountBalance() async {
    setState(() {
      _balanceRefreshing = true;
    });
    _controller.forward();
    _balance = await BalanceHelper().getAccountBalance(widget.token, widget.chainType);
    loadAccountHistory(includingRewards: _transactionIncludingRewards);

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _balanceLoaded = true;
      _balanceRefreshing = false;
      _controller.stop();
      _controller.reset();
    });
  }

  void loadChainNetwork() async {
    _chainNet = await sl.get<SharedPrefsUtil>().getChainNetwork();
  }

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _controller.addListener(() {
      if (_controller.isCompleted && _balanceRefreshing) {
        _controller.repeat();
      }
    });
    super.initState();

    loadChainNetwork();
    loadAccountBalance();
    loadAccountHistory();
  }

  buildBalanceCard(BuildContext context) {
    return Card(
        child: SizedBox(
            height: 100,
            child: ListTile(
              title: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(S.of(context).wallet_token_available_balance, style: TextStyle(fontSize: 12)),
                SizedBox(height: 5),
                Text((_balance.balanceDisplay).toStringAsFixed(8), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500))
              ]),
              trailing: RotationTransition(
                  turns: Tween(begin: 0.0, end: 1.0).animate(_controller),
                  child: IconButton(
                    icon: Icon(Icons.refresh, color: _balanceRefreshing ? Theme.of(context).primaryColor : StateContainer.of(context).curTheme.text),
                    onPressed: () async {
                      await loadAccountBalance();
                    },
                  )),
            )));
  }

  buildAccountHistory(BuildContext context, AccountHistory history) {
    return Padding(
        padding: EdgeInsets.only(left: 30, right: 30),
        child: _transactionsLoading
            ? LoadingWidget(text: S.of(context).loading)
            : Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(history.type), flex: 1),
                    Expanded(child: Text((history.getBalance(widget.token) / DefiChainConstants.COIN).toStringAsFixed(8), textAlign: TextAlign.right), flex: 2),
                    if (history.txid != null)
                      Expanded(
                          child: InkWell(
                              child: new Text(S.of(context).wallet_token_show_in_explorer, style: TextStyle(color: Theme.of(context).primaryColor), textAlign: TextAlign.right),
                              onTap: () => launch(DefiChainConstants.getExplorerUrl(_chainNet, history.txid))),
                          flex: 1),
                  ],
                ),
                SizedBox(height: 5),
                Text(history.blockHash, style: TextStyle(fontSize: 8)),
                Divider()
              ]));
  }

  buildAccountHistoryList(BuildContext context) {
    if (_history.length == 0) {
      return LoadingWidget(text: S.of(context).loading);
    }

    return Card(
        child: Column(mainAxisAlignment: MainAxisAlignment.start, mainAxisSize: MainAxisSize.max, children: [
      ListTile(
        title: Text(S.of(context).wallet_token_transactions, style: TextStyle(fontSize: 15)),
      ),
      Expanded(
          child: Scrollbar(
              child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: _history.length,
                  itemBuilder: (context, index) {
                    final history = _history[index];
                    return buildAccountHistory(context, history);
                  })))
    ]));
  }

  buildActions(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
              padding: EdgeInsets.only(right: 10),
              child: AppButton.buildAppButton(context, AppButtonType.PRIMARY, S.of(context).send, icon: Icons.arrow_upward, width: width / 2 - 10, onPressed: () async {
                await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => WalletSendScreen(widget.token, widget.chainType)));

                Navigator.of(context).pop();
              })),
          AppButton.buildAppButton(context, AppButtonType.PRIMARY, S.of(context).receive, icon: Icons.arrow_downward, width: width / 2 - 10, onPressed: () async {
            var wallet = sl.get<IWalletService>();
            var pubKey = await wallet.getPublicKey(widget.chainType);
            await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => WalletReceiveScreen(pubKey: pubKey, chain: widget.chainType)));
          })
        ],
      ),
    );
  }

  buildView(BuildContext context) {
    if (!_balanceLoaded) {
      return LoadingWidget(text: S.of(context).loading);
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.start, children: [
      buildActions(context),
      buildBalanceCard(context),
      CheckboxListTile(
        title: Text("Incl. Rewards"),
        value: _transactionIncludingRewards,
        activeColor: StateContainer.of(context).curTheme.primary,
        onChanged: (newValue) {
          setState(() {
            _history = [];
            _transactionIncludingRewards = newValue;
          });

          loadAccountHistory(includingRewards: newValue);
        },
        controlAffinity: ListTileControlAffinity.leading, //  <-- leading Checkbox
      ),
      Expanded(child: buildAccountHistoryList(context))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight, title: Text(widget.displayName)),
      body: buildView(context),
    );
  }
}
