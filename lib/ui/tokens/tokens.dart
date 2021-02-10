import 'package:defichainwallet/generated/l10n.dart';
import 'package:defichainwallet/network/model/token.dart';
import 'package:defichainwallet/network/token_service.dart';
import 'package:defichainwallet/service_locator.dart';
import 'package:defichainwallet/ui/utils/token_icon.dart';
import 'package:defichainwallet/ui/widgets/loading.dart';
import 'package:flutter/material.dart';

class TokensScreen extends StatefulWidget {
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
    var tokens = await sl.get<ITokenService>().getTokens('DFI');

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
          children: [
            Text(token.name,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500))
          ]),
      trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(token.symbol,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500))
          ]),
    ));
  }

  buildTokenScreen(BuildContext context) {
    if (_tokens == null) {
      return LoadingWidget(text: S.of(context).loading);
    }

    return Padding(
        padding: EdgeInsets.all(30),
        child: ListView(children: [
          Center(
              child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: _tokens.length,
                  itemBuilder: (context, index) {
                    return _buildTokenEntry(_tokens.elementAt(index));
                  }))
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(S.of(context).home_tokens)),
        body: Scaffold(body: buildTokenScreen(context)));
  }
}
