import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:saiive.live/network/model/loan_vault.dart';
import 'package:saiive.live/ui/widgets/auto_resize_text.dart';

enum Alert { info, error }

extension ParseToStringLoanVaultHealthStatus on Alert {
  Color toColor() {
    switch (this) {
      case Alert.info:
        {
          return Colors.lightBlueAccent;
        }

      case Alert.error:
        {
          return Colors.redAccent;
        }
    }

    return Colors.black;
  }
}

class AlertWidget extends StatefulWidget {
  final String text;
  final Alert alert;

  AlertWidget(this.text, {this.alert = Alert.info});

  @override
  State<StatefulWidget> createState() => _AlertWidget();
}

class _AlertWidget extends State<AlertWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
          width: 20,
          height: 20,
          decoration: ShapeDecoration(
            shape: StadiumBorder(),
            color: widget.alert.toColor(),
          )),
      Container(width: 5),
      Expanded(child: Text(widget.text, maxLines: 10,))
    ]);
  }
}
