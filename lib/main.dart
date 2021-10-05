import 'dart:io';

import 'package:saiive.live/defi_chain_wallet_app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as DotEnv;

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        return true;
      };
  }
}

void main() async {
  await DotEnv.load(fileName: "assets/env/.env-Debug");
  HttpOverrides.global = new MyHttpOverrides();
  run();
}
