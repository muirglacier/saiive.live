import 'package:carousel_slider/carousel_slider.dart';
import 'package:saiive.live/appcenter/appcenter.dart';
import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/ui/intro/intro_legal.dart';
import 'package:saiive.live/ui/model/available_themes.dart';
import 'package:saiive.live/ui/widgets/buttons.dart';
import 'package:saiive.live/util/sharedprefsutil.dart';
import 'package:flutter/material.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:flutter_icons/flutter_icons.dart';

class IntroWelcomeScreen extends StatefulWidget {
  @override
  _IntroWelcomeScreenState createState() => _IntroWelcomeScreenState();
}

class _IntroWelcomeScreenState extends State<IntroWelcomeScreen> {
  ThemeSetting _curTheme;

  Future _init() async {
    final curTheme = await sl.get<ISharedPrefsUtil>().getTheme();

    setState(() {
      _curTheme = curTheme;
    });
  }

  Future setTheme(ThemeOptions themeOption) async {
    final theme = ThemeSetting(themeOption);
    sl.get<AppCenterWrapper>().trackEvent("settingsSetTheme", <String, String>{"theme": theme.getDisplayName(context)});

    await sl.get<ISharedPrefsUtil>().setTheme(theme);
    setState(() {
      StateContainer.of(context).updateTheme(theme);
      _curTheme = theme;
    });
  }

  @override
  void initState() {
    super.initState();

    _init();
  }

  List<Widget> getCarouselItems(BuildContext context) {
    return [
      Column(
        children: <Widget>[
          Text(
            S.of(context).welcome,
            style: TextStyle(fontSize: 20),
          ),
          Text(
            S.of(context).welcome_wallet_info,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15),
          ),
        ],
      ),
      Column(
        children: <Widget>[
          Text(
            S.of(context).welcome_wallet_secure,
            style: Theme.of(context).textTheme.bodyText1,
          ),
          Text(
            S.of(context).welcome_wallet_privacy,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyText2,
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
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.start, verticalDirection: VerticalDirection.down, children: <Widget>[
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
              width: width * 0.9,
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
          ),
        ]),
        SizedBox(height: 10),
        Container(
            child: AppButton.buildAppButton(context, AppButtonType.PRIMARY, S.of(context).welcome_wallet_create,
                onPressed: () => {Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => IntroLegalScreen("/intro_wallet_new")))},
                icon: Icons.account_balance_wallet,
                key: const Key("wallet_new"))),
        SizedBox(height: 10),
        Container(
            child: AppButton.buildAppButton(context, AppButtonType.SECONDARY, S.of(context).welcome_wallet_restore,
                onPressed: () => {Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => IntroLegalScreen("/intro_wallet_restore")))},
                icon: Icons.list,
                key: const Key("wallet_restore"))),
        SizedBox(height: 10),
        if (_curTheme?.theme == ThemeOptions.DEFI_DARK)
          Container(
              child: AppButton.buildAppButton(context, AppButtonType.SECONDARY, S.of(context).light_mode,
                  onPressed: () => {setTheme(ThemeOptions.DEFI_LIGHT)}, icon: FontAwesome5.sun, key: const Key("theme_light"))),
        if (_curTheme?.theme == ThemeOptions.DEFI_LIGHT)
          Container(
              child: AppButton.buildAppButton(context, AppButtonType.SECONDARY, S.of(context).dark_mode,
                  onPressed: () => {setTheme(ThemeOptions.DEFI_DARK)}, icon: FontAwesome5.moon, key: const Key("theme_dakr"))),
      ]),
    );
  }
}
