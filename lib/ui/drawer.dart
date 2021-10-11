import 'package:flutter/material.dart';
import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/helper/env.dart';
import 'package:saiive.live/helper/version.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/util/sharedprefsutil.dart';

import 'home.dart';

typedef void DrawerItemSelected(NavigationEntry entry);

class SaiiveDrawer extends StatefulWidget {
  final List<NavigationEntry> navEntries;
  final DrawerItemSelected selectionCallback;

  SaiiveDrawer(this.navEntries, this.selectionCallback);

  @override
  State<StatefulWidget> createState() => _SaiiveDrawer();
}

class _SaiiveDrawer extends State<SaiiveDrawer> {
  EnvironmentType _environmentType = EnvironmentType.Unknonw;
  ChainNet _currentNet = ChainNet.Mainnet;
  String _version = " ";

  void _init() async {
    _environmentType = EnvHelper.getEnvironment();
    _currentNet = await sl.get<ISharedPrefsUtil>().getChainNetwork();
    _version = await VersionHelper().getVersion();

    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(padding: EdgeInsets.zero, children: <Widget>[
      DrawerHeader(
        decoration: BoxDecoration(
          color: StateContainer.of(context).curTheme.primary,
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Container(child: Image.asset('assets/logo_wh.png', height: 100)),
          Column(children: [
            Text(S.of(context).title, style: TextStyle(color: StateContainer.of(context).curTheme.appBarText)),
            Padding(padding: EdgeInsets.only(top: 5), child: Text(_version, style: TextStyle(color: StateContainer.of(context).curTheme.appBarText))),
            Padding(
                padding: EdgeInsets.only(top: 5),
                child: Text(ChainHelper.chainNetworkString(_currentNet), style: TextStyle(color: StateContainer.of(context).curTheme.appBarText))),
            if (_environmentType != EnvironmentType.Production)
              Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Text(EnvHelper.environmentToString(_environmentType), style: TextStyle(color: StateContainer.of(context).curTheme.appBarText)))
          ])
        ]),
      ),
      Scrollbar(
          child: ListView.builder(
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.vertical,
              padding: EdgeInsets.only(bottom: 100),
              shrinkWrap: true,
              itemCount: widget.navEntries.length,
              itemBuilder: (context, index) {
                final navItem = widget.navEntries[index];
                return ListTile(
                    title: Row(
                      children: [
                        Icon(navItem.icon.icon, color: StateContainer.of(context).curTheme.text),
                        Padding(
                            padding: EdgeInsets.only(left: 5),
                            child: Text(
                              navItem.label,
                              style: TextStyle(color: StateContainer.of(context).curTheme.text),
                            ))
                      ],
                    ),
                    onTap: () {
                      widget.selectionCallback(navItem);
                    });
              }))
    ]));
  }
}
