import 'dart:async';

import 'package:defichainwallet/appcenter/appcenter.dart';
import 'package:defichainwallet/appstate_container.dart';
import 'package:defichainwallet/crypto/chain.dart';
import 'package:defichainwallet/crypto/wallet/defichain_wallet.dart';
import 'package:defichainwallet/generated/l10n.dart';
import 'package:defichainwallet/helper/balance.dart';
import 'package:defichainwallet/helper/constants.dart';
import 'package:defichainwallet/helper/logger/LogHelper.dart';
import 'package:defichainwallet/network/events/wallet_sync_start_event.dart';
import 'package:defichainwallet/network/model/account_balance.dart';
import 'package:defichainwallet/network/model/pool_pair.dart';
import 'package:defichainwallet/network/model/token_balance.dart';
import 'package:defichainwallet/network/network_service.dart';
import 'package:defichainwallet/network/pool_pair_service.dart';
import 'package:defichainwallet/network/response/error_response.dart';
import 'package:defichainwallet/service_locator.dart';
import 'package:defichainwallet/ui/utils/token_icon.dart';
import 'package:defichainwallet/ui/widgets/auto_resize_text.dart';
import 'package:defichainwallet/ui/widgets/loading.dart';
import 'package:defichainwallet/ui/widgets/loading_overlay.dart';
import 'package:defichainwallet/util/sharedprefsutil.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class LiquidityAddScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LiquidityAddScreen();
  }
}

class _LiquidityAddScreen extends State<LiquidityAddScreen> {
  TokenBalance _selectedTokenA;
  TokenBalance _selectedTokenB;

  double _amountTokenA;
  double _amountTokenB;
  double _poolSharePercentage;
  double _conversionRate;

  bool _insufficientFunds = false;
  bool _isLoading = true;

  List<TokenBalance> _fromTokens = [];
  List<TokenBalance> _toTokens = [];
  List<TokenBalance> _tokenMap = [];
  List<PoolPair> _poolPairs;
  bool _poolPairCondition = true;
  PoolPair _selectedPoolPair;

  var _amountTokenAController = TextEditingController(text: '');
  var _amountTokenBController = TextEditingController(text: '');

  @override
  void initState() {
    super.initState();

    _amountTokenAController.addListener(handleChangeTokenA);
    _amountTokenBController.addListener(handleChangeTokenB);

    sl.get<AppCenterWrapper>().trackEvent("openAddLiquidity", <String, String>{});

    _init();
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

  _init() async {
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
      _isLoading = false;
    });
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

  handleChangeTokenBSelection() {
    _amountTokenB = null;
    _amountTokenA = null;

    _amountTokenBController.text = '-';

    handleChangeTokenB();
  }

  handleChangeTokenASelection() {
    _amountTokenB = null;
    _amountTokenA = null;

    _amountTokenBController.text = '-';

    handleChangeTokenA();
  }

  getConversionRatio() {
    setState(() {
      _conversionRate = _poolPairCondition
          ? _selectedPoolPair.reserveBDivReserveA != 0
              ? _selectedPoolPair.reserveB / _selectedPoolPair.reserveA
              : 0
          : _selectedPoolPair.reserveADivReserveB != 0
              ? _selectedPoolPair.reserveA / _selectedPoolPair.reserveB
              : 0;
    });
  }

  handleSetMaxTokenA() {
    if (null == _selectedTokenB || null == _selectedTokenA) {
      return;
    }

    _amountTokenAController.text = (_selectedTokenA.balance / DefiChainConstants.COIN).toString();

    handleChangeTokenA();
  }

  handleSetMaxTokenB() {
    if (null == _selectedTokenB || null == _selectedTokenA) {
      return;
    }

    _amountTokenBController.text = (_selectedTokenB.balance / DefiChainConstants.COIN).toString();

    handleChangeTokenB();
  }

  handleChangeTokenA() async {
    if (null == _selectedTokenB || null == _selectedTokenA) {
      return;
    }

    double amount = double.tryParse(_amountTokenAController.text);

    if (amount == 0) {
      setState(() {
        _amountTokenA = null;
      });
      return;
    }
    if (_amountTokenA == amount) {
      return;
    }

    setState(() {
      _amountTokenA = amount;
    });

    if (null == amount) {
      _amountTokenBController.text = '';
    } else {
      getConversionRatio();

      setState(() {
        _amountTokenB = double.parse((_amountTokenA * _conversionRate).toStringAsFixed(8));
      });

      _amountTokenBController.text = _amountTokenB.toString();
      calculatePoolShare();
    }

    checkSufficientFunds();
  }

