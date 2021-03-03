import 'dart:async';

import 'package:defichainwallet/appcenter/appcenter.dart';
import 'package:defichainwallet/appstate_container.dart';
import 'package:defichainwallet/crypto/chain.dart';
import 'package:defichainwallet/generated/l10n.dart';
import 'package:defichainwallet/crypto/wallet/defichain_wallet.dart';
import 'package:defichainwallet/helper/balance.dart';
import 'package:defichainwallet/helper/constants.dart';
import 'package:defichainwallet/helper/logger/LogHelper.dart';
import 'package:defichainwallet/network/dex_service.dart';
import 'package:defichainwallet/network/events/wallet_sync_start_event.dart';
import 'package:defichainwallet/network/model/account_balance.dart';
import 'package:defichainwallet/network/model/pool_pair.dart';
import 'package:defichainwallet/network/model/token_balance.dart';
import 'package:defichainwallet/network/network_service.dart';
import 'package:defichainwallet/network/pool_pair_service.dart';
import 'package:defichainwallet/service_locator.dart';
import 'package:defichainwallet/ui/utils/token_icon.dart';
import 'package:defichainwallet/ui/widgets/auto_resize_text.dart';
import 'package:defichainwallet/ui/widgets/loading_overlay.dart';
import 'package:defichainwallet/util/sharedprefsutil.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DexScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DexScreen();
  }
}

class _DexScreen extends State<DexScreen> {
  TokenBalance _selectedValueTo;
  TokenBalance _selectedValueFrom;

  double _amountFrom;
  double _amountTo;
  double _conversionRate;

  bool _testSwapFrom = false;
  bool _testSwapTo = false;
  bool _testSwapLoading = false;
  bool _insufficientFunds = false;

  List<TokenBalance> _fromTokens = [];
  List<TokenBalance> _toTokens = [];
  List<TokenBalance> _tokenMap = [];
  List<PoolPair> _poolPairs;
  bool _poolPairCondition = true;
  PoolPair _selectedPoolPair;

  var _amountFromController = TextEditingController(text: '');
  var _amountToController = TextEditingController(text: '');

  @override
  void initState() {
    super.initState();

    _amountFromController.addListener(handleChangeFrom);
    _amountToController.addListener(handleChangeTo);

    sl.get<AppCenterWrapper>().trackEvent("openSwapPage", <String, String>{});

    _init();
  }

  @override
  void dispose() {
    _amountFromController.dispose();
    _amountToController.dispose();
    super.dispose();
  }

  _init() async {
    sl.get<AppCenterWrapper>().trackEvent("openSwapPageLoadStart", <String, String>{"timestamp": DateTime.now().millisecondsSinceEpoch.toString()});
    var tokenMap = List<TokenBalance>.empty(growable: true);
    var pairs = await sl.get<IPoolPairService>().getPoolPairs('DFI');
    var uniqueTokenList = Map<String, String>();

    for (var i = 0; i < pairs.length; i++) {
      var element = pairs[i];

      var symbol = element.symbol;
      var symbolList = symbol.split('-');

      if (!uniqueTokenList.containsKey(element.idTokenA)) {
        uniqueTokenList[element.idTokenA] = symbolList[0];
      }

      if (!uniqueTokenList.containsKey(element.idTokenB)) {
        uniqueTokenList[element.idTokenB] = symbolList[1];
      }
    }

    var accountBalance = await new BalanceHelper().getDisplayAccountBalance();
    var popularSymbols = ['DFI', 'ETH', 'BTC', 'DOGE', 'LTC'];

    if (null == accountBalance.firstWhere((element) => element.token == DeFiConstants.DefiAccountSymbol, orElse: () => null)) {
      accountBalance.add(AccountBalance(token: DeFiConstants.DefiAccountSymbol, balance: 0));
    }

    uniqueTokenList.forEach((symbolKey, tokenId) {
      var account = accountBalance.firstWhere((element) => element.token == tokenId, orElse: () => null);
      var finalBalance = account != null ? account.balance : 0;

      tokenMap.add(TokenBalance(hash: tokenId, idToken: symbolKey, balance: finalBalance, isPopularToken: popularSymbols.contains(tokenId)));
    });

    _poolPairs = pairs;
    _tokenMap = tokenMap;

    setState(() {
      _fromTokens = tokenMap;
      _toTokens = tokenMap;
    });

    sl.get<AppCenterWrapper>().trackEvent("openSwapPageLoadEnd", <String, String>{"timestamp": DateTime.now().millisecondsSinceEpoch.toString()});
  }

