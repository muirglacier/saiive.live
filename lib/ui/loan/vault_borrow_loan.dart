import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/wallet/defichain/defichain_wallet.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/network/loans_service.dart';
import 'package:saiive.live/network/model/loan_token.dart';
import 'package:saiive.live/network/model/loan_vault.dart';
import 'package:saiive.live/network/vaults_service.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/ui/loan/vault_borrow_loan_choose_token.dart';
import 'package:saiive.live/ui/loan/vault_borrow_loan_choose_vault.dart';
import 'package:saiive.live/ui/loan/vault_borrow_loan_confirm.dart';
import 'package:saiive.live/ui/utils/fund_formatter.dart';
import 'package:saiive.live/ui/utils/token_icon.dart';
import 'package:saiive.live/ui/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:saiive.live/ui/widgets/navigated.dart';
import 'package:saiive.live/ui/widgets/table_widget.dart';
import 'package:saiive.live/ui/widgets/wallet_return_address_widget.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class VaultBorrowLoan extends StatefulWidget {
  final LoanToken loanToken;
  final LoanVault loanVault;
  final key = GlobalKey();

  VaultBorrowLoan({this.loanToken, this.loanVault});

  @override
  State<StatefulWidget> createState() {
    return _VaultBorrowLoan();
  }
}

class _VaultBorrowLoan extends State<VaultBorrowLoan> {
  PanelController _panelController = PanelController();
  Widget _panel = Container();
  List<LoanVault> _vaults;
  List<LoanToken> _tokens;
  var _amountController = TextEditingController(text: '');
  double _amount = 0;
  double _collateralizationRatio = 0;
  double _totalTokenWithInterest = 0;
  double _totalInterestAmount = 0;
  double _totalInterest = 0;
  double _totalUSDValue = 0;
  LoanVault _loanVault;
  LoanToken _loanToken;
  String _returnAddress;

  @override
  void initState() {
    super.initState();

    _loanVault = widget.loanVault;
    _loanToken = widget.loanToken;

    _initTokens();
    _initVaults();

    if (widget.loanVault != null) {
      _collateralizationRatio = double.tryParse(widget.loanVault.collateralRatio);
    }
    _amountController.addListener(handleChange);
  }

  _initTokens() async {
    setState(() {
      _tokens = null;
    });

    var tokens = await sl.get<ILoansService>().getLoanTokens(DeFiConstants.DefiAccountSymbol);

    setState(() {
      _tokens = tokens;
    });
  }

  _initVaults() async {
    setState(() {
      _vaults = null;
    });

    var pubKeyList = await sl.get<DeFiChainWallet>().getPublicKeys();
    var vaults = await sl.get<IVaultsService>().getMyVaults(DeFiConstants.DefiAccountSymbol, pubKeyList);

    setState(() {
      _vaults = vaults;
    });
  }

  handleChange() async {
    if (_loanVault == null) {
      return;
    }
    double amount = double.tryParse(_amountController.text.replaceAll(',', '.'));

    if (null == amount) {
      return;
    }

    var otherLoanValues = _loanVault.loanAmounts.fold(0.0, (previousValue, element) {
      if (element.symbol == _loanToken.token.symbol) {
        return previousValue;
      }

      var amount = double.tryParse(element.amount);
      var _loanTokenPriceUSD = element.activePrice != null ? element.activePrice.active.amount : 0;

      if (_loanToken.token.symbolKey == "DUSD") {
        _loanTokenPriceUSD = 1;
      }

      return previousValue + (amount * _loanTokenPriceUSD);
    });

    var currentLoanAmount = _loanVault.loanAmounts.firstWhere((element) => element.symbol == _loanToken.token.symbol, orElse: () => null);

    var _interestToken = double.tryParse(_loanToken.interest);
    var _interestVault = double.tryParse(_loanVault.schema.interestRate);
    var totalAmount = (currentLoanAmount != null ? double.tryParse(currentLoanAmount.amount) : 0.0) + amount;

    _totalInterest = _interestVault + _interestToken;
    _totalInterestAmount = (totalAmount * _totalInterest / 100);
    _totalTokenWithInterest = totalAmount + _totalInterestAmount;

    var _loanTokenPriceUSD = _loanToken.activePrice != null ? _loanToken.activePrice.active.amount : 0;

    if (_loanToken.token.symbolKey == "DUSD") {
      _loanTokenPriceUSD = 1;
    }

    _totalUSDValue = (_totalTokenWithInterest * _loanTokenPriceUSD) + otherLoanValues;

    setState(() {
      _collateralizationRatio = (100 / _totalUSDValue) * double.tryParse(_loanVault.collateralValue);
      _amount = amount;
    });
  }

