import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/crypto/model/wallet_account.dart';
import 'package:saiive.live/crypto/model/wallet_address.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/services/wallet_service.dart';
import 'package:saiive.live/ui/accounts/accounts_address_add_screen.dart';
import 'package:saiive.live/ui/wallet/wallet_receive.dart';
import 'package:saiive.live/ui/widgets/auto_resize_text.dart';
import 'package:saiive.live/ui/widgets/loading.dart';

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

  Future _init() async {
    _isLoading = true;
    _walletService = sl.get<IWalletService>();

    var accounts = await _walletService.getPublicKeysFromAccount(this.widget.walletAccount);

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
            trailing: Flexible(
              child: IconButton(
                  onPressed: () async {
                    await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => WalletReceiveScreen(chain: address.chain, pubKey: address.publicKey)));
                  },
                  icon: Icon(Icons.qr_code)),
            ),
            title: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start, children: [
              Text(address.name, style: Theme.of(context).textTheme.headline3),
              SizedBox(width: 10),
              AutoSizeText(address.publicKey, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.headline3, maxLines: 1),
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
        child: Scrollbar(
            child: Padding(
                padding: EdgeInsets.only(right: 10),
                child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: _walletAddresses.length,
                    itemBuilder: (context, index) {
                      return Expanded(child: _buildWalletAddressWidget(context, _walletAddresses.elementAt(index)));
                    }))));
  }

  _buildActionsButton(BuildContext context) {
    if (widget.walletAccount.walletAccountType != WalletAccountType.HdAccount) {
      return null;
    }
    return [
      Padding(
          padding: EdgeInsets.only(right: 15.0),
          child: GestureDetector(
            onTap: () async {
              await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => AccountsAddressAddScreen(widget.walletAccount, true)));

              await _init();
            },
            child: Icon(Icons.add, size: 30.0, color: Theme.of(context).appBarTheme.actionsIconTheme.color),
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