  filter(TokenBalance valFromSymbol, TokenBalance valToSymbol) {
    var filterPoolPairList = (TokenBalance symbol) {
      var validSymbols = [];

      for (var i = 0; i < _poolPairs.length; i++) {
        var element = _poolPairs[i];

        var elSymbol = element.symbol;
        var symbolList = elSymbol.split('-');

        if (symbolList[0] == symbol.hash) {
          validSymbols.add(symbolList[1]);
        } else if (symbolList[1] == symbol.hash) {
          validSymbols.add(symbolList[0]);
        }
      }

      List<TokenBalance> tokens = [];

      _tokenMap.forEach((TokenBalance value) {
        if (validSymbols.contains(value.hash)) {
          tokens.add(value);
        }
      });

      return tokens;
    };

    if (null != valFromSymbol) {
      setState(() {
        _toTokens = filterPoolPairList(valFromSymbol);
      });
    }

    if (null != valToSymbol) {
      setState(() {
        _fromTokens = filterPoolPairList(valToSymbol);
      });
    }
  }

  findPoolPair(TokenBalance tokenA, TokenBalance tokenB) {
    if (null == tokenA || null == tokenB) {
      return;
    }

    _selectedPoolPair = _poolPairs.firstWhere(
        (element) => (element.idTokenA == tokenA.idToken && element.idTokenB == tokenB.idToken) || (element.idTokenA == tokenB.idToken && element.idTokenB == tokenA.idToken),
        orElse: () => null);
    if (null != _selectedPoolPair) {
      _poolPairCondition = _selectedPoolPair.idTokenA == tokenA.idToken && _selectedPoolPair.idTokenB == tokenB.idToken;
    }
  }

  getConversionRatio() {
    setState(() {
      _conversionRate = _amountTo / _amountFrom;
    });
  }

  checkSufficientFunds() {
    if (_selectedValueFrom == null) {
      return;
    }

    double amount = double.tryParse(_amountFromController.text);

    if (null == amount) {
      return;
    }

    amount *= DefiChainConstants.COIN;

    if (amount > _selectedValueFrom.balance) {
      setState(() {
        _insufficientFunds = true;
      });
    } else {
      setState(() {
        _insufficientFunds = false;
      });
    }
  }

  handleSetMaxFrom() {
    if (null == _selectedValueFrom || null == _selectedValueTo) {
      return;
    }

    _amountFromController.text = (_selectedValueFrom.balance / DefiChainConstants.COIN).toString();

    handleChangeFrom();
  }

  handleSetMaxTo() {
    if (null == _selectedValueFrom || null == _selectedValueTo) {
      return;
    }

    _amountToController.text = (_selectedValueTo.balance / DefiChainConstants.COIN).toString();

    handleChangeTo();
  }

  handleChangeToToken() {
    _amountTo = null;
    _amountFrom = null;

    _amountToController.text = '-';

    handleChangeTo();
  }

  handleChangeFromToken() {
    _amountTo = null;
    _amountFrom = null;

    _amountToController.text = '-';

    handleChangeFrom();
  }

  interchangeSymbols() {
    var backupTo = _selectedValueTo;
    var backupToTokens = _toTokens;

    _amountTo = null;
    _amountFrom = null;

    handleChangeFrom();

    setState(() {
      _selectedValueTo = _selectedValueFrom;
      _toTokens = _fromTokens;

      _selectedValueFrom = backupTo;
      _fromTokens = backupToTokens;
    });
  }

  handleChangeFrom() async {
    if (null == _selectedValueTo || null == _selectedValueFrom) {
      return;
    }

    if (_testSwapTo || _testSwapLoading) {
      return;
    }

    double amount = double.tryParse(_amountFromController.text);

    if (amount == 0) {
      setState(() {
        _amountFrom = null;
      });
      return;
    }
    if (_amountFrom == amount) {
      return;
    }

    _testSwapFrom = true;
    _testSwapTo = false;

    setState(() {
      _amountFrom = amount;
    });

    if (null == amount) {
      _amountToController.text = '-';
    } else {
      _testSwapLoading = true;

      var wallet = sl.get<DeFiChainWallet>();
      var pubKey = await wallet.getPublicKey();

      try {
        var swapResult = await sl.get<IDexService>().testPoolSwap('DFI', pubKey, _selectedValueFrom.hash, amount, pubKey, _selectedValueTo.hash);

        setState(() {
          _amountTo = double.tryParse(swapResult.result.split('@')[0]);
        });
        _amountToController.text = swapResult.result.split('@')[0];

        getConversionRatio();
      } on HttpException catch (e) {
        final errorMsg = e.error.error;
        LogHelper.instance.e("Error ($errorMsg)");

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error ($errorMsg)'),
        ));

        _amountToController.text = '-';
      }

