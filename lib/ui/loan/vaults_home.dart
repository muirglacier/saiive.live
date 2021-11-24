import 'package:saiive.live/generated/l10n.dart';
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

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);

    _tabController.addListener(() {
      _selectedIndex = _tabController.index;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  text: S.of(context).loan_browse_loans
                ),
                Tab(text: S.of(context).loan_your_loans),
              ],
            ),
            title: Text(S.of(context).loan_vaults),
            actions: [
              Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    onTap: () async {
                      Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => VaultCreateScreen()));
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
