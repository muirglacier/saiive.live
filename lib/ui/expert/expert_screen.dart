import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ExpertScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ExpertScreen();
}

class _ExpertScreen extends State<ExpertScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("Expert mode")));
  }
}
