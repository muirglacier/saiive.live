import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/crypto/database/wallet_database.dart';
import 'package:saiive.live/crypto/model/wallet_account.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/service_locator.dart';

class AccountsEditScreen extends StatefulWidget {
  final WalletAccount account;
  final bool isNewAccount;
  AccountsEditScreen(this.account, this.isNewAccount);

  @override
  State<StatefulWidget> createState() => _AccountsEditScreen();
}

class _AccountsEditScreen extends State<AccountsEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  initState() {
    super.initState();

    _nameController.text = widget.account.name;
  }

  _buildEditScreen(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                // The validator receives the text that the user has entered.
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return S.of(context).wallet_accounts_cannot_be_empty;
                  }
                  return null;
                },
              ),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      final walletDb = sl.get<IWalletDatabase>();

                      widget.account.name = _nameController.text;

                      walletDb.addOrUpdateAccount(widget.account);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(S.of(context).wallet_accounts_saved)));

                      Navigator.of(context).popUntil(ModalRoute.withName("/accounts"));
                    }
                  },
                  child: Text(widget.isNewAccount ? S.of(context).add : S.of(context).save),
                ),
              ),
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight,
          title: Text(S.of(context).wallet_accounts_select_type),
          actions: [],
        ),
        body: _buildEditScreen(context));
  }
}
