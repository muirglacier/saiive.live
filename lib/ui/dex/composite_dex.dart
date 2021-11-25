import 'dart:async';
import 'dart:io';
import 'package:collection/src/iterable_extensions.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:saiive.live/appcenter/appcenter.dart';
import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/model/wallet_address.dart';
import 'package:saiive.live/crypto/wallet/defichain/defichain_wallet.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/helper/balance.dart';
import 'package:saiive.live/helper/constants.dart';
import 'package:saiive.live/network/events/wallet_sync_start_event.dart';
import 'package:saiive.live/network/model/account_balance.dart';
import 'package:saiive.live/network/model/pool_pair.dart';
import 'package:saiive.live/network/model/pool_pair_token.dart';
import 'package:saiive.live/network/model/token_balance.dart';
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
import 'package:flutter/material.dart';
import 'package:saiive.live/ui/widgets/loading_overlay.dart';
import 'package:saiive.live/ui/widgets/table_widget.dart';
import 'package:saiive.live/ui/widgets/wallet_return_address_widget.dart';
import 'package:wakelock/wakelock.dart';

class CompositeDexScreen extends StatefulWidget {
  const CompositeDexScreen({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CompositeDexScreen();
  }
}

class CompositeSwapResult {
  double aToBPrice = 1;
  double bToAPrice = 1;
  double estimated = 0;
}

class _CompositeDexScreen extends State<CompositeDexScreen> {
  bool _isLoading = true;
  List<TokenBalance> _fromTokens = [];
  List<TokenBalance> _toTokens = [];
  List<TokenBalance> _tokenMap = [];
  List<PoolPair> _poolPairs;
  List<PoolPair> _selectedPoolPairs;
  List<PoolPairToken> _tokens;
  CompositeSwapResult _price;
  var _amountFromController = TextEditingController(text: '');

  TokenBalance _selectedValueTo;
  TokenBalance _selectedValueFrom;

  double _amountFrom;

  WalletAddress _toAddress;
  String _returnAddress;

  @override
  void initState() {
    super.initState();

    _amountFromController.addListener(handleChangeFrom);

    sl.get<AppCenterWrapper>().trackEvent("openCompositeSwapPage", <String, String>{});
    sl.get<IHealthService>().checkHealth(context);

    _init();
  }

  _init() async {
    sl.get<AppCenterWrapper>().trackEvent("openCompositeSwapPageLoadStart", <String, String>{"timestamp": DateTime.now().millisecondsSinceEpoch.toString()});
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

    if (null == accountBalance.firstWhere((element) => element.token == DeFiConstants.DefiAccountSymbol, orElse: () => null)) {
      accountBalance.add(AccountBalance(token: DeFiConstants.DefiAccountSymbol, balance: 0, chain: ChainType.DeFiChain));
    }

    uniqueTokenList.forEach((symbolKey, tokenId) {
      var account = accountBalance.firstWhere((element) => element.token == tokenId, orElse: () => null);
      var finalBalance = account != null ? account.balance : 0;
      var balance = null;

      if (account != null) {
        balance = TokenBalance(hash: tokenId, idToken: symbolKey, balance: finalBalance, displayName: account.tokenDisplay);
      } else {
        balance = TokenBalance(hash: tokenId, idToken: symbolKey, balance: finalBalance, displayName: "d" + tokenId);
      }

      if (account != null) {
        _fromTokens.add(balance);
      }

      _tokenMap.add(balance);
    });

    _tokens = pairs.fold(List<PoolPairToken>.empty(growable: true), (List<PoolPairToken> previousValue, element) {
      bool hasTokenA = previousValue.firstWhereOrNull((el) => el.id == element.idTokenA) != null;
      bool hasTokenB = previousValue.firstWhereOrNull((el) => el.id == element.idTokenB) != null;
      List<PoolPairToken> tokensToAdd = [];

      if (!hasTokenA) {
        tokensToAdd.add(new PoolPairToken(
            id: element.idTokenA, name: element.symbol.split('-')[0], symbol: element.symbol.split('-')[0], blockCommission: element.blockCommissionA, reserve: element.reserveA));
      }

      if (!hasTokenB) {
        tokensToAdd.add(new PoolPairToken(
            id: element.idTokenB, name: element.symbol.split('-')[1], symbol: element.symbol.split('-')[1], blockCommission: element.blockCommissionB, reserve: element.reserveB));
      }

      return [...previousValue, ...tokensToAdd];
    });

    _poolPairs = pairs;

    setState(() {
      _fromTokens = _fromTokens;
      _isLoading = false;
    });

    sl.get<AppCenterWrapper>().trackEvent("openCompositeSwapPageLoadEnd", <String, String>{"timestamp": DateTime.now().millisecondsSinceEpoch.toString()});
  }

