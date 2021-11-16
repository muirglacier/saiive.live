import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/crypto/addressbook/address_book_db.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/model/address_book_model.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/ui/accounts/accounts_select_action_screen.dart';
import 'package:saiive.live/ui/addressbook/addressbook_entry_edit_screen.dart';
import 'package:saiive.live/ui/utils/token_icon.dart';
import 'package:saiive.live/ui/widgets/loading.dart';

class AddressBookScreen extends StatefulWidget {
  final bool selectOnlyMode;
  final void Function(AddressBookEntry) onAddressSelected;
  final ChainType chainFilter;
  // ignore: avoid_init_to_null
  AddressBookScreen({this.selectOnlyMode = false, this.onAddressSelected = null, this.chainFilter = null, Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AddressBookScreen();
}

class _AddressBookScreen extends State<AddressBookScreen> {
  bool _isLoading = false;
  IAddressBookDatabase _addressBookDatabase;
  List<AddressBookEntry> _addresses;

  Future _init() async {
    _addressBookDatabase = sl.get<IAddressBookDatabase>();
    var addresses = await _addressBookDatabase.getAddressBook();

    if (widget.chainFilter != null) {
      addresses = addresses.where((element) => element.chain == widget.chainFilter).toList();
    }

    setState(() {
      _isLoading = false;
      _addresses = addresses;
    });
  }

  @override
  void initState() {
    _isLoading = true;
    super.initState();

    _init();
  }

  Widget _buildAdressEntry(BuildContext context, AddressBookEntry address) {
    return Card(
        child: ListTile(
      leading: TokenIcon(ChainHelper.chainTypeString(address.chain)),
      title: AutoSizeText(address.name, maxLines: 1),
      onTap: () async {
        if (widget.selectOnlyMode) {
          widget.onAddressSelected(address);
          Navigator.pop(context);
        } else {
          await Navigator.of(context).push(MaterialPageRoute(
              settings: RouteSettings(name: "/accountsAddScreen"),
              builder: (BuildContext context) => AddressBookEntryEditScreen(address.chain, address, false, _addressBookDatabase)));

          await _init();
        }
      },
      subtitle: AutoSizeText(address.publicKey, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
    ));
  }

  _buildAddressBookScreen(BuildContext context) {
    if (_isLoading) {
      return LoadingWidget(text: S.of(context).loading);
    }

    return Padding(
        padding: EdgeInsets.all(10),
        child: Scrollbar(
            child: Padding(
                padding: EdgeInsets.only(right: 10),
                child: ListView(children: [
                  ListView.builder(
                      physics: BouncingScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: _addresses.length,
                      itemBuilder: (context, index) {
                        final wa = _addresses.elementAt(index);

                        return _buildAdressEntry(context, wa);
                      })
                ]))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight,
          title: Text(S.of(context).addressbook),
          actions: [
            if (!widget.selectOnlyMode)
              Padding(
                  padding: EdgeInsets.only(right: 15.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => AccountsSelectActionScreen((chainType) async {
                                await Navigator.of(context).push(MaterialPageRoute(
                                    settings: RouteSettings(name: "/accountsAddScreen"),
                                    builder: (BuildContext context) => AddressBookEntryEditScreen(chainType, null, true, _addressBookDatabase)));
                                await _init();
                              }, defichainOnly: false)));
                    },
                    child: Icon(Icons.add, size: 30.0, color: Theme.of(context).appBarTheme.actionsIconTheme.color),
                  )),
            // if (!_isLoading)
            //   Padding(
            //       padding: EdgeInsets.only(right: 15.0),
            //       child: GestureDetector(
            //         onTap: () async {},
            //         child: Icon(Icons.upload, size: 30.0, color: Theme.of(context).appBarTheme.actionsIconTheme.color),
            //       )),
          ],
        ),
        body: _buildAddressBookScreen(context));
  }
}
