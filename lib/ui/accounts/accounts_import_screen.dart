import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qr_reader/qrcode_reader_view.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/crypto/hd_wallet_util.dart';
import 'package:saiive.live/crypto/database/wallet_database.dart';
import 'package:saiive.live/crypto/database/wallet_database_factory.dart';
import 'package:saiive.live/crypto/model/wallet_account.dart';
import 'package:saiive.live/crypto/wallet/address_type.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/helper/logger/LogHelper.dart';
import 'package:saiive.live/network/model/ivault.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/ui/accounts/accounts_edit_screen.dart';
import 'package:saiive.live/util/sharedprefsutil.dart';
import 'package:uuid/uuid.dart';

class AccountsImportScreen extends StatefulWidget {
  final ChainType chainType;

  AccountsImportScreen(this.chainType);

  @override
  State<StatefulWidget> createState() => _AccountsImportScreen();
}

class _AccountsImportScreen extends State<AccountsImportScreen> {
  bool _cameraAllowed = false;

  final _keyController = TextEditingController();

  _init() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return;
    }

    var status = await Permission.camera.status;
    if (!status.isGranted) {
      final permission = await Permission.camera.request();

      if (!permission.isGranted) {
        return;
      }
    }
    setState(() {
      _cameraAllowed = true;
    });
  }

  @override
  initState() {
    super.initState();
    _init();
  }

  popToAccountsPage() {
    Navigator.of(context).popUntil(ModalRoute.withName("/accounts"));
  }

  Future shouldImportPrivateKeyForPublicKey(String pubKey, String privKey, IWalletDatabase database) async {
    var walletAddress = await database.getWalletAddress(pubKey);
    var walletAccount = await database.getAccount(walletAddress.accountId);

    var import = ElevatedButton(
      child: Text(S.of(context).ok),
      onPressed: () async {
        try {
          walletAccount.walletAccountType = WalletAccountType.PrivateKey;
          await sl.get<IVault>().setPrivateKey(walletAccount.uniqueId, privKey);
          await database.addOrUpdateAccount(walletAccount);
        } finally {
          Navigator.of(context).pop();
        }
      },
    );
    var cancel = ElevatedButton(
      child: Text(S.of(context).cancel),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text(S.of(context).wallet_accounts_import),
      content: Text(S.of(context).wallet_accounts_import_priv_key_for_pub_key(pubKey)),
      actions: [
        import,
        cancel,
      ],
    );
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future onScan(String data) async {
    LogHelper.instance.d(data);

    final currentNet = await sl.get<SharedPrefsUtil>().getChainNetwork();

    //propably a publicKey
    if (data.length == 34) {
      if (HdWalletUtil.isAddressValid(data, widget.chainType, currentNet)) {
        final walletAccount = WalletAccount(Uuid().v4(),
            id: -1,
            chain: widget.chainType,
            account: -1,
            walletAccountType: WalletAccountType.PublicKey,
            name: ChainHelper.chainTypeString(widget.chainType) + "_" + data[data.length - 1]);

        Navigator.of(context).push(MaterialPageRoute(
            settings: RouteSettings(name: "/accountsEditScreen"),
            builder: (BuildContext context) => AccountsEditScreen(walletAccount, currentNet, true, data, AddressType.Legacy, privateKey: null)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(S.of(context).wallet_accounts_import_invalid_pub_key),
        ));
        popToAccountsPage();
      }
    }
    //propably a privateKey
    else if (data.length == 52) {
      if (HdWalletUtil.isPrivateKeyValid(data, widget.chainType, currentNet)) {
        final walletAccount = WalletAccount(Uuid().v4(),
            id: -1,
            chain: widget.chainType,
            account: -1,
            walletAccountType: WalletAccountType.PrivateKey,
            name: ChainHelper.chainTypeString(widget.chainType) + "_" + data[data.length - 1]);

        var p2sh = HdWalletUtil.getPublicAddressFromWif(data, widget.chainType, currentNet, AddressType.P2SHSegwit);
        final walletDbFactory = sl.get<IWalletDatabaseFactory>();
        final walletDb = await walletDbFactory.getDatabase(widget.chainType, currentNet);

        final isOwnAddress = await walletDb.isOwnAddress(p2sh);

        if (isOwnAddress) {
          await shouldImportPrivateKeyForPublicKey(p2sh, data, walletDb);
          popToAccountsPage();
        } else {
          Navigator.of(context).push(MaterialPageRoute(
              settings: RouteSettings(name: "/accountsEditScreen"),
              builder: (BuildContext context) => AccountsEditScreen(walletAccount, currentNet, true, p2sh, AddressType.Legacy, privateKey: data)));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(S.of(context).wallet_accounts_import_invalid_priv_key),
        ));
        popToAccountsPage();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(S.of(context).wallet_accounts_import_invalid),
      ));
      popToAccountsPage();
    }
  }

  _buildAccountAddScreen(BuildContext context) {
    if (Platform.isAndroid || Platform.isLinux || Platform.isIOS) {
      if (_cameraAllowed) {
        return Center(
            child: QrcodeReaderView(
                onScan: onScan,
                helpWidget: Container(),
                headerWidget: AppBar(
                  toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight,
                  backgroundColor: Colors.transparent,
                  elevation: 0.0,
                )));
      }
    }
    return Padding(
        padding: EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          TextFormField(
            controller: _keyController,
            // The validator receives the text that the user has entered.
            validator: (value) {
              if (value == null || value.isEmpty) {
                return S.of(context).wallet_accounts_cannot_be_empty;
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          Center(
              child: ElevatedButton(
                  child: Text(S.of(context).wallet_accounts_import),
                  onPressed: () async {
                    if (_keyController.text != null && _keyController.text.isNotEmpty) {
                      await onScan(_keyController.text);
                    }
                  }))
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight,
          title: Text(S.of(context).wallet_accounts_import),
          actions: [],
        ),
        body: _buildAccountAddScreen(context));
  }
}
