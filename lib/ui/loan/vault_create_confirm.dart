import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/network/model/loan_schema.dart';
import 'package:flutter/material.dart';
import 'package:saiive.live/ui/utils/fund_formatter.dart';

class VaultCreateConfirmScreen extends StatefulWidget {
  final LoanSchema schema;

  VaultCreateConfirmScreen(this.schema);

  @override
  State<StatefulWidget> createState() {
    return _VaultCreateConfirmScreen();
  }
}

class _VaultCreateConfirmScreen extends State<VaultCreateConfirmScreen> {
  @override
  void initState() {
    super.initState();
  }

  _buildView() {
    List<List<String>> items = [
      ['Transaction Type', 'Create vault'],
      ['Vault fee', FundFormatter.format(2)],
      ['Estimated Fee', FundFormatter.format(0.0002)],
      ['Total transaction cost', FundFormatter.format(2.0002)],
    ];

    List<List<String>> itemsSchema = [
      ['Min. collateral ratio', widget.schema.minColRatio],
      ['Interest rate (APR)', widget.schema.interestRate],
    ];

    return CustomScrollView(slivers: [
      SliverToBoxAdapter(
          child: Card(
              child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('You are creating a vault',
                            style: Theme.of(context).textTheme.headline6),
                        Row(children: <Widget>[
                          Container(
                              decoration:
                                  BoxDecoration(color: Colors.transparent),
                              child: Icon(Icons.shield, size: 40)),
                          Container(width: 10),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(
                                  'ID will be generated once the vault has been created',
                                  overflow: TextOverflow.fade,
                                  style: Theme.of(context).textTheme.caption,
                                )
                              ]))
                        ])
                      ])))),
      SliverToBoxAdapter(
          child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text('Transaction Details',
                  style: Theme.of(context).textTheme.caption))),
      SliverList(
          delegate: SliverChildListDelegate([
        SingleChildScrollView(
          child: Column(
            children: [
              Container(
                child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (BuildContext context, int index) {
                      final item = items[index];

                      return Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                        child: Card(
                            child: ListTile(
                          title: Text(item.elementAt(0)),
                          subtitle: Text(item.elementAt(1)),
                        )),
                      );
                    }),
              ),
            ],
          ),
        )
      ])),
      SliverToBoxAdapter(
          child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text('Vault Details',
                  style: Theme.of(context).textTheme.caption))),
      SliverList(
          delegate: SliverChildListDelegate([
        SingleChildScrollView(
          child: Column(
            children: [
              Container(
                child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: itemsSchema.length,
                    itemBuilder: (BuildContext context, int index) {
                      final item = itemsSchema[index];

                      return Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                        child: Card(
                            child: ListTile(
                          title: Text(item.elementAt(0)),
                          subtitle: Text(item.elementAt(1)),
                        )),
                      );
                    }),
              ),
            ],
          ),
        )
      ])),
      SliverToBoxAdapter(
          child: Padding(
              padding: EdgeInsets.only(left: 30, right: 30),
              child: Column(children: [
                SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        child: Text('Continue'),
                        onPressed: () {
                          //TODO: Do Transaction here
                        })),
                SizedBox(
                    width: double.infinity,
                    child: TextButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        }))
              ])))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight,
            title: Text('Confirm Create Vault')),
        body: _buildView());
  }
}
