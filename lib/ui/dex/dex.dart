import 'dart:async';
import 'dart:io';

import 'package:saiive.live/appcenter/appcenter.dart';
import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/model/wallet_address.dart';
import 'package:saiive.live/crypto/wallet/address_type.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/crypto/wallet/defichain/defichain_wallet.dart';
import 'package:saiive.live/helper/balance.dart';
import 'package:saiive.live/helper/constants.dart';
import 'package:saiive.live/helper/logger/LogHelper.dart';
import 'package:saiive.live/network/dex_service.dart';
import 'package:saiive.live/network/events/wallet_sync_start_event.dart';
import 'package:saiive.live/network/model/account_balance.dart';
import 'package:saiive.live/network/model/pool_pair.dart';
import 'package:saiive.live/network/model/token_balance.dart';
import 'package:saiive.live/network/network_service.dart';
import 'package:saiive.live/network/pool_pair_service.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/services/health_service.dart';
import 'package:saiive.live/ui/accounts/account_select_address_widget.dart';
import 'package:saiive.live/ui/utils/authentication_helper.dart';
import 'package:saiive.live/ui/utils/fund_formatter.dart';
import 'package:saiive.live/ui/utils/token_icon.dart';
import 'package:saiive.live/ui/utils/transaction_fail.dart';
import 'package:saiive.live/ui/utils/transaction_success.dart';
import 'package:saiive.live/ui/widgets/auto_resize_text.dart';
import 'package:saiive.live/ui/widgets/loading.dart';
import 'package:saiive.live/ui/widgets/loading_overlay.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:saiive.live/ui/widgets/wallet_return_address_widget.dart';
import 'package:wakelock/wakelock.dart';

class DexScreen extends StatefulWidget {
  const DexScreen({Key key}) : super(key: key);

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
  double _estimatedSwapAmount;
  double _aToBPrice;

  bool _insufficientFunds = false;

  bool _isLoading = true;

  List<TokenBalance> _fromTokens = [];
  List<TokenBalance> _toTokens = [];
  List<TokenBalance> _tokenMap = [];
  List<PoolPair> _poolPairs;
  PoolPair _selectedPoolPair;

  var _amountFromController = TextEditingController(text: '');
  var _amountToController = TextEditingController(text: '');

  WalletAddress _toAddress;
  String _returnAddress;

  void resetForm() {
    setState(() {
      _selectedPoolPair = null;

      _selectedValueTo = null;
      _selectedValueFrom = null;

      _amountFrom = 0;
      _amountTo = 0;
      _conversionRate = 0;
      _estimatedSwapAmount = 0;
      _aToBPrice = 0;

      _amountFromController.clear();
      _amountToController.clear();
    });
  }

