import 'package:defichainwallet/appstate_container.dart';
import 'package:defichainwallet/crypto/chain.dart';
import 'package:defichainwallet/crypto/database/wallet_database.dart';
import 'package:defichainwallet/crypto/wallet/defichain_wallet.dart';
import 'package:defichainwallet/generated/l10n.dart';
import 'package:defichainwallet/helper/constants.dart';
import 'package:defichainwallet/network/model/transaction.dart';
import 'package:defichainwallet/service_locator.dart';
import 'package:defichainwallet/ui/wallet/wallet_receive.dart';
import 'package:defichainwallet/ui/wallet/wallet_send.dart';
import 'package:defichainwallet/ui/widgets/buttons.dart';
import 'package:defichainwallet/ui/widgets/loading.dart';
import 'package:defichainwallet/util/sharedprefsutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class WalletTokenScreen extends StatefulWidget {
  final String token;
  WalletTokenScreen(this.token);

  @override
  State<StatefulWidget> createState() {
    return _WalletTokenScreen();
  }
}

class _WalletTokenScreen extends State<WalletTokenScreen>
    with TickerProviderStateMixin {
  dynamic _balance;
  bool _balanceLoaded = false;
  bool _balanceRefreshing = false;
  AnimationController _controller;

  bool _transactionsLoading = false;
  List<Transaction> _transactions = [];

  ChainNet _chainNet;

  Future loadAccountBalance() async {
    setState(() {
      _balanceRefreshing = true;
    });
    _controller.forward();

    final db = sl.get<IWalletDatabase>();

    if (widget.token == DeFiConstants.DefiTokenSymbol) {
      _balance = await db.getAccountBalance(widget.token);
      _balance += await db.getAccountBalance(DeFiConstants.DefiTokenSymbol);
    } else {
      _balance = await db.getAccountBalance(widget.token);
    }

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _balanceLoaded = true;
      _balanceRefreshing = false;
      _controller.stop();
      _controller.reset();
    });
  }

  Future loadTransactions() async {
    setState(() {
      _transactionsLoading = true;
    });
    final db = sl.get<IWalletDatabase>();
    _transactions = await db.getTransactions();

    setState(() {
      _transactionsLoading = false;
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
    loadTransactions();
  }

  buildBalanceCard(BuildContext context) {
    return SizedBox(
        height: 100,
        child: Card(
            child: ListTile(
          title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(S.of(context).wallet_token_available_balance,
                    style: TextStyle(fontSize: 12)),
                SizedBox(height: 5),
                Text((_balance).toStringAsFixed(8),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500))
              ]),
          trailing: RotationTransition(
              turns: Tween(begin: 0.0, end: 1.0).animate(_controller),
              child: IconButton(
                icon: Icon(Icons.refresh,
                    color: _balanceRefreshing
                        ? Theme.of(context).primaryColor
                        : StateContainer.of(context).curTheme.text),
                onPressed: () async {
                  await loadAccountBalance();
                },
              )),
        )));
  }

  buildTransaction(BuildContext context, Transaction tx) {
    return Padding(
        padding: EdgeInsets.only(left: 30, right: 30),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                      child: new Text(
                          S.of(context).wallet_token_show_in_explorer,
                          style:
                              TextStyle(color: Theme.of(context).primaryColor)),
                      onTap: () => launch(DefiChainConstants.getExplorerUrl(
                          _chainNet, tx.mintTxId))),
                  Text(tx.correctValue.toString())
                ],
              ),
              SizedBox(height: 5),
              Text(tx.mintTxId, style: TextStyle(fontSize: 8)),
              Divider()
            ]));
  }

  buildTransactionsList(BuildContext context) {
    return Expanded(
        child: Card(
            child: Column(children: [
      ListTile(
        title: Text(S.of(context).wallet_token_transactions,
            style: TextStyle(fontSize: 15)),
      ),
      Flexible(
          child: ListView.builder(
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: _transactions.length,
              itemBuilder: (context, index) {
                final tx = _transactions[index];
                return buildTransaction(context, tx);
              }))
    ])));
  }

  buildActions(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.only(right: 10, left: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
              padding: EdgeInsets.only(right: 10),
              child: AppButton.buildAppButton(
                  context, AppButtonType.PRIMARY, S.of(context).send,
                  icon: Icons.arrow_upward,
                  width: width / 2 - 20, onPressed: () {
                final token = widget.token;
                if (token != DeFiConstants.DefiTokenSymbol) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        "Sending funds for '$token' is currently not supported!"),
                  ));
                } else {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) =>
                          WalletSendScreen(widget.token)));
                }
              })),
          AppButton.buildAppButton(
              context, AppButtonType.PRIMARY, S.of(context).receive,
              icon: Icons.arrow_downward,
              width: width / 2 - 20, onPressed: () async {
            var wallet = sl.get<DeFiChainWallet>();
            var pubKey = await wallet.getPublicKey();
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) =>
                    WalletReceiveScreen(pubKey: pubKey)));
          })
        ],
      ),
    );
  }

  buildView(BuildContext context) {
    if (!_balanceLoaded) {
      return LoadingWidget(text: S.of(context).loading);
    }

    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          buildActions(context),
          buildBalanceCard(context),
          buildTransactionsList(context)
        ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.token)),
      body: buildView(context),
    );
  }
}
