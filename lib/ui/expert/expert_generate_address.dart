import 'package:flutter/material.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/model/wallet_account.dart';
import 'package:saiive.live/crypto/wallet/address_type.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/services/wallet_service.dart';
import 'package:saiive.live/ui/accounts/accounts_address_add_screen.dart';
import 'package:saiive.live/ui/utils/token_icon.dart';
import 'package:saiive.live/ui/widgets/loading.dart';

class ExpertAddressScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ExpertAddressScreen();
}

class _ExpertAddressScreen extends State<ExpertAddressScreen> {
  TextEditingController _addressController = TextEditingController(text: "0");
  List<WalletAccount> _walletAccounts = List<WalletAccount>.empty();
  IWalletService _walletService;

  bool _isLoading = false;

  WalletAccount _selectedWalletAccount;
  bool _isChangeAddress = false;
  int _index = 0;
  AddressType _addressType = AddressType.P2SHSegwit;

  _init() async {
    _walletService = sl.get<IWalletService>();
    var accounts = await _walletService.getAccounts();

    setState(() {
      _walletAccounts = accounts;
      _selectedWalletAccount = accounts.first;
      _isLoading = false;
    });
  }

  @override
  initState() {
    super.initState();

    _addressController.addListener(() {
      final index = int.parse(_addressController.text.replaceAll(',', '.'));
      setState(() {
        _index = index;
      });
    });

    _init();
  }

  _doGenerateAddress() async {
    final address = await _walletService.generateAddress(_selectedWalletAccount, _isChangeAddress, _index, _addressType);

    await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => AccountsAddressAddScreen(_selectedWalletAccount, false, walletAddress: address)));
  }

  _buildWalletAccountDropdownListItem(WalletAccount e) {
    return Row(
      children: [
        TokenIcon(ChainHelper.chainTypeString(e.chain)),
        SizedBox(width: 10),
        Padding(padding: EdgeInsets.only(right: 10), child: Text(e.name)),
      ],
    );
  }

  _buildSelectWalletAccount(BuildContext context) {
    if (_walletAccounts.isEmpty) {
      return Text(
        S.of(context).wallet_accounts_create,
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      );
    }
    return DropdownButton<WalletAccount>(
      isExpanded: true,
      hint: Text(S.of(context).dex_from_token),
      value: _selectedWalletAccount,
      onChanged: (WalletAccount newValue) {
        setState(() {
          _selectedWalletAccount = newValue;
        });
      },
      items: _walletAccounts.map((e) {
        return new DropdownMenuItem<WalletAccount>(
          value: e,
          child: _buildWalletAccountDropdownListItem(e),
        );
      }).toList(),
    );
  }

  _buildAddressType(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: const Text('Default'),
          leading: Radio<AddressType>(
            value: AddressType.P2SHSegwit,
            groupValue: _addressType,
            onChanged: (AddressType value) {
              setState(() {
                _addressType = value;
              });
            },
          ),
        ),
        ListTile(
          title: const Text('Legacy'),
          leading: Radio<AddressType>(
            value: AddressType.Legacy,
            groupValue: _addressType,
            onChanged: (AddressType value) {
              setState(() {
                _addressType = value;
              });
            },
          ),
        ),
        ListTile(
          title: const Text('Bech32'),
          leading: Radio<AddressType>(
            value: AddressType.Bech32,
            groupValue: _addressType,
            onChanged: (AddressType value) {
              setState(() {
                _addressType = value;
              });
            },
          ),
        ),
      ],
    );
  }

  _buildIndex(BuildContext context) {
    return TextField(controller: _addressController, keyboardType: TextInputType.number);
  }

  _buildIsReturnAddress(BuildContext context) {
    return Row(children: [
      Checkbox(
        value: _isChangeAddress,
        onChanged: (v) {
          setState(() {
            _isChangeAddress = v;
          });
        },
      ),
      Text("IsChangeAddress")
    ]);
  }

  _buildScreen(BuildContext context) {
    if (_isLoading) {
      return Center(child: LoadingWidget(text: S.of(context).loading));
    }
    return Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildSelectWalletAccount(context),
      SizedBox(height: 10),
      _buildIsReturnAddress(context),
      SizedBox(height: 10),
      Container(child: Text("Index:")),
      _buildIndex(context),
      SizedBox(height: 10),
      Container(child: Text("Address type:")),
      _buildAddressType(context),
      SizedBox(height: 10),
      ElevatedButton(
          child: Text("Generate"),
          onPressed: () async {
            await _doGenerateAddress();
          })
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Expert generate address mode")),
        body: PrimaryScrollController(controller: new ScrollController(), child: SingleChildScrollView(child: Padding(padding: EdgeInsets.all(10), child: _buildScreen(context)))));
  }
}
