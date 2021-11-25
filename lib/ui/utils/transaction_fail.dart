import 'package:azblob/azblob.dart';
import 'package:logger_flutter_console/logger_flutter_console.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/database/wallet_database_factory.dart';
import 'package:saiive.live/crypto/errors/NoUtxoError.dart';
import 'package:saiive.live/crypto/errors/ReadOnlyAccountError.dart';
import 'package:saiive.live/crypto/errors/TransactionError.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/helper/env.dart';
import 'package:saiive.live/helper/logger/LogHelper.dart';
import 'package:saiive.live/helper/version.dart';
import 'package:saiive.live/network/network_service.dart';
import 'package:flutter/material.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/ui/widgets/loading.dart';
import 'package:saiive.live/ui/widgets/loading_overlay.dart';
import 'package:saiive.live/util/sharedprefsutil.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

class TransactionFailScreen extends StatefulWidget {
  final String text;
  final ChainType chain;

  final String additional;
  final dynamic error;

  TransactionFailScreen(this.text, this.chain, {this.additional, this.error});

  @override
  _TransactionFailScreenState createState() => _TransactionFailScreenState();
}

class _TransactionFailScreenState extends State<TransactionFailScreen> {
  String _errorText;

  String _copyText;
  String _version;

  bool _isLoading = true;

  bool _isMissingUtxoError = false;
  String utxoRechargerUrl = "http://utxo.mydeficha.in/";

  _transformError() async {
    if (widget.error == null) {
      return;
    }
    var stackTrace = "";
    if (widget.error is Error) {
      stackTrace = (widget.error as Error).stackTrace.toString();
    }

    final sharedPrefsUtil = sl.get<ISharedPrefsUtil>();
    final network = await sharedPrefsUtil.getChainNetwork();
    final walletDatabase = await sl.get<IWalletDatabaseFactory>().getDatabase(this.widget.chain, network);

    final unspentTx = await walletDatabase.getUnspentTransactions();

    _copyText = "";
    _copyText += "\r\n";
    _copyText += _version;
    _copyText += "\r\n";
    _copyText += "Unspent transactions:";

    unspentTx.forEach((element) {
      _copyText += " * ${element.mintTxId} ${element.mintIndex} (${element.spentTxId})\r\n";
    });

    _copyText += "\r\n";

    if (widget.error is HttpException) {
      final httpError = widget.error as HttpException;
      _errorText = httpError.error.error;
      _copyText += _errorText + "\r\n" + stackTrace;
    } else if (widget.error is NoUtxoError) {
      _errorText = S.of(this.context).wallet_operation_no_utxo;
      _copyText += _errorText;
      _isMissingUtxoError = true;
    } else if (widget.error is TransactionError) {
      final txError = widget.error as TransactionError;
      _errorText = txError.error;

      _copyText += txError.copyText() + "\r\n" + stackTrace;
    } else if (widget.error is ReadOnlyAccountError) {
      _errorText = "We used a readonly address to create the transaction. This should not happen!";
      _copyText += _errorText;
    } else {
      _errorText = widget.error.toString();
      _copyText += _errorText + "\r\n" + stackTrace;
    }

    LogHelper.instance.e(_errorText);
  }

  _init() async {
    _version = await VersionHelper().getVersion();

    _transformError();

    setState(() {
      _isLoading = false;
    });
  }

  Future<dynamic> pasteAndShare() async {
    try {
      var buffer = LogConsole.getCachedEvents();

      var storage = AzureStorage.parse(EnvHelper.getAzBlobKey());

      var allCopyText = _errorText + "\r\n" + _copyText;
      allCopyText += "\r\n";
      allCopyText += "\r\n";
      allCopyText += "\r\n----- LOGS ----";
      allCopyText += "\r\n";
      buffer.forEach((event) {
        var text = event.lines.join('\n');
        allCopyText += text;
      });
      allCopyText += "\r\n";

      var id = Uuid().v4();

      final fileName = "/errors/$id.txt";
      await storage.putBlob(fileName, body: allCopyText);
      await Share.share(fileName, subject: "Error");
    } catch (e) {
      await Share.share(_copyText, subject: "Error");
    }
    return true;
  }

  @override
  void initState() {
    super.initState();

    _init();
  }

  Widget utxoRechagerLink(BuildContext context) {
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return LoadingWidget(text: S.of(context).loading);
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(
            S.of(context).wallet_operation_failed,
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        body: Padding(padding: EdgeInsets.all(10), child: Center(
            child: SingleChildScrollView(
                child: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.error_outline_outlined, size: 50),
          Text(
            widget.text,
            style: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.w800),
          ),
          if (widget.additional != null && widget.additional.isNotEmpty)
            Text(
              widget.additional,
              style: TextStyle(fontSize: 30, color: Colors.white),
            ),
          if (widget.error != null) SizedBox(height: 30),
          if (widget.error != null)
            SelectableText(
              _errorText,
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          if (widget.error != null) SizedBox(height: 30),
          Text(S.of(context).wallet_operation_share, style: TextStyle(fontSize: 30, color: Colors.white)),
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () async {
                  var pasteAndShareFuture = pasteAndShare();
                  final overlay = LoadingOverlay.of(context);
                  await overlay.during(pasteAndShareFuture);
                },
                child: Icon(Icons.share, size: 26.0, color: Colors.white),
              )),
          if (_isMissingUtxoError) utxoRechagerLink(context)
        ])))));
  }
}
