import 'dart:io';

import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/ui/lock/unlock_handler.dart';
import 'package:saiive.live/ui/utils/legal_entities.dart';
import 'package:saiive.live/ui/utils/webview.dart';
import 'package:saiive.live/ui/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:url_launcher/url_launcher.dart';

class IntroLegalScreen extends StatefulWidget {
  final String forwardUrl;
  IntroLegalScreen(this.forwardUrl);

  @override
  _IntroLegalState createState() => _IntroLegalState();
}

class _IntroLegalState extends State<IntroLegalScreen> {
  bool accepted = false;

  @override
  void initState() {
    super.initState();
  }

  Widget createLegalItem(String name, String uri, BuildContext context) {
    return GestureDetector(
        onTap: () async {
          if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
            if (await canLaunch(uri)) {
              await launch(uri);
            }
          } else {
            Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => WebViewScreen(uri, name)));
          }
        },
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              ListTile(
                trailing: Icon(Icons.arrow_right),
                title: Text(name),
              ),
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final marginRight = 20.0;
    final marginLeft = 20.0;
    return Scaffold(
      appBar: AppBar(toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight, title: Text(S.of(context).welcome_legal)),
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisAlignment: MainAxisAlignment.start, verticalDirection: VerticalDirection.down, children: <Widget>[
        SizedBox(height: 20),
        Container(padding: EdgeInsets.only(left: marginLeft, right: marginRight), child: Text(S.of(context).welcome_legal_text)),
        SizedBox(height: 20),
        LegalEntitiesWidget(EdgeInsets.only(left: marginLeft, right: marginRight)),
        Container(
          padding: EdgeInsets.only(left: marginLeft, right: marginRight),
          child: CheckboxListTile(
            title: Text(S.of(context).welcome_accept_terms_and_privacy),
            value: accepted,
            onChanged: (bool value) {
              setState(() {
                accepted = value;
              });
            },
          ),
        ),
        SizedBox(height: 100),
        Container(
            padding: EdgeInsets.only(left: marginLeft, right: marginRight),
            child: AppButton.buildAppButton(context, AppButtonType.PRIMARY, S.of(context).next, enabled: accepted, onPressed: () async {
              if (accepted) {
                await sl.get<IUnlockHandler>().setNewPassword(context, canCancel: false);
                Navigator.of(context).pushNamed(widget.forwardUrl);
              }
            }, icon: Icons.check)),
        SizedBox(height: 10)
      ]),
    );
  }
}
