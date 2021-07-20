import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/database/wallet_database_factory.dart';
import 'package:saiive.live/crypto/model/wallet_account.dart';
import 'package:saiive.live/crypto/model/wallet_address.dart';
import 'package:saiive.live/crypto/wallet/address_type.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/network/model/ivault.dart';
import 'package:saiive.live/service_locator.dart';

class AccountsEditScreen extends StatefulWidget {
  final WalletAccount account;
  final ChainNet network;
  final bool isNewAccount;
  final String publicKey;
  final AddressType addressType;
  final String privateKey;
  AccountsEditScreen(this.account, this.network, this.isNewAccount, this.publicKey, this.addressType, {this.privateKey});

  @override
  State<StatefulWidget> createState() => _AccountsEditScreen();
}

class _AccountsEditScreen extends State<AccountsEditScreen> {
  final _nameController = TextEditingController();

  @override
  initState() {
    super.initState();

    _nameController.text = widget.account.name;
  }

  _buildEditScreen(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
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
                if (_nameController.text != null && _nameController.text.isNotEmpty) {
                  final walletDbFactory = sl.get<IWalletDatabaseFactory>();
                  final walletDb = await walletDbFactory.getDatabase(widget.account.chain, widget.network);
                  widget.account.name = _nameController.text;

                  if (widget.isNewAccount) {
                    final walletAddress = WalletAddress(
                        accountId: widget.account.uniqueId,
                        index: -1,
                        chain: widget.account.chain,
                        account: -1,
                        isChangeAddress: false,
                        network: this.widget.network,
                        name: S.of(context).address,
                        publicKey: this.widget.publicKey,
                        addressType: this.widget.addressType);

                    if (this.widget.privateKey != null && this.widget.privateKey.isNotEmpty) {
                      await sl.get<IVault>().setPrivateKey(widget.account.uniqueId, widget.privateKey);
                    }

                    await walletDb.addAddress(walletAddress);
                  }
                  await walletDb.addOrUpdateAccount(widget.account);
                  Navigator.popUntil(context, ModalRoute.withName('/home'));
                  // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(S.of(context).wallet_accounts_saved)));
                }
              },
              child: Text(widget.isNewAccount ? S.of(context).add : S.of(context).save),
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
          title: Text(widget.isNewAccount ? S.of(context).wallet_accounts_add : S.of(context).wallet_accounts_edit),
          actions: [],
        ),
        body: _buildEditScreen(context));
  }
}
