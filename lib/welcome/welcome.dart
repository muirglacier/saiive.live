import 'package:defichainwallet/generated/l10n.dart';
import 'package:defichainwallet/wallet/init/wallet_init.dart';
import 'package:defichainwallet/wallet/init/wallet_restore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class WelcomeScreen extends StatefulWidget {
  WelcomeScreen();

  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  List<Widget> getCarouselItems(BuildContext context) {
    return [
      Column(
        children: <Widget>[
          Text(
            S.of(context).welcome,
            style: TextStyle(fontFamily: "Popins", fontSize: 20),
          ),
          Text(
            S.of(context).welcome_wallet_info,
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: "Popins", fontSize: 15),
          ),
        ],
      ),
      Column(
        children: <Widget>[
          Text(
            S.of(context).welcome_wallet_secure,
            style: TextStyle(fontFamily: "Popins", fontSize: 20),
          ),
          Text(
            S.of(context).welcome_wallet_privacy,
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: "Popins", fontSize: 15),
          ),
        ],
      )
    ];
  }

  int _current = 0;

  @override
  Widget build(BuildContext context) {
    final carouselItems = getCarouselItems(context);
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          verticalDirection: VerticalDirection.down,
          children: <Widget>[
            Container(
                margin: const EdgeInsets.only(top: 100),
                child: SizedBox(
                    height: height / 4,
                    child: Image.asset(
                      "assets/logo.png",
                      fit: BoxFit.fill,
                    ))),
            SizedBox(height: 50),
            Column(children: <Widget>[
              Container(
                  height: height / 5,
                  width: double.infinity,
                  child: CarouselSlider(
                    items: carouselItems,
                    options: CarouselOptions(
                        enableInfiniteScroll: false,
                        enlargeCenterPage: true,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _current = index;
                          });
                        }),
                  )),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: carouselItems.map((url) {
                  int index = carouselItems.indexOf(url);
                  return Container(
                    width: 8.0,
                    height: 8.0,
                    margin:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _current == index
                          ? Color.fromRGBO(0, 0, 0, 0.9)
                          : Color.fromRGBO(0, 0, 0, 0.4),
                    ),
                  );
                }).toList(),
              ),
            ]),
            SizedBox(height: 10),
            Container(
                child: SizedBox(
                    width: 300,
                    child: RaisedButton(
                      child: Text(
                        S.of(context).welcome_wallet_create,
                      ),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                WalletInitScreen()));
                      },
                    ))),
            SizedBox(height: 10),
            Container(
                child: SizedBox(
                    width: 300,
                    child: RaisedButton(
                      color: Theme.of(context).backgroundColor,
                      child: Text(
                        S.of(context).welcome_wallet_restore,
                      ),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                WalletRestoreScreen()));
                      },
                    ))),
          ]),
    );
  }
}
