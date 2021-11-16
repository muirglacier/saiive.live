import 'package:saiive.live/generated/l10n.dart';
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

class _VaultsHomeScreen extends State<VaultsHomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
              bottom: const TabBar(
                tabs: [
                  Tab(
                    text: 'Browse Loans',
                  ),
                  Tab(text: 'Your Loans'),
                ],
              ),
              title: Text(S.of(context).loan_vaults)),
          body: const TabBarView(
            children: [VaultTokensScreen(), VaultsScreen()],
          ),
        ));
  }
}
