import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomTableWidget extends StatefulWidget {
  List<List<String>> items;

  CustomTableWidget(this.items);

  @override
  State<StatefulWidget> createState() => _CustomTableWidget();
}

class _CustomTableWidget extends State<CustomTableWidget> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        itemCount: widget.items.length,
        itemBuilder: (BuildContext context, int index) {
          final item = widget.items[index];

          return
            Card(
              child: ListTile(
                  title: Text(item.elementAt(0)),
                  subtitle: Text(item.elementAt(1))
              ),
            );
        });
  }
}
