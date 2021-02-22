import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_qr_reader/qrcode_reader_view.dart';

class QrCodeScan extends StatefulWidget {
  QrCodeScan();

  @override
  _QrCodeScanState createState() => new _QrCodeScanState();
}

class _QrCodeScanState extends State<QrCodeScan> {
  GlobalKey<QrcodeReaderViewState> _key = GlobalKey();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: QrcodeReaderView(
        key: _key,
        onScan: onScan,
        helpWidget: Scaffold(),
        headerWidget: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
        ),
      ),
    );
  }

  Future onScan(String data) async {
    Navigator.pop(context, data);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