  handleChangeFrom() async {
    double amount = double.tryParse(_amountFromController.text.replaceAll(',', '.'));

    if (amount == null || amount == 0) {
      setState(() {
        _amountFrom = null;
        _price = null;
      });
      return;
    }

    setState(() {
      _amountFrom = amount;
    });

    if (_amountFrom != null && _amountFrom > 0) {
      findPrice();
    }
  }

  handleChangeTokenTo() {}

  findPrice() {
    var path = findPath(_poolPairs, _selectedValueFrom.idToken, _selectedValueTo.idToken);
    var visited = path[0];
    var foundPaths = path[1];
    var poolPairs = List.from(foundPaths).foldIndexed(List<PoolPair>(), (index, pairs, token) {
      if (index + 1 >= foundPaths.length) {
        return pairs;
      }

      var pair = _poolPairs.firstWhere(
          (element) => (element.idTokenA == token && element.idTokenB == foundPaths[index + 1]) || (element.idTokenB == token && element.idTokenA == foundPaths[index + 1]),
          orElse: () => null);

      if ((pair == null) || index == foundPaths.length) {
        return pairs;
      }
      pairs.add(pair);

      return pairs;
    });

    _selectedPoolPairs = poolPairs;
    calculatePriceRates();
  }

  calculatePriceRates() {
    var tokenA = _tokens.firstWhereOrNull((element) => element.id == _selectedValueFrom.idToken);

    if (tokenA == null) {
      return;
    }

    var slippage = 1 - _amountFrom / tokenA.reserve;
    var lastTokenBySymbol = tokenA.symbol;
    var lastAmount = _amountFrom;

    var price = _selectedPoolPairs.fold(new CompositeSwapResult(), (CompositeSwapResult previousValue, element) {
      var split = element.symbol.split('-');
      var tokenA = split[0];
      var tokenB = split[1];

      var reserveA = tokenA == lastTokenBySymbol ? element.reserveA : element.reserveB;
      var reserveB = tokenA == lastTokenBySymbol ? element.reserveB : element.reserveA;

      var tokenASymbol = tokenA == lastTokenBySymbol ? tokenA : tokenB;
      var tokenBSymbol = tokenA == lastTokenBySymbol ? tokenB : tokenA;

      var priceRateA = reserveB / reserveA;
      var priceRateB = reserveA / reserveB;

      var aToBPrice = tokenASymbol == lastTokenBySymbol ? priceRateA : priceRateB;
      var bToaPrice = tokenASymbol == lastTokenBySymbol ? priceRateB : priceRateA;
      var estimated = lastAmount * aToBPrice;

      lastAmount = estimated;
      lastTokenBySymbol = tokenBSymbol;

      previousValue.aToBPrice = previousValue.aToBPrice * aToBPrice;
      previousValue.bToAPrice = previousValue.bToAPrice * bToaPrice;
      previousValue.estimated = estimated;

      return previousValue;
    });

    price.estimated = price.estimated * slippage;

    setState(() {
      _price = price;
    });
  }

