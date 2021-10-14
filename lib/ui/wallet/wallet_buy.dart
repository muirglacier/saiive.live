import 'package:flutter/material.dart';
import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/ui/widgets/dfx_buy_widget.dart';

class DfxBuyScreen extends StatefulWidget {
  DfxBuyScreen();

  @override
  State<StatefulWidget> createState() {
    return _DfxBuyScreen();
  }
}

class _DfxBuyScreen extends State<DfxBuyScreen> {
  Widget buildBuyPage(BuildContext context) {
    return Padding(padding: EdgeInsets.all(20), child: DfxBuyWidget());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight,
          title: Text(S.of(context).dfx_buy_title),
          actions: [],
        ),
        body: SingleChildScrollView(child: buildBuyPage(context)));
  }
}
