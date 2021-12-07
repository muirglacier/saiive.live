import 'dart:async';
import 'dart:io';

import 'package:event_taxi/event_taxi.dart';
import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/network/events/vaults_sync_start_event.dart';
import 'package:saiive.live/ui/loan/auctions.dart';
import 'package:saiive.live/ui/loan/vault_create.dart';
import 'package:saiive.live/ui/loan/vault_tokens.dart';
import 'package:saiive.live/ui/loan/vaults.dart';
import 'package:flutter/material.dart';
import 'package:saiive.live/util/search_able_widget.dart';

class VaultsHomeScreen extends StatefulWidget {
  const VaultsHomeScreen({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _VaultsHomeScreen();
  }
}

class _VaultsHomeScreen extends State<VaultsHomeScreen> with SingleTickerProviderStateMixin {
  TabController _tabController;
  var _searchController = TextEditingController(text: '');
  FocusNode _searchFocusNode;
  int _selectedIndex = 0;
  bool _search = false;
  bool _auctionFilterBuyable = false;

  var _tabs = [VaultsScreen(), VaultTokensScreen(), AuctionsScreen()];

  StreamSubscription<VaultSyncStartEvent> _vaultSyncStartEvent;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
        _search = false;
      });
    });

    _searchFocusNode = new FocusNode();
    _searchController.addListener(handleSearch);

    if (_vaultSyncStartEvent == null) {
      _vaultSyncStartEvent = EventTaxiImpl.singleton().registerTo<VaultSyncStartEvent>().listen((event) async {
        _tabs[0].refresh();
        _tabs[1].refresh();
        _tabs[2].refresh();
      });
    }

    super.initState();
  }

  handleSearch() async {
    String text = _searchController.text;
    var tab = _tabs[_selectedIndex];

    if (tab is SearchableWidget) {
      (tab as SearchableWidget).search(text);
    }
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
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight,
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: StateContainer.of(context).curTheme.lightColor,
              tabs: [
                Tab(text: S.of(context).loan_your_loans),
                Tab(text: S.of(context).loan_browse_loans),
                Tab(text: 'Auctions'),
              ],
            ),
              title: (_selectedIndex == 2 && _search) ? Container(
                width: double.infinity,
                height: 40,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
                child: Center(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                          },
                        ),
                        hintText: 'Search...',
                        border: InputBorder.none),
                  ),
                ),
              ) : Row(children: [
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
              if (_selectedIndex == 2) Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    onTap: () async {
                      setState(() {
                        _auctionFilterBuyable = !_auctionFilterBuyable;
                      });

                      (_tabs[_selectedIndex] as AuctionsScreen).toggleFilterBuyable(_auctionFilterBuyable);
                    },
                    child: Icon(_auctionFilterBuyable ? Icons.money_off_csred :  Icons.attach_money, size: 26.0, color: Theme.of(context).appBarTheme.actionsIconTheme.color),
                  )),
              if (_selectedIndex == 2) Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    onTap: () async {
                      setState(() {
                        _search = !_search;
                      });

                      _searchFocusNode.requestFocus();
                    },
                    child: Icon(Icons.filter_alt, size: 26.0, color: Theme.of(context).appBarTheme.actionsIconTheme.color),
                  )),
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
