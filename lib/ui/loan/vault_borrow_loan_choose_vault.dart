import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/network/model/loan_vault.dart';
import 'package:flutter/material.dart';

class VaultBorrowLoanChooseVaultScreen extends StatefulWidget {
  final List<LoanVault> vaults;
  final Function(LoanVault vault) onVaultSelected;
  final key = GlobalKey();

  VaultBorrowLoanChooseVaultScreen(this.vaults, this.onVaultSelected);

  @override
  State<StatefulWidget> createState() {
    return _VaultBorrowLoanChooseVaultScreen();
  }
}

class _VaultBorrowLoanChooseVaultScreen extends State<VaultBorrowLoanChooseVaultScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(20),
        child: CustomScrollView(physics: BouncingScrollPhysics(), scrollDirection: Axis.vertical, slivers: <Widget>[
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                final vault = widget.vaults.elementAt(index);
                return _buildVaultEntry(vault);
              },
              childCount: widget.vaults.length,
            ),
          )
        ]));
  }

  Widget _buildVaultEntry(LoanVault vault) {
    return Card(
        child: ListTile(
      title: Column(children: [
        Text(
          vault.vaultId,
          overflow: TextOverflow.ellipsis,
        ),
        Row(children: [
          Text(
            S.of(context).loan_collateral_ratio,
            style: Theme.of(context).textTheme.caption,
          ),
          Container(width: 5),
          Text(vault.collateralRatio)
        ])
      ]),
      onTap: () {
        this.widget.onVaultSelected(vault);
      },
    ));
  }
}
