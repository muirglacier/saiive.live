import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:saiive.live/defi_chain_wallet_app.dart';

void main() async {
  await dotenv.load(fileName: "assets/env/.env-Prod");

  run();
}
