import 'package:flutter/material.dart';
import 'package:saiive.live/generated/l10n.dart';

class SlippageWidget extends StatefulWidget {
  final void Function(double) onValueChange;
  final double initialValue;
  final String title;
  final bool isExpanded;
  const SlippageWidget({this.onValueChange, this.initialValue, this.title, this.isExpanded = false});

  @override
  State<StatefulWidget> createState() => _SlippageWidgetState();
}

class _SlippageWidgetState extends State<SlippageWidget> {
  var _isExpanded = false;
  double _value;

  @override
  void initState() {
    _value = widget.initialValue;
    _isExpanded = widget.isExpanded;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionPanelList(
        expandedHeaderPadding: EdgeInsets.all(5),
        expansionCallback: (int index, bool isExpanded) {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        children: [
          ExpansionPanel(
              isExpanded: _isExpanded,
              headerBuilder: (context, isOpen) {
                return GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        widget.title ?? S.of(context).expert,
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ));
              },
              body: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(children: <Widget>[
                    Column(children: <Widget>[
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Radio<double>(
                                      value: .02,
                                      groupValue: _value,
                                      onChanged: (double value) {
                                        setState(() {
                                          _value = value;
                                          widget.onValueChange(value);
                                        });
                                      },
                                    ),
                                    Expanded(
                                      child: Text('2%'),
                                    )
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
                                          widget.onValueChange(value);
                                        });
                                      },
                                    ),
                                    Expanded(child: Text('3%'))
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
                                          widget.onValueChange(value);
                                        });
                                      },
                                    ),
                                    Expanded(child: Text('5%'))
                                  ],
                                ),
                                flex: 1,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Row(
                                  children: [
                                    Radio<double>(
                                      value: .10,
                                      groupValue: _value,
                                      onChanged: (double value) {
                                        setState(() {
                                          _value = value;
                                          widget.onValueChange(value);
                                        });
                                      },
                                    ),
                                    Expanded(child: Text('10%'))
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Row(
                                  children: [
                                    Radio<double>(
                                      value: .15,
                                      groupValue: _value,
                                      onChanged: (double value) {
                                        setState(() {
                                          _value = value;
                                          widget.onValueChange(value);
                                        });
                                      },
                                    ),
                                    Expanded(child: Text('15%'))
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Row(
                                  children: [
                                    Radio<double>(
                                      value: .20,
                                      groupValue: _value,
                                      onChanged: (double value) {
                                        setState(() {
                                          _value = value;
                                          widget.onValueChange(value);
                                        });
                                      },
                                    ),
                                    Expanded(
                                      child: Text('20%'),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(width: 20),
                    ])
                  ])))
        ]);
  }
}
