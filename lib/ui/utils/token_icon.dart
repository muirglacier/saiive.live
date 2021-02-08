import 'dart:math';

import 'package:defichainwallet/appstate_container.dart';
import 'package:defichainwallet/generated/l10n.dart';
import 'package:defichainwallet/ui/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TokenIcon extends StatefulWidget {
  String _token;

  TokenIcon(this._token);

  @override
  _TokenIconState createState() => new _TokenIconState(this._token);
}

class _TokenIconState extends State<TokenIcon> {
  String _token;
  String _path;
  bool _iconTryLoad = false;
  static Map<String, Color> _colorList = new Map<String, Color>();

  _TokenIconState(this._token);

  @override
  void initState() {
    super.initState();

    _init();
  }

  _init() async {
    var path = 'assets/svg/' + _token.toLowerCase() + '-icon.svg';

    try {
      await rootBundle.load(path);

      setState(() {
        _path = path;
        _iconTryLoad = true;
      });
    } catch (_) {
      setState(() {
        _path = null;
        _iconTryLoad = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (false == _iconTryLoad) {
      return SizedBox(width: 32, height: 32);
    }

    if (null == _path) {
      if (!_colorList.containsKey(_token)) {
        _colorList[_token] =
            Colors.primaries[Random().nextInt(Colors.primaries.length)];
      }

      return SizedBox(
          width: 32,
          height: 32,
          child: CircleAvatar(
              backgroundColor: _colorList[_token],
              radius: 16,
              child: Text(this._token.substring(0, 1).toUpperCase(),
                  style: TextStyle(fontSize: 18, color: Colors.black))));
    }

    return SizedBox(
        width: 32,
        height: 32,
        child: SvgPicture.asset(
          _path,
          height: 32,
        ));
  }
}
