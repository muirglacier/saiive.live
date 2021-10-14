import 'dart:async';

import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/ui/widgets/loading.dart';
import 'package:flutter/material.dart';

class LoadingOverlay {
  BuildContext _context;
  Stream<String> _loadingText;

  void hide() {
    Navigator.of(_context).pop();
  }

  void show() {
    showDialog(
        context: _context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Container(
              child: Material(
                  type: MaterialType.transparency,
                  child: LoadingWidget(
                    text: S.of(context).loading,
                    stream: _loadingText,
                  )));
        });
  }

  Future<T> during<T>(Future<T> future, {String text}) {
    show();
    return future.whenComplete(() => hide());
  }

  LoadingOverlay._create(this._context, this._loadingText);

  factory LoadingOverlay.of(BuildContext context, {Stream<String> loadingText}) {
    Stream<String> controller;
    if (loadingText == null) {
      // ignore: close_sinks
      var streamController = StreamController<String>();
      streamController.add(S.of(context).loading);
      controller = streamController.stream;
    } else {
      controller = loadingText;
    }
    var overlay = LoadingOverlay._create(context, controller);
    return overlay;
  }
}