  findPath(List<PoolPair> pairs, String origin, String target) {
    bool isPathFound = false;
    List<String> nodesToVisit = [origin];
    List<String> visitedNodes = [];
    int currentDistance = 0;
    List<String> path = [];

    bfs(String start, List<String> edges, String target) {
      if (edges.length == 0 && start != target) {
        visitedNodes.add(start);
        return;
      }

      if (!isPathFound) {
        path.add(start);
      }

      if (start == target) {
        isPathFound = true;
        visitedNodes.add(start);
        nodesToVisit = [];
        return;
      }

      visitedNodes.add(start);

      while (nodesToVisit.length > 0) {
        currentDistance += 1;
        nodesToVisit.removeAt(0);

        var nextNodeVisitEdges = edges;

        while (nextNodeVisitEdges.length != 0 && !isPathFound) {
          var startValue = nextNodeVisitEdges[0];
          var innerEdges = getAdjacentNodes(startValue, pairs).where((element) => !visitedNodes.contains(element)).toList();

          nodesToVisit.addAll(innerEdges);

          bfs(startValue, innerEdges, target);

          nextNodeVisitEdges.removeAt(0);
        }
      }
    }

    var adjacentNodes = getAdjacentNodes(origin, pairs);
    bfs(origin, adjacentNodes, target);
    return [visitedNodes, isPathFound ? path : []];
  }

