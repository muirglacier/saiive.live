import 'dart:async';

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

  @override
  void initState() {
    super.initState();

    _text = widget.text;

    if (widget.stream != null) {
      _textSub = widget.stream.listen((event) {
        setState(() {
          _text = event;
        });
      });
    }
  }

  @override
  void dispose() {
    super.dispose();

    _textSub.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
      SizedBox(height: 100, width: 100, child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor))),
      SizedBox(height: 20),
      Text(this._text)
    ]));
  }
}
