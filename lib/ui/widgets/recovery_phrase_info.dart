import 'package:carousel_slider/carousel_slider.dart';
import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../wallet/recovery_phrase_display.dart';

class RecoveryPhraseInfoWidget extends StatefulWidget {
  final String mnemonic;

  RecoveryPhraseInfoWidget({this.mnemonic});

  @override
  State<StatefulWidget> createState() {
    return _RecoveryPhraseInfoWidget();
  }
}

class _RecoveryPhraseInfoWidget extends State<RecoveryPhraseInfoWidget> {
  int _current = 0;

  Widget buildInfoWidget(BuildContext context, String image, String header, String text) {
    return Column(
      children: <Widget>[
        Text(
          header,
          style: TextStyle(fontSize: 20, color: StateContainer.of(context).curTheme.text),
        ),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(color: Theme.of(context).hintColor),
        ),
      ],
    );
  }

  List<Widget> getCarouselItems(BuildContext context) {
    return [
      buildInfoWidget(context, "", S.of(context).wallet_new_info1_header, S.of(context).wallet_new_info1_text),
      buildInfoWidget(context, "", S.of(context).wallet_new_info2_header, S.of(context).wallet_new_info2_text),
      buildInfoWidget(
        context,
        "",
        S.of(context).wallet_new_info3_header,
        S.of(context).wallet_new_info3_text,
      ),
      Column(children: <Widget>[buildInfoWidget(context, "", S.of(context).wallet_new_info4_header, S.of(context).wallet_new_info4_text)])
    ];
  }

  @override
  Widget build(BuildContext context) {
    final carouselItems = getCarouselItems(context);
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Center(
          child: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          SizedBox(
              width: width * 0.9,
              height: height / 2 - 100,
              child: CarouselSlider(
                items: carouselItems,
                options: CarouselOptions(
                    enableInfiniteScroll: false,
                    viewportFraction: 1.0,
                    enlargeCenterPage: false,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _current = index;
                      });
                    }),
              )),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: carouselItems.map((url) {
              int index = carouselItems.indexOf(url);
              return Container(
                width: 8.0,
                height: 8.0,
                margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _current == index ? StateContainer.of(context).curTheme.primary : StateContainer.of(context).curTheme.lightColor,
                ),
              );
            }).toList(),
          )
        ]),
        // if (_current == carouselItems.length - 1)
        Container(
            child: SizedBox(
                width: 300,
                child: ElevatedButton(
                  child: Text(S.of(context).wallet_new_reveal),
                  style: ElevatedButton.styleFrom(primary: StateContainer.of(context).curTheme.primary),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => RecoveryPhraseDisplayScreen(widget.mnemonic)));
                  },
                ))),
        if (_current != 4) Container(child: SizedBox(width: 300, height: 40))
      ])),
    );
  }
}
