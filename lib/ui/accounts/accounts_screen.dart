import 'dart:io';

import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/model/wallet_account.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/network/events/wallet_sync_start_event.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/services/wallet_service.dart';
import 'package:saiive.live/ui/accounts/accounts_detail_screen.dart';
import 'package:saiive.live/ui/accounts/accounts_select_action_screen.dart';
import 'package:saiive.live/ui/widgets/loading.dart';

import 'accounts_import_screen.dart';

class AccountsScreen extends StatefulWidget {
  final allowChangeVisibility;
  final allowImport;
  AccountsScreen({this.allowChangeVisibility = true, this.allowImport = true});

  @override
  State<StatefulWidget> createState() => _AccountScreen();
}

class _AccountScreen extends State<AccountsScreen> {
  List<WalletAccount> _walletAccounts = List<WalletAccount>.empty();
  bool _isLoading = false;

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
      setState(() {
        account.selected = !account.selected;
      });
    } else {
      await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => AccountsDetailScreen(account)));
    }
  }

  void _init() async {
    _walletService = sl.get<IWalletService>();

    var accounts = await _walletService.getAccounts();

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
      return [
        Text(WalletAccount.getStringForWalletAccountType(account.walletAccountType)),
        Text(" | Id: ", style: Theme.of(context).textTheme.bodyText1),
        Text(account.account.toString(), style: Theme.of(context).textTheme.bodyText1),
      ];
    }

    return [Text(WalletAccount.getStringForWalletAccountType(account.walletAccountType))];
  }

  Widget _buildSelectIcon(bool isSelected, WalletAccount account) {
    if (isSelectionMode) {
      return Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start, children: [
        Icon(
          isSelected ? Icons.check_box : Icons.check_box_outline_blank,
          color: Theme.of(context).primaryColor,
        ),
        SizedBox(width: 10),
        Text(account.name, style: Theme.of(context).textTheme.headline3)
      ]);
    } else {
      return Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start, children: [
        Icon(
          isSelected ? Icons.visibility : Icons.visibility_off,
          color: Theme.of(context).primaryColor,
        ),
        SizedBox(width: 10),
        Text(account.name, style: Theme.of(context).textTheme.headline3)
      ]);
    }
  }

  Widget _buildAccountEntry(BuildContext context, WalletAccount account) {
    return Card(
        child: ListTile(
      leading: SizedBox(width: 100, child: _buildSelectIcon(account.selected, account)),
      title: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Row(children: _buildPublicKeyAddress(context, account))]),
      trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text(ChainHelper.chainTypeString(account.chain), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500))]),
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
        child: Scrollbar(
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
                ]))));
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
            Text(S.of(context).wallet_accounts)
          ]),
          actions: [
            // Padding(
            //     padding: EdgeInsets.only(right: 15.0),
            //     child: GestureDetector(
            //       onTap: () {
            //         Navigator.of(context).push(MaterialPageRoute(
            //             builder: (BuildContext context) => AccountsSelectActionScreen((chainType) {
            //                   Navigator.of(context)
            //                       .push(MaterialPageRoute(settings: RouteSettings(name: "/accountsAddScreen"), builder: (BuildContext context) => AccountsAddScreen(chainType)));
            //                 })));
            //       },
            //       child: Icon(Icons.add, size: 30.0, color: Theme.of(context).appBarTheme.actionsIconTheme.color),
            //     )),
            if (!_isLoading && widget.allowImport)
              Padding(
                  padding: EdgeInsets.only(right: 15.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => AccountsSelectActionScreen((chainType) {
                                Navigator.of(context).push(
                                    MaterialPageRoute(settings: RouteSettings(name: "/accountsImportScreen"), builder: (BuildContext context) => AccountsImportScreen(chainType)));
                              })));
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
        body: _buildAccountPage(context));
  }
}
