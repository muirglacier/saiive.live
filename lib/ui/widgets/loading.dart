import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final String text;

  LoadingWidget({@required this.text});
  
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
          SizedBox(height: 100, width: 100, child: CircularProgressIndicator()),
          SizedBox(height: 20),
          Text(this.text)
        ]));
  }
}