  List<String> getAdjacentNodes(String startNode, List<PoolPair> pairs) {
    List<String> adjacentNodes = [];

    pairs.forEach((element) {
      if (element.idTokenA == startNode && element.idTokenB != startNode) {
        adjacentNodes.add(element.idTokenB);
      } else if (element.idTokenB == startNode && element.idTokenA != startNode) {
        adjacentNodes.add(element.idTokenA);
      }
    });

    return adjacentNodes;
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

  filterValueTo(TokenBalance fromToken) {
    setState(() {
      _toTokens = _tokenMap.where((element) => element.idToken != fromToken.idToken).toList();
    });
  }

  Future doSwap() async {
    Wakelock.enable();

    final wallet = sl.get<DeFiChainWallet>();

    int valueFrom = (_amountFrom * DefiChainConstants.COIN).round();
    //int maxPrice = (_conversionRate * DefiChainConstants.COIN).round();

    final walletTo = _toAddress.publicKey;
    try {
      var streamController = StreamController<String>();

      var poolIds = List<int>.empty(growable: true);
      for (var pool in _selectedPoolPairs) {
        poolIds.add(int.parse(pool.id));
      }
      var createSwapFuture = wallet.createAndSendSwapV2(_selectedValueFrom.hash, valueFrom, _selectedValueTo.hash, walletTo, 9223372036854775807, 9223372036854775807, poolIds,
          returnAddress: _returnAddress, loadingStream: streamController);

      sl
          .get<AppCenterWrapper>()
          .trackEvent("swap", <String, String>{"fromToken": _selectedValueFrom.hash, "toToken": _selectedValueTo.hash, "valueFrom": valueFrom.toString(), "walletTo": walletTo});

      final overlay = LoadingOverlay.of(context, loadingText: streamController.stream);
      var tx = await overlay.during(createSwapFuture);

      sl.get<AppCenterWrapper>().trackEvent("swapSuccess",
          <String, String>{"fromToken": _selectedValueFrom.hash, "toToken": _selectedValueTo.hash, "valueFrom": valueFrom.toString(), "walletTo": walletTo, "txId": tx.txId});

      streamController.close();

      EventTaxiImpl.singleton().fire(WalletSyncStartEvent());
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => TransactionSuccessScreen(ChainType.DeFiChain, tx.txId, S.of(context).dex_swap_successfull),
      ));

      // resetForm();
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

  Widget _buildDexPage(BuildContext context) {
    if (_isLoading) {
      return LoadingWidget(text: S.of(context).loading);
    } else {
      return SingleChildScrollView(
          child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(children: [
                Row(children: [
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
                                filterValueTo(val);

                                _selectedValueFrom = val;
                                // filterToList();
                              });
                            },
                          ))),
                  SizedBox(width: 20),
                  Expanded(
                      flex: 1,
                      child: Container(
                          height: 60,
                          child: DropdownButton<TokenBalance>(
                            isExpanded: true,
                            hint: Text(S.of(context).dex_to_token),
                            value: _selectedValueTo,
                            items: _selectedValueFrom == null
                                ? null
                                : _toTokens.map((e) {
                                    return new DropdownMenuItem<TokenBalance>(
                                      value: e,
                                      child: _buildDropdownListItem(e),
                                    );
                                  }).toList(),
                            onChanged: (TokenBalance val) {
                              setState(() {
                                _selectedValueTo = val;

                                handleChangeTokenTo();
                              });
                            },
                          )))
                ]),
                if (_selectedValueFrom != null && _selectedValueTo != null)
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(height: 20),
                    Text('How much from you wanna swap?'),
                    Row(children: [
                      Expanded(
                          flex: 1,
                          child: TextField(
                              controller: _amountFromController,
                              decoration: InputDecoration(hintText: S.of(context).dex_from_amount),
                              keyboardType: TextInputType.numberWithOptions(decimal: true))),
                      Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        ElevatedButton(
                            child: Text(
                              '50%',
                              style: TextStyle(color: StateContainer.of(context).curTheme.text),
                            ),
                            onPressed: () {}),
                        Container(width: 5),
                        ElevatedButton(
                            child: Text(
                              'Max',
                              style: TextStyle(color: StateContainer.of(context).curTheme.text),
                            ),
                            onPressed: () {})
                      ])
                    ]),
                    Container(height: 20),
                    Row(children: [
                      Expanded(flex: 1, child: Text('Amount to receive')),
                      if (_price != null) Text(FundFormatter.format(_price.estimated)),
                      Container(width: 5),
                      if (_selectedValueTo != null) TokenIcon(_selectedValueTo.hash),
                    ]),
                    Container(height: 20),
                    if (_price != null) _buildSwapDetails(),
                    if (_price != null) _buildTxDetails(),
                    Container(height: 20),
                    AccountSelectAddressWidget(
                        label: Text(S.of(context).dex_to_address, style: Theme.of(context).inputDecorationTheme.hintStyle),
                        onChanged: (newValue) {
                          setState(() {
                            _toAddress = newValue;
                          });
                        }),
                    Container(height: 20),
                    WalletReturnAddressWidget(
                      onChanged: (v) {
                        setState(() {
                          _returnAddress = v;
                        });
                      },
                    ),
                    Container(height: 20),
                    if (_price != null)
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

  _buildSwapDetails() {
    List<List<String>> items = [
      [_selectedValueFrom.displayName + ' price in ' + _selectedValueTo.displayName, FundFormatter.format(_price.aToBPrice)],
      [_selectedValueTo.displayName + ' price in ' + _selectedValueFrom.displayName, FundFormatter.format(_price.bToAPrice)]
    ];

    return Column(children: [Padding(padding: const EdgeInsets.only(left: 8.0), child: Text('Prices', style: Theme.of(context).textTheme.caption)), CustomTableWidget(items)]);
  }

  _buildTxDetails() {
    List<List<String>> items = [
      ['Amount to be converted', FundFormatter.format(_amountFrom) + ' ' + _selectedValueFrom.displayName],
      ['Estimated to receive', FundFormatter.format(_price.estimated) + ' ' + _selectedValueTo.displayName]
    ];

    return Column(children: [Padding(padding: const EdgeInsets.only(left: 8.0), child: Text('Prices', style: Theme.of(context).textTheme.caption)), CustomTableWidget(items)]);
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
              Text(S.of(context).dex_v2)
            ])),
        body: _buildDexPage(context));
  }
}
