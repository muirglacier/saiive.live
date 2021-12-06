import 'package:flutter/material.dart';
import 'package:saiive.live/appcenter/appcenter.dart';
import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/model/wallet_account.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/services/wallet_service.dart';
import 'package:saiive.live/ui/widgets/derivation_path_type_selector_widget.dart';
import 'package:uuid/uuid.dart';

class AccountsAddScreen extends StatefulWidget {
  final ChainType chainType;
  final WalletAccount walletAccount;
  final bool isNewAddress;

  AccountsAddScreen(this.chainType, this.walletAccount, this.isNewAddress);

  @override
  State<StatefulWidget> createState() => _AccountsAddScreen();
}

class _AccountsAddScreen extends State<AccountsAddScreen> {
  final _nameController = TextEditingController();

  PathDerivationType _pathDerivationType = PathDerivationType.FullNodeWallet;

  int _accountIndex = 0;

  IWalletService _walletService;
  List<WalletAccount> _allAccounts = [];

  _init() async {
    if (!widget.isNewAddress) {
      _nameController.text = widget.walletAccount.name;

      _pathDerivationType = widget.walletAccount.derivationPathType;
      setState(() {});
    }

    _walletService = sl.get<IWalletService>();
    var allAccounts = await _walletService.getAccountsForChain(widget.chainType);
    setState(() {
      _allAccounts = allAccounts;
    });
    if (widget.isNewAddress) {
      setNextAccountIndex();
    } else {
      _accountIndex = widget.walletAccount.account;
    }
  }

  setNextAccountIndex() {
    var walletAccounts = _allAccounts.where((element) => element.derivationPathType == _pathDerivationType).toList();
    walletAccounts.sort((a, b) => a.account.compareTo(b.account));

    if (walletAccounts.isEmpty) {
      setState(() {
        _accountIndex = 0;
      });
    } else {
      setState(() {
        _accountIndex = walletAccounts.last.account + 1;
      });
    }
  }

  @override
  initState() {
    super.initState();

    _init();
  }

  Widget buildDerivationPathType(BuildContext context) {
    if (widget.isNewAddress) {
      return Column(children: [
        DerivationPathTypeSelectorWidget(
            onChanged: (v) {
              setState(() {
                this._pathDerivationType = v;
              });
              setNextAccountIndex();
            },
            isExpanded: true),
        Row(children: [Text(S.of(context).wallet_account_index), Text(":"), SizedBox(width: 10), Text(_accountIndex.toString())])
      ]);
    }

    return Column(children: [
      Row(children: [Text(S.of(context).wallet_new_phrase_path_derivation_type), Text(":"), SizedBox(width: 10), Text(pathDerivationTypeString(_pathDerivationType))]),
      SizedBox(height: 10),
      Row(children: [Text(S.of(context).wallet_account_index), Text(":"), SizedBox(width: 10), Text(_accountIndex.toString())])
    ]);
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
          buildDerivationPathType(context),
          SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: () async {
                try {
                  if (_nameController.text != null && _nameController.text.isNotEmpty) {
                    final walletService = sl.get<IWalletService>();

                    var walletAccount = widget.walletAccount;

                    if (widget.isNewAddress) {
                      walletAccount = new WalletAccount(Uuid().v4(),
                          id: _accountIndex,
                          chain: widget.chainType,
                          account: _accountIndex,
                          walletAccountType: WalletAccountType.HdAccount,
                          name: _nameController.text,
                          derivationPathType: _pathDerivationType,
                          selected: true);
                    }

                    walletAccount.name = _nameController.text;
                    await walletService.addAccount(walletAccount);

                    if (widget.isNewAddress) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    } else {
                      Navigator.of(context).pop();
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(S.of(context).wallet_accounts_cannot_be_empty)));
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
