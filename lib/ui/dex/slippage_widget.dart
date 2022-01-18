import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saiive.live/generated/l10n.dart';

class SlippageWidget extends StatefulWidget {
  final void Function(double) onValueChange;
  final double initialValue;
  final String title;
  const SlippageWidget({this.onValueChange, this.initialValue, this.title});

  @override
  State<StatefulWidget> createState() => _SlippageWidgetState();
}

class _SlippageWidgetState extends State<SlippageWidget> {
  double _value;
  double _percentage = 0;
  bool _isCustom = false;
  TextEditingController _percentageTextController = TextEditingController();

  @override
  void initState() {
    _value = widget.initialValue;
    _percentage = widget.initialValue * 100;
    _percentageTextController.text = _percentage.toString();
    _percentageTextController.addListener(handleChangePercentage);

    super.initState();
  }

  handleChangePercentage() {
    double amount = double.tryParse(_percentageTextController.text.replaceAll(',','.'));

    if (amount == null) {
      return;
    }

    setState(() {
      _percentage = amount;
      widget.onValueChange(_percentage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: EdgeInsets.zero,
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Radio<double>(
                      value: .01,
                      groupValue: _value,
                      onChanged: (double value) {
                        setState(() {
                          _value = value;
                          _isCustom = false;
                          widget.onValueChange(value);
                        });
                      },
                    ),
                    Text('1%')
                  ],
                ),
                flex: 1,
              ),
              Expanded(
                child: Row(
                  children: [
                    Radio<double>(
                      value: .03,
                      groupValue: _value,
                      onChanged: (double value) {
                        setState(() {
                          _value = value;
                          _isCustom = false;
                          widget.onValueChange(value);
                        });
                      },
                    ),
                    Text('3%')
                  ],
                ),
                flex: 1,
              ),
              Expanded(
                child: Row(
                  children: [
                    Radio<double>(
                      value: .05,
                      groupValue: _value,
                      onChanged: (double value) {
                        setState(() {
                          _value = value;
                          _isCustom = false;
                          widget.onValueChange(value);
                        });
                      },
                    ),
                    Text('5%')
                  ],
                ),
                flex: 1,
              ),
              Expanded(
                child: Row(
                  children: [
                    Radio<double>(
                      value: -1,
                      groupValue: _value,
                      onChanged: (double value) {
                        setState(() {
                          _value = value;
                          _isCustom = true;
                        });

                        widget.onValueChange(value);
                      },
                    ),
                    Text('Custom')
                  ],
                ),
                flex: 2,
              ),
            ],
          ),
          if (_isCustom) buildCustom(context),
        ]));
  }

  Widget buildCustom(BuildContext context) {
    return Padding(padding: EdgeInsets.all(5), child: Row(children: [
      Expanded(flex: 1, child: TextField(
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            maxLength: 10,
            textAlign: TextAlign.right,
            decoration: InputDecoration(labelText: '', counterText: '', suffix: Text('%')),
            controller: _percentageTextController)),
    ]));
  }
}
