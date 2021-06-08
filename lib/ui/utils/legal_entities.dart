import 'dart:io';

import 'package:saiive.live/ui/utils/card-link.widget.dart';
import 'package:saiive.live/ui/utils/webview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:url_launcher/url_launcher.dart';

class LegalEntitiesWidget extends StatefulWidget {
  final EdgeInsets padding;
  LegalEntitiesWidget(this.padding);

  @override
  _LegalEntitiesWidgetState createState() => _LegalEntitiesWidgetState();
}

class _LegalEntitiesWidgetState extends State<LegalEntitiesWidget> {
  bool accepted = false;

  @override
  void initState() {
    super.initState();
  }

  Widget createLegalItem(String name, String uri, BuildContext context) {
    return CardLinkItemWidget(name, uri);
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisAlignment: MainAxisAlignment.start, verticalDirection: VerticalDirection.down, children: <Widget>[
      Container(padding: widget.padding, child: createLegalItem(S.of(context).welcome_legal_tos, S.of(context).welcome_legal_tos_link, context)),
      Container(padding: widget.padding, child: createLegalItem(S.of(context).welcome_legal_privacy, S.of(context).welcome_legal_privacy_link, context)),
    ]);
  }
}
