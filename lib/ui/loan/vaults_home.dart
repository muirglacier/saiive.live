import 'dart:async';
import 'dart:io';

import 'package:event_taxi/event_taxi.dart';
import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/network/events/vaults_sync_start_event.dart';
import 'package:saiive.live/ui/loan/vault_create.dart';
import 'package:saiive.live/ui/loan/vault_tokens.dart';
import 'package:saiive.live/ui/loan/vaults.dart';
import 'package:flutter/material.dart';

class VaultsHomeScreen extends StatefulWidget {
  const VaultsHomeScreen({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _VaultsHomeScreen();
  }
}

class _VaultsHomeScreen extends State<VaultsHomeScreen> with SingleTickerProviderStateMixin {
  TabController _tabController;
  int _selectedIndex = 0;

  var _tabs = [VaultTokensScreen(), VaultsScreen()];

  StreamSubscription<VaultSyncStartEvent> _vaultSyncStartEvent;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);

    _tabController.addListener(() {
      _selectedIndex = _tabController.index;
    });

    if (_vaultSyncStartEvent == null) {
      _vaultSyncStartEvent = EventTaxiImpl.singleton().registerTo<VaultSyncStartEvent>().listen((event) async {
        _tabs[0].refresh();
        _tabs[1].refresh();
      });
    }

    super.initState();
  }

  @override
  void deactivate() {
    super.deactivate();

    if (_vaultSyncStartEvent != null) {
      _vaultSyncStartEvent.cancel();
      _vaultSyncStartEvent = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight,
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: S.of(context).loan_browse_loans),
                Tab(text: S.of(context).loan_your_loans),
              ],
            ),
            title: Row(children: [
              if (Platform.isAndroid || Platform.isIOS || Platform.isFuchsia)
                Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () {
                        var key = StateContainer.of(context).scaffoldKey;
                        key.currentState.openDrawer();
                      },
                      child: Icon(Icons.view_headline, size: 26.0, color: Theme.of(context).appBarTheme.actionsIconTheme.color),
                    )),
              Text(S.of(context).loan_vaults)
            ]),
            actions: [
              Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    onTap: () async {
                      await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => VaultCreateScreen()));
                    },
                    child: Icon(Icons.add, size: 26.0, color: Theme.of(context).appBarTheme.actionsIconTheme.color),
                  )),
              Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    onTap: () {
                      _tabs[_selectedIndex].refresh();
                    },
                    child: Icon(Icons.refresh, size: 26.0, color: Theme.of(context).appBarTheme.actionsIconTheme.color),
                  )),
            ],
          ),
          body: TabBarView(
            children: _tabs,
            controller: _tabController,
          ),
        ));
  }
}
