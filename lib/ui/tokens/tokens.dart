import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/network/model/token.dart';
import 'package:saiive.live/network/token_service.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/ui/utils/token_icon.dart';
import 'package:saiive.live/ui/widgets/loading.dart';
import 'package:flutter/material.dart';

class TokensScreen extends StatefulWidget {
  const TokensScreen({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _TokensScreen();
  }
}

class _TokensScreen extends State<TokensScreen> {
  List<Token> _tokens;

  @override
  void initState() {
    super.initState();

    _initTokens();
  }

  _initTokens() async {
    var tokens = await sl.get<ITokenService>().getTokens(DeFiConstants.DefiAccountSymbol);

    setState(() {
      _tokens = tokens;
    });
  }

  Widget _buildTokenEntry(Token token) {
    return Card(
        child: ListTile(
      leading: TokenIcon(token.symbol),
      title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text(token.name.isNotEmpty ? token.name : token.symbol, style: Theme.of(context).textTheme.headline3)]),
      trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text(token.symbol, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500))]),
    ));
  }

  buildTokenScreen(BuildContext context) {
    if (_tokens == null) {
      return LoadingWidget(text: S.of(context).loading);
    }

    return Padding(
        padding: EdgeInsets.all(10),
        child: Padding(
            padding: EdgeInsets.only(right: 10),
            child: ListView(children: [
              ListView.builder(
                  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: _tokens.length,
                  itemBuilder: (context, index) {
                    return _buildTokenEntry(_tokens.elementAt(index));
                  })
            ])));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight, title: Row(children: [Text(S.of(context).home_tokens)])),
        body: Scaffold(body: PrimaryScrollController(controller: new ScrollController(), child: buildTokenScreen(context))));
  }
}
