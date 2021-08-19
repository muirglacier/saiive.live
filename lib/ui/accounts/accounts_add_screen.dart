import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:saiive.live/appcenter/appcenter.dart';
import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/crypto/model/wallet_account.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/services/wallet_service.dart';

class AccountsAddScreen extends StatefulWidget {
  final WalletAccount walletAccount;
  final bool isNewAddress;

  AccountsAddScreen(this.walletAccount, this.isNewAddress);

  @override
  State<StatefulWidget> createState() => _AccountsAddScreen();
}

class _AccountsAddScreen extends State<AccountsAddScreen> {
  final _nameController = TextEditingController();

  _init() {
    if (!widget.isNewAddress) {
      _nameController.text = widget.walletAccount.name;
      setState(() {});
    }
  }

  @override
  initState() {
    super.initState();
    _init();
  }

  _buildAccountAddScreen(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            controller: _nameController,
            decoration: InputDecoration(hintText: S.of(context).label),
          ),
          SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: () async {
                try {
                  if (_nameController.text != null && _nameController.text.isNotEmpty) {
                    final walletService = sl.get<IWalletService>();

                    widget.walletAccount.name = _nameController.text;
                    await walletService.addAccount(widget.walletAccount);

                    Navigator.of(context).pop();
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(S.of(context).wallet_offline(e.toString()))));
                  sl.get<AppCenterWrapper>().trackEvent("addAccountError", <String, String>{'error': e.toString()});
                }
              },
              child: Text(widget.isNewAddress ? S.of(context).add : S.of(context).save),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight,
          title: Text(widget.isNewAddress ? S.of(context).wallet_accounts_add : S.of(context).wallet_accounts_edit),
          actions: [],
        ),
        body: SingleChildScrollView(child: _buildAccountAddScreen(context)));
  }
}
