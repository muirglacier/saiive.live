import 'package:defichainwallet/defi_chain_wallet_app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as DotEnv;

void main() async {
  await DotEnv.load(fileName: "assets/env/.env-Staging");

  run();
}
