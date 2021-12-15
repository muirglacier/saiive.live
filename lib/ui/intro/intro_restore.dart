import 'dart:io';

import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/network/model/ivault.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/services/health_service.dart';
import 'package:saiive.live/ui/widgets/mnemonic_seed.dart';
import 'package:saiive.live/util/sharedprefsutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class IntroRestoreScreen extends StatefulWidget {
  @override
  _IntroRestoreScreenState createState() => _IntroRestoreScreenState();
}

class _IntroRestoreScreenState extends State<IntroRestoreScreen> {
  List<String> _phrase = [];

  Future saveSeed(String seed, bool singleWalletMode) async {
    var prefs = sl.get<ISharedPrefsUtil>();
    await prefs.setSeedBackedUp(true);
    await sl.get<IVault>().setSeed(seed);
  }

  @override
  void initState() {
    super.initState();

    sl.get<IHealthService>().checkHealth(context);
  }

  @override
  Widget build(BuildContext context) {
    if (dotenv.env["ENV"] == "dev") {
      var demoWords2 = "bubble year chase pair benefit swarm ripple pottery price device receive gain over loud give reopen point input menu execute daring much prefer sauce";

      if (Platform.isAndroid || Platform.isWindows) {
        demoWords2 =
            "wrong turtle frost decide labor verify correct north interest explain velvet mirror that frost alcohol brain ripple coach fortune verb surge suffer pizza rate";
        demoWords2 = "shaft blue often ring catalog marble prize tank canvas mention hope valve february dawn appear humor cloth maid color stage weather disagree result subway";
        demoWords2 = "bubble year chase pair benefit swarm ripple pottery price device receive gain over loud give reopen point input menu execute daring much prefer sauce";
        //demoWords2 = "rely denial exact surprise entire female lounge play put click charge finger leader true raven mobile inflict kitten lady topic caught input there apple";
      }
      //demoWords2 = "capital sick crisp frozen dial black syrup burden fruit loan material wheel giraffe slight sentence long cancel quit parrot arena wine island mutual praise";
      // demoWords2 = "";
      //WOLFI
      //demoWords2 = "glad village quantum off rely pretty emerge predict clump orphan crater space monster sleep trip remain cute into village drip proud siren clean middle";

      // demoWords2 = "entry sight penalty liquid wet draw lizard ozone carpet onion meat squeeze clay spare swim buzz escape satoshi tongue kit weekend alone budget half";

      // demoWords2 = "easily three name skate piece rain remove invest make try noise dizzy flight easily lonely orphan grow eagle gas grab lecture energy prepare online";
      _phrase = demoWords2.split(" ");
    }

    return Scaffold(
        appBar: AppBar(toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight, title: Text(S.of(context).welcome_wallet_restore)),
        body: MnemonicSeedWidget(
          words: _phrase,
          onNext: (seed, pathType, singleWalletMode) async {
            await saveSeed(seed, singleWalletMode);
            Navigator.of(context).pushNamedAndRemoveUntil("/intro_accounts_restore", (route) => false);
          },
        ));
  }
}
