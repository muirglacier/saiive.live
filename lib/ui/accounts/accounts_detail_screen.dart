import 'package:flutter/material.dart';
import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/crypto/database/wallet_database_factory.dart';
import 'package:saiive.live/crypto/model/wallet_account.dart';
import 'package:saiive.live/crypto/model/wallet_address.dart';
import 'package:saiive.live/crypto/wallet/address_type.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/services/wallet_service.dart';
import 'package:saiive.live/ui/accounts/accounts_add_screen.dart';
import 'package:saiive.live/ui/accounts/accounts_address_add_screen.dart';
import 'package:saiive.live/ui/utils/authentication_helper.dart';
import 'package:saiive.live/ui/wallet/wallet_receive.dart';
import 'package:saiive.live/ui/widgets/auto_resize_text.dart';
import 'package:saiive.live/ui/widgets/loading.dart';
import 'package:saiive.live/util/sharedprefsutil.dart';

class AccountsDetailScreen extends StatefulWidget {
  final WalletAccount walletAccount;
  AccountsDetailScreen(this.walletAccount);

  @override
  State<StatefulWidget> createState() => _AccountsDetailScreen();
}

class _AccountsDetailScreen extends State<AccountsDetailScreen> {
  List<WalletAddress> _walletAddresses;
  bool _isLoading = true;

  IWalletService _walletService;
  bool _isSingleAddressWallet = false;

  Future _init() async {
    _isLoading = true;
    _walletService = sl.get<IWalletService>();

    _isSingleAddressWallet = await sl.get<ISharedPrefsUtil>().getUseSingleAddressWallet();

    var accounts = await _walletService.getPublicKeysFromAccount(this.widget.walletAccount);

    accounts.sort((a, b) => a.index.compareTo(b.index));

    setState(() {
      _walletAddresses = accounts;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();

    _init();
  }

  Widget _buildWalletAddressWidget(BuildContext context, WalletAddress address) {
    return Card(
        child: ListTile(
            trailing: IconButton(
                onPressed: () async {
                  await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => WalletReceiveScreen(chain: address.chain, pubKey: address.publicKey)));
                },
                icon: Icon(Icons.qr_code)),
            title: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start, children: [
              if (address.name != null) Text(address.name, style: Theme.of(context).textTheme.headline3),
              SizedBox(width: 10),
              AutoSizeText(address.publicKey, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.headline3, maxLines: 1),
              Row(
                children: [
                  AutoSizeText(address.path(widget.walletAccount), overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.caption, maxLines: 1),
                  SizedBox(width: 10),
                  AutoSizeText(addressTypeToString(address.addressType), overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.caption, maxLines: 1),
                ],
              )
            ]),
            onTap: () async {
              await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => AccountsAddressAddScreen(widget.walletAccount, false, walletAddress: address)));

              await _init();
            }));
  }

  Widget _buildAccountPage(BuildContext context) {
    if (_isLoading) {
      return LoadingWidget(text: S.of(context).loading);
    }
    if (_walletAddresses.isEmpty) {
      return Center(child: Text(S.of(context).wallet_accounts_empty));
    }

    return Padding(
        padding: EdgeInsets.all(10),
        child: Padding(
            padding: EdgeInsets.only(right: 10),
            child: ListView.builder(
                physics: BouncingScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: _walletAddresses.length,
                itemBuilder: (context, index) {
                  return _buildWalletAddressWidget(context, _walletAddresses.elementAt(index));
                })));
  }

  List<Widget> _buildActionsButton(BuildContext context) {
    return [
      Padding(
          padding: EdgeInsets.only(right: 15.0),
          child: GestureDetector(
            onTap: () async {
              await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => AccountsAddScreen(widget.walletAccount.chain, widget.walletAccount, false)));

              await _init();
            },
            child: Icon(Icons.edit, size: 30.0, color: Theme.of(context).appBarTheme.actionsIconTheme.color),
          )),
      if (widget.walletAccount.walletAccountType == WalletAccountType.HdAccount && !_isSingleAddressWallet)
        Padding(
            padding: EdgeInsets.only(right: 15.0),
            child: GestureDetector(
              onTap: () async {
                await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => AccountsAddressAddScreen(widget.walletAccount, true)));

                await _init();
              },
              child: Icon(Icons.add, size: 30.0, color: Theme.of(context).appBarTheme.actionsIconTheme.color),
            )),
      if (!_isSingleAddressWallet)
        Padding(
            padding: EdgeInsets.only(right: 15.0),
            child: GestureDetector(
              onTap: () async {
                Widget okButton = TextButton(
                  child: Text(S.of(context).ok),
                  onPressed: () async {
                    sl.get<AuthenticationHelper>().forceAuth(context, () async {
                      final walletDbFactory = sl.get<IWalletDatabaseFactory>();
                      final currentNet = await sl.get<ISharedPrefsUtil>().getChainNetwork();
                      final walletDb = await walletDbFactory.getDatabase(widget.walletAccount.chain, currentNet);

                      await walletDb.removeAccount(widget.walletAccount);

                      Navigator.of(context, rootNavigator: true).popUntil(ModalRoute.withName("/home"));
                    });

                    // await doChainNetSwitch(net, _curNet);
                  },
                );
                Widget cancelButton = TextButton(
                  child: Text(S.of(context).cancel),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                );

                // set up the AlertDialog
                AlertDialog alert = AlertDialog(
                  title: Text(S.of(context).delete),
                  content: Text(S.of(context).wallet_accounts_delete),
                  actions: [okButton, cancelButton],
                );

                // show the dialog
                await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return alert;
                  },
                );
              },
              child: Icon(Icons.delete, size: 30.0, color: Theme.of(context).appBarTheme.actionsIconTheme.color),
            ))
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight,
          title: Text(S.of(context).wallet_accounts_detail),
          actions: _buildActionsButton(context),
        ),
        body: _buildAccountPage(context));
  }
}