      _testSwapLoading = false;
    }

    checkSufficientFunds();

    _testSwapFrom = false;
  }

  handleChangeTo() async {
    if (null == _selectedValueTo || null == _selectedValueFrom) {
      return;
    }

    if (_testSwapFrom || _testSwapLoading) {
      return;
    }

    double amount = double.tryParse(_amountToController.text);

    if (amount == 0) {
      setState(() {
        _amountTo = null;
      });
      return;
    }

    if (_amountTo == amount) {
      return;
    }

    _testSwapFrom = false;
    _testSwapTo = true;

    setState(() {
      _amountTo = amount;
    });

    if (null == amount) {
      _amountFromController.text = '-';
    } else {
      _testSwapLoading = true;

      var wallet = sl.get<DeFiChainWallet>();
      var pubKey = await wallet.getPublicKey();

      try {
        var swapResult = await sl.get<IDexService>().testPoolSwap('DFI', pubKey, _selectedValueTo.hash, amount, pubKey, _selectedValueFrom.hash);

        setState(() {
          _amountFrom = double.tryParse(swapResult.result.split('@')[0]);
        });

        _amountFromController.text = swapResult.result.split('@')[0];

        getConversionRatio();
      } on HttpException catch (e) {
        final errorMsg = e.error.error;
        LogHelper.instance.e("Error ($errorMsg)");

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error ($errorMsg)'),
        ));

        _amountFromController.text = '-';

        sl.get<AppCenterWrapper>().trackEvent(
            "swapTestError", <String, String>{"fromToken": _selectedValueFrom.hash, "toToken": _selectedValueTo.hash, "valueFrom": amount.toString(), "walletTo": pubKey});
      }

      _testSwapLoading = false;
    }
    checkSufficientFunds();

    _testSwapTo = false;
  }

  Future doSwap() async {
    final wallet = sl.get<DeFiChainWallet>();

    if (wallet.isLocked()) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(S.of(context).wallet_locked),
      ));

      return;
    }

    int valueFrom = (_amountFrom * DefiChainConstants.COIN).round();
    int maxPrice = (_conversionRate * DefiChainConstants.COIN).round();

    final walletTo = await wallet.getPublicKey();
    try {
      var streamController = StreamController<String>();
      var createSwapFuture = wallet.createAndSendSwap(_selectedValueFrom.hash, valueFrom, _selectedValueTo.hash, walletTo, maxPrice, 0, loadingStream: streamController);

      sl.get<AppCenterWrapper>().trackEvent("swap", <String, String>{
        "fromToken": _selectedValueFrom.hash,
        "toToken": _selectedValueTo.hash,
        "valueFrom": valueFrom.toString(),
        "walletTo": walletTo,
        "maxPrice": maxPrice.toString()
      });

      final overlay = LoadingOverlay.of(context, loadingText: streamController.stream);
      var tx = await overlay.during(createSwapFuture);

      sl.get<AppCenterWrapper>().trackEvent("swapSuccess", <String, String>{
        "fromToken": _selectedValueFrom.hash,
        "toToken": _selectedValueTo.hash,
        "valueFrom": valueFrom.toString(),
        "walletTo": walletTo,
        "maxPrice": maxPrice.toString(),
        "txId": tx.mintTxId
      });

      streamController.close();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(S.of(context).dex_swap_successfull),
        action: SnackBarAction(
          label: S.of(context).dex_swap_show_transaction,
          onPressed: () async {
            var _chainNet = await sl.get<SharedPrefsUtil>().getChainNetwork();
            var url = DefiChainConstants.getExplorerUrl(_chainNet, tx.txId);
            EventTaxiImpl.singleton().fire(WalletSyncStartEvent());
            if (await canLaunch(url)) {
              await launch(url);
            }
          },
        ),
      ));
    } on HttpException catch (e) {
      final errorMsg = e.error.error;
      LogHelper.instance.e("Error saving tx...($errorMsg)");

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error occured commiting the tx...($errorMsg)'),
      ));
      sl.get<AppCenterWrapper>().trackEvent("swawFailureHandled", <String, String>{
        "fromToken": _selectedValueFrom.hash,
        "toToken": _selectedValueTo.hash,
        "valueFrom": valueFrom.toString(),
        "walletTo": walletTo,
        "maxPrice": maxPrice.toString(),
        "error": errorMsg
      });
    } catch (e) {
      LogHelper.instance.e("Error...", e);
      final errorMsg = e.toString();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error occured commiting the tx...($errorMsg)'),
      ));

      sl.get<AppCenterWrapper>().trackEvent("swapFailure", <String, String>{
        "fromToken": _selectedValueFrom.hash,
        "toToken": _selectedValueTo.hash,
        "valueFrom": valueFrom.toString(),
        "walletTo": walletTo,
        "maxPrice": maxPrice.toString(),
        "error": e.toString()
      });
    }
  }

  _buildDropdownListItem(TokenBalance e) {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.only(right: 10),
          child: TokenIcon(e.hash),
        ),
        Expanded(
          flex: 1,
          child: AutoSizeText(
            e.hash,
            style: Theme.of(context).textTheme.headline3,
            maxLines: 1,
          ),
        ),
        Expanded(
          flex: 4,
          child: Text(e.balanceDisplayRounded, textAlign: TextAlign.right),
        )
      ],
    );
  }

  @override
  Widget build(Object context) {
    return Scaffold(
        appBar: AppBar(title: Text(S.of(context).dex)),
        body: SingleChildScrollView(
            child: Padding(
                padding: EdgeInsets.all(30),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Expanded(
                        flex: 1,
                        child: Container(
                            height: 60,
                            child: DropdownButton<TokenBalance>(
                              isExpanded: true,
                              hint: Text(S.of(context).dex_from_token),
                              value: _selectedValueFrom,
                              items: _fromTokens.map((e) {
                                return new DropdownMenuItem<TokenBalance>(
                                  value: e,
                                  child: _buildDropdownListItem(e),
                                );
                              }).toList(),
                              onChanged: (TokenBalance val) {
                                setState(() {
                                  filter(val, _selectedValueTo);

                                  _selectedValueFrom = val;

                                  findPoolPair(_selectedValueFrom, _selectedValueTo);
                                  handleChangeFromToken();
                                });
                              },
                            ))),
                    SizedBox(width: 20),
                    ButtonTheme(
                        height: 30,
                        minWidth: 40,
                        child: ElevatedButton(
                            child: Text(S.of(context).dex_add_max),
                            onPressed: () {
                              handleSetMaxFrom();
                            }))
                  ]),
                  TextField(
                    controller: _amountFromController,
                    decoration: InputDecoration(hintText: S.of(context).dex_from_amount),
                  ),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(primary: StateContainer.of(context).curTheme.backgroundColor),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
                        SizedBox(width: 10),
                        Text(
                          '<->',
                          style: TextStyle(color: StateContainer.of(context).curTheme.text),
                        ),
                      ]),
                      onPressed: () {
                        interchangeSymbols();
                      }),
                  Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Expanded(
                        flex: 1,
                        child: Container(
                            height: 60,
                            child: DropdownButton<TokenBalance>(
                              isExpanded: true,
                              hint: Text(S.of(context).dex_to_token),
                              value: _selectedValueTo,
                              items: _toTokens.map((e) {
                                return new DropdownMenuItem<TokenBalance>(
                                  value: e,
                                  child: _buildDropdownListItem(e),
                                );
                              }).toList(),
                              onChanged: (TokenBalance val) {
                                setState(() {
                                  filter(_selectedValueFrom, val);

                                  _selectedValueTo = val;

                                  findPoolPair(_selectedValueFrom, _selectedValueTo);
                                  handleChangeToToken();
                                });
                              },
                            ))),
                    SizedBox(width: 20),
                    ButtonTheme(
                        height: 30,
                        minWidth: 40,
                        child: ElevatedButton(
                            child: Text(S.of(context).dex_add_max),
                            onPressed: () {
                              handleSetMaxTo();
                            }))
                  ]),
                  TextField(
                    controller: _amountToController,
                    decoration: InputDecoration(hintText: S.of(context).dex_to_amount),
                  ),
                  if (_insufficientFunds)
                    Column(children: [
                      Padding(padding: EdgeInsets.only(top: 10)),
                      Text(S.of(context).dex_insufficient_funds, style: Theme.of(context).textTheme.headline6),
                    ]),
                  if (_selectedPoolPair != null && _amountTo != null && _amountFrom != null && _insufficientFunds == false)
                    Column(children: [
                      SizedBox(height: 10),
                      Row(children: [
                        Expanded(flex: 4, child: Text(S.of(context).dex_price)),
                        Expanded(
                            flex: 6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(_conversionRate.toStringAsFixed(8) + ' ' + _selectedValueTo.hash + ' per ' + _selectedValueFrom.hash, textAlign: TextAlign.right),
                                Text((1 / _conversionRate).toStringAsFixed(8) + ' ' + _selectedValueFrom.hash + ' per ' + _selectedValueTo.hash, textAlign: TextAlign.right),
                              ],
                            )),
                      ]),
                      Divider(
                        thickness: 2,
                      ),
                      Row(children: [
                        Expanded(flex: 4, child: Text(S.of(context).dex_amount)),
                        Expanded(
                            flex: 6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(_amountTo.toString()),
                              ],
                            )),
                      ]),
                      Divider(
                        thickness: 2,
                      ),
                      Row(children: [
                        Expanded(flex: 4, child: Text(S.of(context).dex_commission)),
                        Expanded(
                            flex: 6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(_selectedPoolPair.commission.toString()),
                              ],
                            )),
                      ]),
                      ElevatedButton(
                        child: Text(S.of(context).dex_swap),
                        onPressed: () async {
                          await doSwap();
                        },
                      )
                    ])
                ]))));
  }
}
