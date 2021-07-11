import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/database/wallet_database_factory.dart';
import 'package:saiive.live/crypto/model/wallet_account.dart';
import 'package:saiive.live/crypto/model/wallet_address.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/ui/accounts/accounts_screen.dart';
import 'package:saiive.live/ui/widgets/loading.dart';
import 'package:saiive.live/util/sharedprefsutil.dart';

class AccountSelectAddressWidget extends StatefulWidget {
  final Widget label;
  final ValueChanged<WalletAddress> onChanged;

  const AccountSelectAddressWidget({Key key, @required this.label, this.onChanged}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AccountSelectAddressWidget();
}

class _AccountSelectAddressWidget extends State<AccountSelectAddressWidget> {
  Map<String, WalletAccount> _walletAccounts = {};
  List<WalletAddress> _walletAddresses = List<WalletAddress>.empty(growable: true);

  WalletAddress _selectedWalletAddress;

  bool _isLoading = true;
  _reset() {
    setState(() {
      _walletAccounts.clear();
      _walletAddresses.clear();
      _isLoading = true;
      _selectedWalletAddress = null;
    });
  }

  _init() async {
    _reset();
    final currentNet = await sl.get<SharedPrefsUtil>().getChainNetwork();
    final database = await sl.get<IWalletDatabaseFactory>().getDatabase(ChainType.DeFiChain, currentNet);

    final accounts = await database.getAccounts();

    for (final acc in accounts) {
      if (acc.selected) {
        final addresses = await database.getWalletAddressesById(acc.uniqueId);
        _walletAddresses.addAll(addresses);
        _walletAccounts.putIfAbsent(acc.uniqueId, () => acc);

        if (_selectedWalletAddress == null && _walletAddresses.isNotEmpty) {
          _selectedWalletAddress = _walletAddresses.last;
          if (widget.onChanged != null) {
            widget.onChanged(_selectedWalletAddress);
          }
        }
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();

    _init();
  }

  _buildDropdownListItem(WalletAddress e) {
    return Row(
      children: [
        Padding(padding: EdgeInsets.only(right: 10), child: Text(e.name)),
        Expanded(
          flex: 1,
          child: AutoSizeText(
            e.publicKey,
            style: Theme.of(context).textTheme.headline6,
            maxLines: 1,
          ),
        )
      ],
    );
  }

  _buildDropDown(BuildContext context) {
    if (_walletAddresses.isEmpty) {
      return Text(
        S.of(context).wallet_accounts_create,
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      );
    }
    return DropdownButton<WalletAddress>(
      isExpanded: true,
      hint: Text(S.of(context).dex_from_token),
      value: _selectedWalletAddress,
      onChanged: (WalletAddress newValue) {
        setState(() {
          _selectedWalletAddress = newValue;
        });
        if (widget.onChanged != null) {
          widget.onChanged(newValue);
        }
      },
      items: _walletAddresses.map((e) {
        return new DropdownMenuItem<WalletAddress>(
          value: e,
          child: _buildDropdownListItem(e),
        );
      }).toList(),
    );
  }

  _buildWidget(BuildContext context) {
    if (_isLoading) {
      return Center(child: LoadingWidget(text: S.of(context).loading));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      widget.label,
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(flex: 1, child: Container(height: 60, child: _buildDropDown(context))),
          Padding(
              padding: EdgeInsets.only(bottom: _walletAddresses.isEmpty ? 30 : 10),
              child: IconButton(
                  onPressed: () async {
                    await Navigator.of(context).push(MaterialPageRoute(
                        settings: RouteSettings(name: "/accounts"),
                        builder: (BuildContext context) => AccountsScreen(
                              allowChangeVisibility: false,
                              allowImport: false,
                            )));
                    await _init();
                  },
                  icon: Icon(Icons.add)))
        ],
      )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return _buildWidget(context);
  }
}
