import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TestRunInfoScreen extends StatefulWidget {
  TestRunInfoScreen();

  @override
  State<StatefulWidget> createState() {
    return _TestRunInfoScreen();
  }
}

class _TestRunInfoScreen extends State<TestRunInfoScreen> {
  _TestRunInfoScreen();

  @override
  void initState() {
    super.initState();
  }

  _buildHelpPage(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(30),
        child: CustomScrollView(slivers: [
          SliverFillRemaining(
              hasScrollBody: false,
              child: Column(children: [
                Container(
                    child: Column(
                  children: [
                    Text(S.of(context).test_info_test),
                    Text(S.of(context).test_info_funds),
                    SizedBox(height: 10),
                    Container(
                        child: new InkWell(
                            child: new Text(
                              'TESTNET FUNDS',
                              style: TextStyle(color: StateContainer.of(context).curTheme.primary),
                            ),
                            onTap: () => launch('https://forms.office.com/r/Wh0xtr8DhJ'))),
                    SizedBox(height: 40),
                    Text(S.of(context).test_info_telegram),
                    SizedBox(height: 10),
                    Container(
                        child: new InkWell(
                            child: new Text(
                              'TELEGRAM GROUP',
                              style: TextStyle(color: StateContainer.of(context).curTheme.primary),
                            ),
                            onTap: () => launch('https://t.me/SmartDefiWallet'))),
                    SizedBox(height: 40),
                    Text(S.of(context).test_info_feedback),
                    SizedBox(height: 10),
                    Container(
                        child: new InkWell(
                            child: new Text(
                              'GITHUB',
                              style: TextStyle(color: StateContainer.of(context).curTheme.primary),
                            ),
                            onTap: () => launch('https://github.com/saiive/saiive.live/issues/new/choose'))),
                    SizedBox(height: 40),
                    Text(S.of(context).test_info_epilogue),
                    SizedBox(height: 40),
                    Text(S.of(context).test_info, style: TextStyle(fontWeight: FontWeight.bold))
                  ],
                )),
              ]))
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight,
          title: Text(S.of(context).test_info),
        ),
        body: _buildHelpPage(context));
  }
}
