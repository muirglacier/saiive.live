import 'package:flutter/material.dart';
import 'package:saiive.live/network/model/loan_vault.dart';

class VaultStatusWidget extends StatefulWidget {
  final LoanVaultHealthStatus status;

  VaultStatusWidget(this.status);

  @override
  State<StatefulWidget> createState() => _VaultStatusWidget();
}

class _VaultStatusWidget extends State<VaultStatusWidget> {
  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(widget.status.toText()),
      backgroundColor: widget.status.toColor(),
    );
  }
}
