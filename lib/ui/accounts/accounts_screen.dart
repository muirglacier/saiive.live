import 'package:auto_size_text/auto_size_text.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/model/wallet_account.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/network/events/wallet_sync_start_event.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/services/wallet_service.dart';
import 'package:saiive.live/ui/accounts/accounts_add_screen.dart';
import 'package:saiive.live/ui/accounts/accounts_detail_screen.dart';
import 'package:saiive.live/ui/accounts/accounts_select_action_screen.dart';
import 'package:saiive.live/ui/utils/token_icon.dart';
import 'package:saiive.live/ui/widgets/loading.dart';
import 'package:saiive.live/util/sharedprefsutil.dart';

import 'accounts_import_screen.dart';

class AccountsScreen extends StatefulWidget {
  final allowChangeVisibility;
  final allowImport;

  final useOnlyFilter;
  final ChainType chainType;

  AccountsScreen({this.allowChangeVisibility = true, this.allowImport = true, this.useOnlyFilter = false, this.chainType = ChainType.DeFiChain, Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AccountScreen();
}

class _AccountScreen extends State<AccountsScreen> {
  List<WalletAccount> _walletAccounts = List<WalletAccount>.empty();
  bool _isLoading = false;
  bool _isSingleAddressWallet = false;

  IWalletService _walletService;

  bool isSelectionMode = false;

  void onLongPress(bool isSelected, WalletAccount index) {
    if (!widget.allowChangeVisibility) {
      return;
    }
    setState(() {
      index.selected = !isSelected;
      isSelectionMode = !isSelectionMode;
    });
  }

  Future onTap(bool isSelected, WalletAccount account) async {
    if (isSelectionMode) {
      for (var wa in _walletAccounts) {
        if (wa.chain == account.chain) {
          wa.selected = false;
        }
      }
      setState(() {
        account.selected = !isSelected;
      });
    } else {
      await Navigator.of(context).push(MaterialPageRoute(settings: RouteSettings(name: "/accountsDetails"), builder: (BuildContext context) => AccountsDetailScreen(account)));

      await _init();
    }
  }

  Future _init() async {
    _walletService = sl.get<IWalletService>();

    var accounts = await _walletService.getAccounts();

    _isSingleAddressWallet = await sl.get<ISharedPrefsUtil>().getUseSingleAddressWallet();
    if (widget.useOnlyFilter) {
      accounts = accounts.where((element) => element.chain == widget.chainType).toList();
    }

    setState(() {
      _walletAccounts = accounts;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    _isLoading = true;
    super.initState();

    _init();
  }

  Future _save() async {
    if (isSelectionMode) {
      for (final acc in _walletAccounts) {
        _walletService.addAccount(acc);
      }

      EventTaxiImpl.singleton().fire(WalletSyncStartEvent());
    }

    setState(() {
      isSelectionMode = !isSelectionMode;
    });
  }

  List<Widget> _buildPublicKeyAddress(BuildContext context, WalletAccount account) {
    if (account.walletAccountType == WalletAccountType.HdAccount) {
      var text = "${WalletAccount.getStringForWalletAccountType(account.walletAccountType)}(${pathDerivationTypeString(account.derivationPathType)})";
      return [
        AutoSizeText(text, maxLines: 1, overflow: TextOverflow.ellipsis),
      ];
    }

    return [Text(WalletAccount.getStringForWalletAccountType(account.walletAccountType))];
  }

  Widget _buildSelectIcon(bool isSelected, WalletAccount account) {
    if (isSelectionMode) {
      return Stack(
        children: <Widget>[
          TokenIcon(ChainHelper.chainTypeString(account.chain), opacity: 0.2),
          Positioned(
            bottom: 0,
            right: 0,
            child: Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      );
    } else {
      return Stack(
        children: <Widget>[
          if (!account.selected)
            ColorFiltered(colorFilter: ColorFilter.mode(Colors.grey, BlendMode.color), child: TokenIcon(ChainHelper.chainTypeString(account.chain), opacity: 1.0)),
          if (account.selected) TokenIcon(ChainHelper.chainTypeString(account.chain), opacity: 1.0),
          if (!account.selected)
            Positioned(
              bottom: -5,
              right: -5,
              child: Container(
                  child: Icon(
                account.selected ? Icons.visibility : Icons.visibility_off,
                color: account.selected ? Colors.green : Colors.red,
              )),
            ),
        ],
      );
    }
  }

  Widget _buildAccountEntry(BuildContext context, WalletAccount account) {
    return Card(
        child: ListTile(
      title: Text(account.name),
      subtitle: Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Row(children: _buildPublicKeyAddress(context, account))])
      ]),
      leading: _buildSelectIcon(account.selected, account),
      onTap: () async {
        await onTap(account.selected, account);
      },
      onLongPress: () => onLongPress(account.selected, account),
    ));
  }

  Widget _buildAccountPage(BuildContext context) {
    if (_isLoading) {
      return LoadingWidget(text: S.of(context).loading);
    }

    return Padding(
        padding: EdgeInsets.all(10),
        child: Padding(
            padding: EdgeInsets.only(right: 10),
            child: ListView(children: [
              ListView.builder(
                  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: _walletAccounts.length,
                  itemBuilder: (context, index) {
                    final wa = _walletAccounts.elementAt(index);

                    return _buildAccountEntry(context, wa);
                  })
            ])));
  }

  _buildFloatingActionButton(BuildContext context) {
    if (!widget.allowChangeVisibility) {
      return null;
    }
    if (_isLoading) {
      return null;
    }
    return FloatingActionButton.extended(
      onPressed: () async {
        await _save();
      },
      heroTag: null,
      icon: Icon(isSelectionMode ? Icons.save : Icons.visibility_outlined, color: StateContainer.of(context).curTheme.appBarText),
      label: Text(
        S.of(context).visibility,
        style: TextStyle(color: StateContainer.of(context).curTheme.appBarText),
      ),
      backgroundColor: Theme.of(context).primaryColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight,
          title: Row(children: [Text(S.of(context).wallet_accounts)]),
          actions: [
            if (!_isSingleAddressWallet)
              Padding(
                  padding: EdgeInsets.only(right: 15.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => AccountsSelectActionScreen((chainType) async {
                                await Navigator.of(context).push(MaterialPageRoute(
                                    settings: RouteSettings(name: "/accountsAddScreen"), builder: (BuildContext context) => AccountsAddScreen(chainType, null, true)));
                                await _init();
                              })));
                    },
                    child: Icon(Icons.add, size: 30.0, color: Theme.of(context).appBarTheme.actionsIconTheme.color),
                  )),
            if (!_isLoading && widget.allowImport && !_isSingleAddressWallet)
              Padding(
                  padding: EdgeInsets.only(right: 15.0),
                  child: GestureDetector(
                    onTap: () async {
                      await Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => AccountsSelectActionScreen((chainType) async {
                                await Navigator.of(context).push(
                                    MaterialPageRoute(settings: RouteSettings(name: "/accountsImportScreen"), builder: (BuildContext context) => AccountsImportScreen(chainType)));
                              })));

                      await _init();
                    },
                    child: Icon(Icons.upload, size: 30.0, color: Theme.of(context).appBarTheme.actionsIconTheme.color),
                  )),
            if (!_isLoading && widget.allowChangeVisibility)
              Padding(
                  padding: EdgeInsets.only(right: 15.0),
                  child: GestureDetector(
                    onTap: () async {
                      await _save();
                    },
                    child: Icon(isSelectionMode ? Icons.save : Icons.visibility_outlined, size: 30.0, color: Theme.of(context).appBarTheme.actionsIconTheme.color),
                  ))
          ],
        ),
        floatingActionButton: _buildFloatingActionButton(context),
        body: PrimaryScrollController(controller: new ScrollController(), child: _buildAccountPage(context)));
  }
}