  handleChangeTokenB() async {
    if (null == _selectedTokenB || null == _selectedTokenA) {
      return;
    }

    double amount = double.tryParse(_amountTokenBController.text);

    if (amount == 0) {
      setState(() {
        _amountTokenB = null;
      });
      return;
    }

    if (_amountTokenB == amount) {
      return;
    }

    setState(() {
      _amountTokenB = amount;
    });

    if (null == amount) {
      _amountTokenAController.text = '';
    } else {
      getConversionRatio();

      setState(() {
        _amountTokenA = double.parse((_amountTokenB * (1 / _conversionRate)).toStringAsFixed(8));
      });

      _amountTokenAController.text = _amountTokenA.toString();

      calculatePoolShare();
    }
    checkSufficientFunds();
  }

  checkSufficientFunds() {
    var sufficient = false;

    if (_amountTokenA != null && _amountTokenA * DefiChainConstants.COIN > _selectedTokenA.balance) {
      sufficient = true;
    }

    if (_amountTokenB != null && _amountTokenB * DefiChainConstants.COIN > _selectedTokenB.balance) {
      sufficient = true;
    }

    setState(() {
      _insufficientFunds = sufficient;
    });
  }

  calculatePoolShare() {
    var shareA = _selectedTokenA.idToken == _selectedPoolPair.idTokenA ? (_amountTokenA / _selectedPoolPair.reserveA) : (_amountTokenA / _selectedPoolPair.reserveB);
    var shareB = _selectedTokenB.idToken == _selectedPoolPair.idTokenB ? (_amountTokenB / _selectedPoolPair.reserveB) : (_amountTokenB / _selectedPoolPair.reserveA);

    setState(() {
      _poolSharePercentage = ((shareA + shareB) / 2) * 100;
    });
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
            )),
        Expanded(
          flex: 1,
          child: AutoSizeText(e.balanceDisplayRounded, maxLines: 1, textAlign: TextAlign.right),
        )
      ],
    );
  }

  Future addLiquidity() async {
    final wallet = sl.get<DeFiChainWallet>();
    final walletTo = await wallet.getPublicKey();

    int amountTokenA = (_amountTokenA * DefiChainConstants.COIN).round();
    int amountTokenB = (_amountTokenB * DefiChainConstants.COIN).round();

    var streamController = StreamController<String>();

    sl.get<AppCenterWrapper>().trackEvent("addLiquidity", <String, String>{
      "tokenA": _selectedTokenA.hash,
      "amountA": amountTokenA.toString(),
      "tokenB": _selectedTokenB.hash,
      "amountB": amountTokenB.toString(),
      "shareAddress": walletTo
    });

    var createSwapFuture = wallet.createAndSendAddPoolLiquidity(_selectedTokenA.hash, amountTokenA, _selectedTokenB.hash, amountTokenB, walletTo, loadingStream: streamController);
    final overlay = LoadingOverlay.of(context, loadingText: streamController.stream);

    try {
      var tx = await overlay.during(createSwapFuture);

      sl.get<AppCenterWrapper>().trackEvent("addLiquiditySuccess", <String, String>{
        "tokenA": _selectedTokenA.hash,
        "amountA": amountTokenA.toString(),
        "tokenB": _selectedTokenB.hash,
        "amountB": amountTokenB.toString(),
        "shareAddress": walletTo,
        "txId": tx.mintTxId
      });

      streamController.close();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(S.of(context).liqudity_add_successfull),
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

      Navigator.of(context).pop();
    } catch (e) {
      LogHelper.instance.e("Error creating addpool-tx", e);
      if (e is ErrorResponse) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.error),
        ));

        sl.get<AppCenterWrapper>().trackEvent("addLiquidityFailureHandled", <String, String>{
          "tokenA": _selectedTokenA.hash,
          "amountA": amountTokenA.toString(),
          "tokenB": _selectedTokenB.hash,
          "amountB": amountTokenB.toString(),
          "shareAddress": walletTo,
          "error": e.error
        });
      } else if (e is HttpException) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.error.error),
        ));

        sl.get<AppCenterWrapper>().trackEvent("addLiquidityFailureHandled", <String, String>{
          "tokenA": _selectedTokenA.hash,
          "amountA": amountTokenA.toString(),
          "tokenB": _selectedTokenB.hash,
          "amountB": amountTokenB.toString(),
          "shareAddress": walletTo,
          "error": e.error.error
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()),
        ));

        sl.get<AppCenterWrapper>().trackEvent("addLiquidityFailure", <String, String>{
          "tokenA": _selectedTokenA.hash,
          "amountA": amountTokenA.toString(),
          "tokenB": _selectedTokenB.hash,
          "amountB": amountTokenB.toString(),
          "shareAddress": walletTo,
          "error": e.toString()
        });
      }
    }
  }

  @override
  void dispose() {
    _amountTokenAController.dispose();
    _amountTokenBController.dispose();
    super.dispose();
  }

  Widget _buildAddLmPage(BuildContext context) {
    if (_isLoading) {
      return LoadingWidget(text: S.of(context).loading);
    }

    return Column(mainAxisSize: MainAxisSize.min, children: [
      Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Expanded(
            flex: 1,
            child: Container(
                height: 60,
                child: DropdownButton<TokenBalance>(
                  isExpanded: true,
                  hint: Text(S.of(context).liquitiy_add_token_a),
                  value: _selectedTokenA,
                  items: _fromTokens.map((e) {
                    return new DropdownMenuItem<TokenBalance>(
                      value: e,
                      child: _buildDropdownListItem(e),
                    );
                  }).toList(),
                  onChanged: (TokenBalance val) {
                    setState(() {
                      filter(val, _selectedTokenB);

                      _selectedTokenA = val;

                      findPoolPair(_selectedTokenA, _selectedTokenB);
                      handleChangeTokenASelection();
                    });
                  },
                ))),
        SizedBox(width: 20),
        ButtonTheme(
            height: 30,
            minWidth: 40,
            child: ElevatedButton(
                child: Text(S.of(context).liquitiy_add_max),
                onPressed: () {
                  handleSetMaxTokenA();
                }))
      ]),
      TextField(
        controller: _amountTokenAController,
        decoration: InputDecoration(hintText: S.of(context).liquitiy_add_amount_a, contentPadding: const EdgeInsets.symmetric(vertical: 10.0)),
      ),
      Row(children: [
        Expanded(
            flex: 1,
            child: Container(
                height: 60,
                child: DropdownButton<TokenBalance>(
                  isExpanded: true,
                  hint: Text(S.of(context).liquitiy_add_token_b),
                  value: _selectedTokenB,
                  items: _toTokens.map((e) {
                    return new DropdownMenuItem<TokenBalance>(
                      value: e,
                      child: _buildDropdownListItem(e),
                    );
                  }).toList(),
                  onChanged: (TokenBalance val) {
                    setState(() {
                      filter(_selectedTokenA, val);

                      _selectedTokenB = val;

                      findPoolPair(_selectedTokenA, _selectedTokenB);
                      handleChangeTokenBSelection();
                    });
                  },
                ))),
        SizedBox(width: 20),
        ButtonTheme(
            height: 30,
            minWidth: 40,
            child: ElevatedButton(
                child: Text(S.of(context).liquitiy_add_max),
                onPressed: () {
                  handleSetMaxTokenB();
                }))
      ]),
      TextField(
        controller: _amountTokenBController,
        decoration: InputDecoration(hintText: S.of(context).liquitiy_add_amount_b),
      ),
      if (_insufficientFunds)
        Column(children: [
          Padding(padding: EdgeInsets.only(top: 10)),
          Text(S.of(context).liquitiy_add_insufficient_funds, style: Theme.of(context).textTheme.headline6),
        ]),
      if (_selectedPoolPair != null && _amountTokenB != null && _amountTokenA != null && _insufficientFunds == false)
        Column(children: [
          SizedBox(height: 10),
          Row(children: [
            Expanded(flex: 4, child: Text(S.of(context).liquitiy_add_price)),
            Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                        (_poolPairCondition == true ? _selectedPoolPair.reserveBDivReserveA.toString() : _selectedPoolPair.reserveADivReserveB.toString()) +
                            ' ' +
                            _selectedTokenB.hash +
                            ' per ' +
                            _selectedTokenA.hash,
                        textAlign: TextAlign.right),
                    Text(
                        (_poolPairCondition == true ? _selectedPoolPair.reserveADivReserveB.toString() : _selectedPoolPair.reserveBDivReserveA.toString()) +
                            ' ' +
                            _selectedTokenA.hash +
                            ' per ' +
                            _selectedTokenB.hash,
                        textAlign: TextAlign.right),
                  ],
                )),
          ]),
          Divider(
            thickness: 2,
          ),
          Row(children: [
            Expanded(flex: 4, child: Text(S.of(context).liquitiy_add_pool_share)),
            Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(_poolSharePercentage.toStringAsFixed(8) + '%'),
                  ],
                )),
          ]),
          Row(children: [
            Expanded(flex: 4, child: Text(S.of(context).liquitiy_add_total_pooled + ' ' + _selectedTokenA.hash)),
            Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(_selectedPoolPair.reserveA.toStringAsFixed(8)),
                  ],
                )),
          ]),
          Divider(
            thickness: 2,
          ),
          Row(children: [
            Expanded(flex: 4, child: Text(S.of(context).liquitiy_add_total_pooled + ' ' + _selectedTokenB.hash)),
            Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(_selectedPoolPair.reserveB.toStringAsFixed(8)),
                  ],
                )),
          ]),
          ElevatedButton(
            child: Text(S.of(context).liquitiy_add),
            onPressed: () async {
              await addLiquidity();
            },
          )
        ])
    ]);
  }

  @override
  Widget build(Object context) {
    return Scaffold(
        appBar: AppBar(toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight, title: Text(S.of(context).liquitiy_add)),
        body: Padding(padding: EdgeInsets.all(30), child: _buildAddLmPage(context)));
  }
}
