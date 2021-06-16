import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/ui/widgets/loading.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  final String url;
  final String name;

  final bool canOpenInBrowser;

  WebViewScreen(this.url, this.name, {this.canOpenInBrowser = false});

  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  bool _pageIsLoading = true;

  @override
  void initState() {
    super.initState();
    // Enable hybrid composition.
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight,
          title: Text(widget.name),
          actions: [
            if (this.widget.canOpenInBrowser)
              Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    onTap: () async {
                      await launch(this.widget.url);
                    },
                    child: Icon(Icons.open_in_browser, size: 26.0, color: Theme.of(context).appBarTheme.actionsIconTheme.color),
                  )),
          ],
        ),
        body: Stack(children: [
          if (_pageIsLoading) LoadingWidget(text: S.of(context).loading),
          WebView(
            initialUrl: widget.url,
            javascriptMode: JavascriptMode.unrestricted,
            onPageStarted: (url) {
              setState(() {
                _pageIsLoading = true;
              });
            },
            onPageFinished: (url) {
              setState(() {
                _pageIsLoading = false;
              });
            },
          )
        ]));
  }
}
