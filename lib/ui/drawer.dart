import 'package:flutter/material.dart';
import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/generated/l10n.dart';

import 'home.dart';

typedef void DrawerItemSelected(NavigationEntry entry);

class DrawerUtil {
  static Drawer createDrawer(BuildContext context, List<NavigationEntry> navEntries, DrawerItemSelected selectionCallback,
      {EnvironmentType env, String version, ChainNet network}) {
    return Drawer(
        child: ListView(padding: EdgeInsets.zero, children: <Widget>[
      DrawerHeader(
        decoration: BoxDecoration(
          color: StateContainer.of(context).curTheme.primary,
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Container(child: Image.asset('assets/logo_wh.png', height: 100)),
          Column(children: [Text(S.of(context).title), Text(version)])
        ]),
      ),
      Expanded(
          child: Scrollbar(
              child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  padding: EdgeInsets.only(bottom: 100),
                  shrinkWrap: true,
                  itemCount: navEntries.length,
                  itemBuilder: (context, index) {
                    final navItem = navEntries[index];
                    return ListTile(
                        title: Row(
                          children: [navItem.icon, Padding(padding: EdgeInsets.only(left: 5), child: Text(navItem.label))],
                        ),
                        onTap: () {
                          selectionCallback(navItem);
                        });
                  })))
    ]));
  }
}
