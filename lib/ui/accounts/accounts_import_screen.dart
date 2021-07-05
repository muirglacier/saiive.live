import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qr_reader/qrcode_reader_view.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/crypto/hd_wallet_util.dart';
import 'package:saiive.live/crypto/model/wallet_account.dart';
import 'package:saiive.live/crypto/wallet/address_type.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/helper/logger/LogHelper.dart';
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

  Future onScan(String data) async {
    LogHelper.instance.d(data);

    final currentNet = await sl.get<SharedPrefsUtil>().getChainNetwork();

    //propably a publicKey
    if (data.length == 34) {
      if (HdWalletUtil.isAddressValid(data, widget.chainType, currentNet)) {
        final walletAccount = WalletAccount(
            uniqueId: Uuid().v4(),
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
        final walletAccount = WalletAccount(
            uniqueId: Uuid().v4(),
            id: -1,
            chain: widget.chainType,
            account: -1,
            walletAccountType: WalletAccountType.PrivateKey,
            name: ChainHelper.chainTypeString(widget.chainType) + "_" + data[data.length - 1]);

        var p2sh = HdWalletUtil.getPublicAddressFromWif(data, widget.chainType, currentNet, AddressType.P2SHSegwit);

        Navigator.of(context).push(MaterialPageRoute(
            settings: RouteSettings(name: "/accountsEditScreen"),
            builder: (BuildContext context) => AccountsEditScreen(walletAccount, currentNet, true, p2sh, AddressType.Legacy, privateKey: data)));
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
      return Container();
    }
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
