import 'package:flutter/material.dart';

abstract class RefreshableWidget extends StatefulWidget {
  const RefreshableWidget({Key key}) : super(key: key);

  void refresh();
}