  buildTokenEntry() {
    var currentLoanAmount =
        _loanToken != null && _loanVault != null ? _loanVault.loanAmounts.firstWhere((element) => element.symbol == _loanToken.token.symbol, orElse: () => null) : null;

    return InkWell(
        onTap: () {
          setState(() {
            _panel = this._buildChooseLoanTokenPanel();
          });

          _panelController.show();
          _panelController.open();
        },
        child: (null == _loanToken)
            ? Card(
                child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Column(children: [
                      Row(children: <Widget>[
                        Text(
                          S.of(context).loan_borrow_choose_token,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        Spacer(),
                        Icon(Icons.swap_vert_outlined)
                      ]),
                    ])))
            : Card(
                child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Column(children: [
                      Row(
                        children: <Widget>[
                          Container(decoration: BoxDecoration(color: Colors.transparent), child: TokenIcon(_loanToken.token.symbolKey)),
                          Container(width: 10),
                          Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(
                              _loanToken.token.name,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.headline6,
                            )
                          ])),
                          Container(width: 10),
                          Container(decoration: BoxDecoration(color: Colors.transparent), child: Icon(Icons.swap_vert_outlined))
                        ],
                      ),
                      Row(children: [
                        Text(S.of(context).loan_price_usd, style: Theme.of(context).textTheme.caption),
                        Spacer(),
                        Text(_loanToken.activePrice != null ? FundFormatter.format(_loanToken.activePrice.active.amount, fractions: 2) + ' \$' : '-'),
                      ]),
                      if (currentLoanAmount != null)
                        Row(children: [
                          Text(S.of(context).loan_current_amount, style: Theme.of(context).textTheme.caption),
                          Spacer(),
                          Text(FundFormatter.format(double.tryParse(currentLoanAmount.amount))),
                        ]),
                      if (currentLoanAmount != null)
                        Row(children: [
                          Text(S.of(context).loan_current_amount_usd, style: Theme.of(context).textTheme.caption),
                          Spacer(),
                          Text(FundFormatter.format(double.tryParse(currentLoanAmount.amount) * (_loanToken.activePrice != null ? _loanToken.activePrice.active.amount : 0)) +
                              ' \$'),
                        ]),
                      Row(children: [Text(S.of(context).loan_interest, style: Theme.of(context).textTheme.caption), Spacer(), Text(_loanToken.interest + '%')])
                    ]))));
  }

  Widget _buildChooseVaultPanel() {
    return Navigated(
        child: VaultBorrowLoanChooseVaultScreen(_vaults, (LoanVault vault) {
      _loanVault = vault;

      setState(() {
        _panel = Container();
      });

      this._panelController.close();
    }));
  }

  Widget _buildChooseLoanTokenPanel() {
    return Navigated(
        child: VaultBorrowLoanChooseTokenScreen(_tokens, (LoanToken token) {
      _loanToken = token;

      setState(() {
        _panel = Container();
      });

      this._panelController.close();
    }));
  }

  buildTXDetails() {
    List<List<String>> items = [
      [S.of(context).loan_collateral_ratio, _collateralizationRatio.toStringAsFixed(2) + '%'],
      [S.of(context).loan_min_collateral_ratio, _loanVault.schema.minColRatio + '%'],
      [S.of(context).loan_token_total_interest_rate, _totalInterest.toStringAsFixed(2) + '%'],
      [S.of(context).loan_token_interest_amount, FundFormatter.format(_totalInterestAmount) + ' ' + _loanToken.token.symbol],
      [S.of(context).loan_token_total_interest, FundFormatter.format(_totalTokenWithInterest) + ' ' + _loanToken.token.symbol],
    ];

    return CustomTableWidget(items);
  }

  buildVaultEntry() {
    return InkWell(
        onTap: () {
          setState(() {
            _panel = this._buildChooseVaultPanel();
          });

          _panelController.show();
          _panelController.open();
        },
        child: null == _loanVault
            ? Card(
                child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Column(children: [
                      Row(children: <Widget>[
                        Text(
                          S.of(context).loan_borrow_choose_vault,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        Spacer(),
                        Icon(Icons.swap_vert_outlined)
                      ]),
                    ])))
            : Card(
                child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Column(children: [
                      Row(children: <Widget>[
                        Container(decoration: BoxDecoration(color: Colors.transparent), child: Icon(Icons.shield, size: 40)),
                        Container(width: 10),
                        Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(
                            _loanVault.vaultId,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.headline6,
                          )
                        ])),
                        Container(width: 10),
                        Container(decoration: BoxDecoration(color: Colors.transparent), child: Icon(Icons.swap_vert_outlined))
                      ]),
                      Container(height: 5),
                      Row(children: [
                        Text(S.of(context).loan_total_collateral, style: Theme.of(context).textTheme.caption),
                        Spacer(),
                        Text(FundFormatter.format(double.tryParse(_loanVault.collateralValue), fractions: 2) + ' \$'),
                      ]),
                      Row(children: [
                        Text(S.of(context).loan_total_loan_amount, style: Theme.of(context).textTheme.caption),
                        Spacer(),
                        Text(FundFormatter.format(double.tryParse(_loanVault.loanValue), fractions: 2) + ' \$'),
                      ]),
                      Row(children: [
                        Text(S.of(context).loan_collateral_ratio, style: Theme.of(context).textTheme.caption),
                        Spacer(),
                        Text(_loanVault.collateralRatio + '%'),
                      ]),
                      Row(children: [
                        Text(S.of(context).loan_min_collateral_ratio, style: Theme.of(context).textTheme.caption),
                        Spacer(),
                        Text(_loanVault.schema.minColRatio + '%')
                      ]),
                      Row(children: [Text(S.of(context).loan_vault_interest, style: Theme.of(context).textTheme.caption), Spacer(), Text(_loanVault.schema.interestRate + '%')]),
                    ]))));
  }

  @override
  Widget build(BuildContext context) {
    if (_vaults == null || _tokens == null) {
      return Scaffold(
          appBar: AppBar(toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight, title: Text(S.of(context).loan_borrow_title)),
          body: LoadingWidget(text: S.of(context).loading));
    }

    GlobalKey<NavigatorState> key = GlobalKey();

    return Scaffold(
        appBar: AppBar(toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight, title: Text(S.of(context).loan_borrow_title)),
        body: SlidingUpPanel(
            controller: _panelController,
            backdropEnabled: true,
            defaultPanelState: PanelState.CLOSED,
            minHeight: 0,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(18.0), topRight: Radius.circular(18.0)),
            color: StateContainer.of(context).curTheme.cardBackgroundColor,
            onPanelClosed: () {
              if (key != null && key.currentState != null && key.currentState.canPop()) {
                key.currentState.pop();
              }

              setState(() {
                _panel = Container();
              });
            },
            panel: LayoutBuilder(builder: (_, builder) {
              return Column(children: [
                SizedBox(
                  height: 12.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 30,
                      height: 5,
                      decoration: BoxDecoration(color: StateContainer.of(context).curTheme.backgroundColor, borderRadius: BorderRadius.all(Radius.circular(12.0))),
                    ),
                  ],
                ),
                Expanded(child: _panel)
              ]);
            }),
            body: Padding(
                padding: EdgeInsets.only(top: 10, left: 10, right: 10),
                child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanDown: (_) {
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    child: NestedScrollView(
                        headerSliverBuilder: (context, value) {
                          return [
                            SliverToBoxAdapter(
                                child: Padding(padding: const EdgeInsets.only(left: 8.0), child: Text(S.of(context).loan_token, style: Theme.of(context).textTheme.caption))),
                            SliverToBoxAdapter(child: buildTokenEntry()),
                            SliverToBoxAdapter(
                                child: Padding(padding: const EdgeInsets.only(left: 8.0), child: Text(S.of(context).loan_vault, style: Theme.of(context).textTheme.caption))),
                            SliverToBoxAdapter(child: buildVaultEntry()),
                          ];
                        },
                        body: Container(child:
                          (_loanVault != null && _loanToken != null) ?
                            SingleChildScrollView(child:
                            Column(children: [
                              Container(height: 20),
                              Text(S.of(context).loan_amount),
                              TextField(
                                  controller: _amountController,
                                  decoration: InputDecoration(hintText: S.of(context).loan_borrow_amount, contentPadding: const EdgeInsets.symmetric(vertical: 10.0)),
                                  keyboardType: TextInputType.numberWithOptions(decimal: true)),
                              buildTXDetails(),
                              Padding(
                                  padding: const EdgeInsets.only(left: 4, right: 4.0, bottom: 10),
                                  child: WalletReturnAddressWidget(
                                    onChanged: (v) {
                                      setState(() {
                                        _returnAddress = v;
                                      });
                                    },
                                  )),
                              Padding(
                                  padding: const EdgeInsets.only(left: 4, right: 4.0, bottom: 20),
                                  child: SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                          child: Text(S.of(context).loan_continue),
                                          onPressed: () async {
                                            await Navigator.of(context).push(MaterialPageRoute(
                                                builder: (BuildContext context) => VaultBorrowLoanConfirmScreen(_loanVault, _loanToken, _amount, _returnAddress)));
                                          })))
                            ])) : Container(),
                        ))))));
  }
}
