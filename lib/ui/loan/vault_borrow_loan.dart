import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/wallet/defichain/defichain_wallet.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/network/loans_service.dart';
import 'package:saiive.live/network/model/loan_token.dart';
import 'package:saiive.live/network/model/loan_vault.dart';
import 'package:saiive.live/network/vaults_service.dart';
import 'package:saiive.live/service_locator.dart';
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

  VaultBorrowLoan(this.loanToken, {this.loanVault});

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
  bool _valid = false;
  double _collateralizationRatio = 0;
  double _totalTokenWithInterest = 0;
  double _totalInterestAmount = 0;
  double _totalInterest = 0;
  double _totalUSDValue = 0;
  LoanVault _loanVault;
  String _returnAddress;

  @override
  void initState() {
    super.initState();

    _loanVault = widget.loanVault;

    _initTokens();
    _initVaults();

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
    double amount = double.tryParse(_amountController.text.replaceAll(',', '.'));
    bool valid = true;

    if (null == amount) {
      valid = false;
      return;
    }

    var _interestToken = double.tryParse(widget.loanToken.interest);
    var _interestVault = double.tryParse(_loanVault.schema.interestRate);

    _totalInterest = _interestVault + _interestToken;
    _totalInterestAmount = (amount * _totalInterest / 100);
    _totalTokenWithInterest = amount + _totalInterestAmount;

    var _loanTokenPriceUSD = widget.loanToken.activePrice != null ? widget.loanToken.activePrice.active.amount : 0;

    _totalUSDValue = _totalTokenWithInterest * _loanTokenPriceUSD;
    _collateralizationRatio = (100 / _totalUSDValue) * double.tryParse(_loanVault.collateralValue);

    setState(() {
      _collateralizationRatio = (100 / _totalUSDValue) * double.tryParse(_loanVault.collateralValue);
      _amount = amount;
      _valid = valid;
    });
  }

  buildTokenEntry() {
    if (null == widget.loanToken) {
      return Card(
          child: Padding(
              padding: EdgeInsets.all(30),
              child: Column(children: [
                Row(children: <Widget>[
                  Text(
                    'Choose a Loan Token',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  Spacer(),
                  Icon(Icons.swap_vert_outlined)
                ]),
              ])));
    }

    return Card(
        child: Padding(
            padding: EdgeInsets.all(30),
            child: Column(children: [
              Row(
                children: <Widget>[
                  Container(decoration: BoxDecoration(color: Colors.transparent), child: TokenIcon(widget.loanToken.token.symbolKey)),
                  Container(width: 10),
                  Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                      widget.loanToken.token.name,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headline6,
                    )
                  ])),
                  Container(width: 10),
                  Container(decoration: BoxDecoration(color: Colors.transparent), child: Icon(Icons.swap_vert_outlined))
                ],
              ),
              Container(height: 5),
              Row(children: [
                Text('Price', style: Theme.of(context).textTheme.caption),
                Spacer(),
                Text(widget.loanToken.activePrice != null ? FundFormatter.format(widget.loanToken.activePrice.active.amount, fractions: 2) + ' \$' : '-'),
              ]),
              Row(children: [Text('Interest', style: Theme.of(context).textTheme.caption), Spacer(), Text(widget.loanToken.interest + '%')])
            ])));
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

  buildTXDetails() {
    List<List<String>> items = [
      ['Collateralization Ratio', _collateralizationRatio.toStringAsFixed(2) + '%'],
      ['Min. collateralization', _loanVault.schema.minColRatio + '%'],
      ['Interest (Vault + Token)', _totalInterest.toStringAsFixed(2) + '%'],
      ['Total Interest Amount', FundFormatter.format(_totalInterestAmount) + ' ' + widget.loanToken.token.symbol],
      ['Total Loan + interest', FundFormatter.format(_totalTokenWithInterest) + ' ' + widget.loanToken.token.symbol],
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
                          'Choose your Vault',
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
                        Text('Total Collateral', style: Theme.of(context).textTheme.caption),
                        Spacer(),
                        Text(FundFormatter.format(double.tryParse(_loanVault.collateralValue), fractions: 2) + ' \$'),
                      ]),
                      Row(children: [Text('Vault Interest', style: Theme.of(context).textTheme.caption), Spacer(), Text(_loanVault.schema.interestRate + '%')])
                    ]))));
  }

  @override
  Widget build(BuildContext context) {
    if (_vaults == null || _tokens == null) {
      return Scaffold(
          appBar: AppBar(toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight, title: Text('Borrow Loan Token')), body: LoadingWidget(text: S.of(context).loading));
    }

    GlobalKey<NavigatorState> key = GlobalKey();

    return Scaffold(
        appBar: AppBar(toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight, title: Text('Borrow Loan Token')),
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
                child: NestedScrollView(
                    headerSliverBuilder: (context, value) {
                      return [
                        SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.only(left: 8.0), child: Text('Loan Token', style: Theme.of(context).textTheme.caption))),
                        SliverToBoxAdapter(child: buildTokenEntry()),
                        SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.only(left: 8.0), child: Text('Vault', style: Theme.of(context).textTheme.caption))),
                        SliverToBoxAdapter(child: buildVaultEntry()),
                      ];
                    },
                    body: Column(children: [
                      if (_loanVault != null && widget.loanToken != null)
                        Column(children: [
                          Container(height: 20),
                          Text('Amount'),
                          TextField(
                              controller: _amountController,
                              decoration: InputDecoration(hintText: 'How much to add?', contentPadding: const EdgeInsets.symmetric(vertical: 10.0)),
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
                          SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                child: Text('Continue'),
                                onPressed: () {
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(builder: (BuildContext context) => VaultBorrowLoanConfirmScreen(_loanVault, widget.loanToken, _amount, _returnAddress)));
                                },
                              ))
                        ]),
                    ])))));
  }
}