  @override
  void initState() {
    super.initState();

    _amountFromController.addListener(handleChangeFrom);
    _amountToController.addListener(handleChangeTo);

    sl.get<AppCenterWrapper>().trackEvent("openSwapPage", <String, String>{});
    sl.get<IHealthService>().checkHealth(context);

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

    var accountBalance = await new BalanceHelper().getDisplayAccountBalance(onlyDfi: true);
    var popularSymbols = ['DFI', 'ETH', 'BTC', 'DOGE', 'LTC'];

    if (null == accountBalance.firstWhere((element) => element.token == DeFiConstants.DefiAccountSymbol, orElse: () => null)) {
      accountBalance.add(AccountBalance(token: DeFiConstants.DefiAccountSymbol, balance: 0, chain: ChainType.DeFiChain));
    }

    uniqueTokenList.forEach((symbolKey, tokenId) {
      var account = accountBalance.firstWhere((element) => element.token == tokenId, orElse: () => null);
      var finalBalance = account != null ? account.balance : 0;

      if (account != null) {
        tokenMap.add(TokenBalance(hash: tokenId, idToken: symbolKey, balance: finalBalance, isPopularToken: popularSymbols.contains(tokenId), displayName: account.tokenDisplay));
      } else {
        tokenMap.add(TokenBalance(hash: tokenId, idToken: symbolKey, balance: finalBalance, isPopularToken: popularSymbols.contains(tokenId), displayName: "d" + tokenId));
      }
    });

    _poolPairs = pairs;
    _tokenMap = tokenMap;

    setState(() {
      _fromTokens = tokenMap;
      _toTokens = tokenMap;
      _isLoading = false;
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
      _aToBPrice = _selectedValueTo.idToken == _selectedPoolPair.idTokenA ?
        _selectedPoolPair.reserveA / _selectedPoolPair.reserveB :
        _selectedPoolPair.reserveB / _selectedPoolPair.reserveA;
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

    if (DeFiConstants.isDfiToken(_selectedValueFrom.hash)) {
      final value = _selectedValueFrom.balance - DeFiChainWallet.MinKeepUTXO;
      _amountFromController.text = (value / DefiChainConstants.COIN).toString();
    } else {
      _amountFromController.text = (_selectedValueFrom.balance / DefiChainConstants.COIN).toString();
    }

    handleChangeFrom();
  }

  handleSetMaxTo() {
    if (null == _selectedValueFrom || null == _selectedValueTo) {
      return;
    }

    if (DeFiConstants.isDfiToken(_selectedValueTo.hash)) {
      final value = _selectedValueTo.balance - DeFiChainWallet.MinKeepUTXO;
      _amountFromController.text = (value / DefiChainConstants.COIN).toString();
    } else {
      _amountFromController.text = (_selectedValueTo.balance / DefiChainConstants.COIN).toString();
    }

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

    setState(() {
      _amountFrom = amount;
    });

    if (null == amount) {
      _amountToController.text = '-';
    } else {
      var amount = _selectedPoolPair.reserveA / _selectedPoolPair.reserveB;

      setState(() {
        _amountTo = amount;
        _estimatedSwapAmount = calculateEstimatedAmount(_amountFrom, _selectedPoolPair.reserveA, _aToBPrice);
      });
      _amountToController.text = amount.toString();

      getConversionRatio();
    }

    checkSufficientFunds();
  }

  handleChangeTo() async {
    if (null == _selectedValueTo || null == _selectedValueFrom) {
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

    setState(() {
      _amountTo = amount;
    });

    if (null == amount) {
      _amountFromController.text = '-';
    } else {
      // var swapResult = await sl.get<IDexService>().testPoolSwap('DFI', pubKey, _selectedValueTo.hash, amount, pubKey, _selectedValueFrom.hash);
      var amount = _selectedPoolPair.reserveB / _selectedPoolPair.reserveA;

      setState(() {
        _amountFrom = amount;
        _estimatedSwapAmount = calculateEstimatedAmount(_amountFrom, _selectedPoolPair.reserveA, _selectedPoolPair.reserveB / _selectedPoolPair.reserveA);
      });

      _amountFromController.text = amount.toString();

      getConversionRatio();
    }
    checkSufficientFunds();
  }

  calculateEstimatedAmount(double tokenAAmount, double reserveA, double price)
  {
    var slippage = 1 - (tokenAAmount / reserveA);
    return tokenAAmount * price * slippage;
  }

  Future doSwap() async {
    Wakelock.enable();

    final wallet = sl.get<DeFiChainWallet>();

    int valueFrom = (_amountFrom * DefiChainConstants.COIN).round();
    //int maxPrice = (_conversionRate * DefiChainConstants.COIN).round();

    final walletTo = _toAddress.publicKey;
    try {
      var streamController = StreamController<String>();
      var createSwapFuture = wallet.createAndSendSwap(_selectedValueFrom.hash, valueFrom, _selectedValueTo.hash, walletTo, 9223372036854775807, 9223372036854775807,
          returnAddress: _returnAddress, loadingStream: streamController);

      sl
          .get<AppCenterWrapper>()
          .trackEvent("swap", <String, String>{"fromToken": _selectedValueFrom.hash, "toToken": _selectedValueTo.hash, "valueFrom": valueFrom.toString(), "walletTo": walletTo});

      final overlay = LoadingOverlay.of(context, loadingText: streamController.stream);
      var tx = await overlay.during(createSwapFuture);

      sl.get<AppCenterWrapper>().trackEvent("swapSuccess",
          <String, String>{"fromToken": _selectedValueFrom.hash, "toToken": _selectedValueTo.hash, "valueFrom": valueFrom.toString(), "walletTo": walletTo, "txId": tx.mintTxId});

      streamController.close();

      EventTaxiImpl.singleton().fire(WalletSyncStartEvent());
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => TransactionSuccessScreen(ChainType.DeFiChain, tx.txId, S.of(context).dex_swap_successfull),
      ));

      resetForm();
    } catch (e) {
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => TransactionFailScreen(S.of(context).wallet_operation_failed, ChainType.DeFiChain, error: e),
      ));

      sl.get<AppCenterWrapper>().trackEvent("swapFailure",
          <String, String>{"fromToken": _selectedValueFrom.hash, "toToken": _selectedValueTo.hash, "valueFrom": valueFrom.toString(), "walletTo": walletTo, "error": e.toString()});
    } finally {
      Wakelock.disable();
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
            e.displayName,
            style: Theme.of(context).textTheme.headline3,
            maxLines: 1,
          ),
        ),
        Expanded(
            flex: 1,
            child: AutoSizeText(FundFormatter.format(e.balance / DefiChainConstants.COIN), style: Theme.of(context).textTheme.headline3, maxLines: 1, textAlign: TextAlign.right))
      ],
    );
  }

  Widget _buildDexPage(BuildContext context) {
    if (_isLoading) {
      return LoadingWidget(text: S.of(context).loading);
    } else {
      return SingleChildScrollView(
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
                TextField(controller: _amountFromController, decoration: InputDecoration(hintText: S.of(context).dex_from_amount), keyboardType: TextInputType.number),
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
                TextField(controller: _amountToController, decoration: InputDecoration(hintText: S.of(context).dex_to_amount), keyboardType: TextInputType.number),
                SizedBox(height: 20),
                AccountSelectAddressWidget(
                    label: Text(S.of(context).dex_to_address, style: Theme.of(context).inputDecorationTheme.hintStyle),
                    onChanged: (newValue) {
                      setState(() {
                        _toAddress = newValue;
                      });
                    }),
                if (_insufficientFunds)
                  Column(children: [
                    Padding(padding: EdgeInsets.only(top: 10)),
                    Text(S.of(context).dex_insufficient_funds, style: Theme.of(context).textTheme.headline6),
                  ]),
                if (_selectedPoolPair != null && _amountTo != null && _amountFrom != null && !_insufficientFunds && _toAddress != null)
                  Column(children: [
                    SizedBox(height: 10),
                    Row(children: [
                      Expanded(flex: 4, child: Text(S.of(context).dex_price)),
                      Expanded(
                          flex: 6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(FundFormatter.format(_conversionRate) + ' ' + _selectedValueTo.hash + ' per ' + _selectedValueFrom.hash, textAlign: TextAlign.right),
                              Text(FundFormatter.format(1 / _conversionRate) + ' ' + _selectedValueFrom.hash + ' per ' + _selectedValueTo.hash, textAlign: TextAlign.right),
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
                              Text(_estimatedSwapAmount.toString()),
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
                    WalletReturnAddressWidget(
                      onChanged: (v) {
                        setState(() {
                          _returnAddress = v;
                        });
                      },
                    ),
                    SizedBox(
                      width: 20,
                      height: 20,
                    ),
                    ElevatedButton(
                      child: Text(S.of(context).dex_swap),
                      onPressed: () async {
                        await sl.get<AuthenticationHelper>().forceAuth(context, () async {
                          await doSwap();
                        });
                      },
                    )
                  ])
              ])));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight,
            title: Row(children: [
              if (Platform.isAndroid || Platform.isIOS || Platform.isFuchsia)
                Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () {
                        var key = StateContainer.of(context).scaffoldKey;
                        key.currentState.openDrawer();
                      },
                      child: Icon(Icons.view_headline, size: 26.0, color: Theme.of(context).appBarTheme.actionsIconTheme.color),
                    )),
              Text(S.of(context).dex)
            ])),
        body: _buildDexPage(context));
  }
}
