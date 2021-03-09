import 'package:flutter/material.dart';
import 'package:defichainwallet/util/chunks.dart';

class Responsive {
  // Primary button builder
  static Widget buildResponsive<E>(BuildContext context, List<E> elements, int breakpoint, Widget builder(E el))
  {
    List<Widget> widgets = [];
    MediaQueryData queryData = MediaQuery.of(context);
    var cols = (queryData.size.width / breakpoint).round();
    var chunked = elements.chunked(cols);

    chunked.toList().asMap().forEach((index, e) {
      List<Widget> children = [];

      e.forEach((element) {
        children.add(Expanded(child: builder(element), flex: 1));
      });

      if (chunked.length > 1 && index == chunked.length - 1 && index < chunked.first.length) {
        for (var i = children.length; i<chunked.first.length; i++) {
          children.add(Expanded(flex: 1, child: Container()));
        }
      }

      widgets.add(Row(crossAxisAlignment: CrossAxisAlignment.start, children: children));
    });

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: widgets);
  }
}
