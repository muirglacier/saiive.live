import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:saiive.live/ui/widgets/table_widget.dart';

class VaultFAQScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _VaultFAQScreen();
  }
}

class _VaultFAQScreen extends State<VaultFAQScreen> {
  _buildView() {
    List<List<String>> items = [
      [S.of(context).loan_faq_collateral, S.of(context).loan_faq_collateral_answer],
      [S.of(context).loan_faq_collateral_ratio, S.of(context).loan_faq_collateral_ratio_answer],
      [S.of(context).loan_faq_vault_status, S.of(context).loan_faq_vault_status_answer],
      [S.of(context).loan_faq_vault_interests, S.of(context).loan_faq_vault_interests_answer],
      [S.of(context).loan_faq_vault_factor, S.of(context).loan_faq_vault_factor_answer],
    ];

    return CustomTableWidget(items);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight, title: Text(S.of(context).loan_faq)), body: _buildView());
  }
}
