import 'dart:async';

import 'package:defichainwallet/service_locator.dart';
import 'package:defichainwallet/ui/model/available_themes.dart';
import 'package:defichainwallet/util/sharedprefsutil.dart';
import 'package:flutter/material.dart';

class LoadingWidget extends StatefulWidget {
  final String text;
  final Stream<String> stream;

  LoadingWidget({@required this.text, this.stream});

  @override
  State<StatefulWidget> createState() {
    return _LoadingWidget();
  }
}

class _LoadingWidget extends State<LoadingWidget> {
  String _text;
  StreamSubscription<String> _textSub;

  int _theme;

  void initAsync() async {
    _text = widget.text;

    var theme = await sl.get<SharedPrefsUtil>().getTheme();

    setState(() {
      _theme = theme.getIndex();
    });

    if (widget.stream != null) {
      _textSub = widget.stream.listen((event) {
        setState(() {
          _text = event;
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();
    initAsync();
  }

  @override
  void dispose() {
    super.dispose();

    if (_textSub != null) {
      _textSub.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    var backgroundColor = Colors.transparent;

    if (_theme == ThemeOptions.DEFI_LIGHT.index) {
      backgroundColor = Colors.white60;
    }

    return Container(
        color: backgroundColor,
        child: Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
          SizedBox(height: 100, width: 100, child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor))),
          SizedBox(height: 20),
          Text(this._text)
        ])));
  }
}
