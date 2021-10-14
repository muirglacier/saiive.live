import 'dart:io';
import 'package:flutter/material.dart';
import 'package:saiive.live/ui/utils/webview.dart';
import 'package:url_launcher/url_launcher.dart';

class CardItemWidget extends StatelessWidget {
  final String name;
  final VoidCallback onPressed;

  final Color backgroundColor;
  final EdgeInsetsGeometry padding;

  CardItemWidget(this.name, this.onPressed, {this.backgroundColor, this.padding = EdgeInsets.zero});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          if (this.onPressed != null) {
            this.onPressed();
          }
        },
        child: Padding(
            padding: this.padding,
            child: Card(
              clipBehavior: Clip.antiAlias,
              color: this.backgroundColor,
              child: Column(
                children: [
                  ListTile(
                    trailing: this.onPressed != null ? Icon(Icons.arrow_right) : null,
                    title: Text(name),
                  ),
                ],
              ),
            )));
  }
}

class CardLinkItemWidget extends StatelessWidget {
  final String name;
  final String uri;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;
  final bool openInBrowser;
  final bool canOpenInBrowser;

  CardLinkItemWidget(this.name, this.uri, {this.backgroundColor, this.padding = EdgeInsets.zero, this.openInBrowser = false, this.canOpenInBrowser = false});

  @override
  Widget build(BuildContext context) {
    return CardItemWidget(name, () async {
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        if (await canLaunch(uri)) {
          await launch(uri);
        }
      } else {
        if (this.openInBrowser) {
          await launch(uri);
        } else {
          Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => WebViewScreen(uri, name, canOpenInBrowser: this.canOpenInBrowser)));
        }
      }
    }, padding: this.padding, backgroundColor: this.backgroundColor);
  }
}
