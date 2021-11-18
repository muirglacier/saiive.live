import 'package:saiive.live/network/model/loan_collateral.dart';
import 'package:saiive.live/network/model/loan_vault_collateral_amount.dart';

class LoanHelper
{
  static double calculateCollateralShare(double totalAmount, LoanVaultAmount amount, LoanCollateral collateralToken)
  {
    var price = amount.activePrice != null ? amount.activePrice.active.amount : 0;

    return (double.tryParse(amount.amount) * price / totalAmount) * 100;
  }
}
