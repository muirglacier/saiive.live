import 'package:flutter/cupertino.dart';
import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/helper/env.dart';
import 'package:saiive.live/helper/version.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/util/sharedprefsutil.dart';

class VersionWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _VersionWidget();
}

class _VersionWidget extends State<VersionWidget> {
  EnvironmentType _environmentType = EnvironmentType.Unknonw;
  ChainNet _currentNet = ChainNet.Mainnet;
  String _version = " ";

  void init() async {
    _environmentType = EnvHelper.getEnvironment();
    _currentNet = await sl.get<SharedPrefsUtil>().getChainNetwork();
    _version = await VersionHelper().getVersion();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    init();
  }

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(
        ChainHelper.chainNetworkString(_currentNet),
        style: TextStyle(color: StateContainer.of(context).curTheme.appBarText),
      ),
      Text(
        _version,
        style: TextStyle(color: StateContainer.of(context).curTheme.appBarText),
      ),
      if (_environmentType != EnvironmentType.Production)
        Text(
          EnvHelper.environmentToString(_environmentType),
          style: TextStyle(color: StateContainer.of(context).curTheme.appBarText),
        )
    ]);
  }
}
