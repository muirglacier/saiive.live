import 'package:saiive.live/network/model/loan_collateral.dart';
import 'package:saiive.live/network/model/loan_vault_active_price.dart';
import 'package:saiive.live/network/model/loan_vault_collateral_amount.dart';

class LoanHelper
{
  static double calculateCollateralShare(double totalAmount, LoanVaultAmount amount, LoanCollateral collateralToken)
  {
    var price = activePrice(amount.symbol, amount.activePrice);
    var collateralPrice = price * amount.amountDouble;
    var factor = double.tryParse(collateralToken.factor) ?? 0;

    return (((amount.amountDouble * price * factor) / (totalAmount == 0 ? collateralPrice : totalAmount))) * 100;
  }

  static double activePrice(String symbol, LoanVaultActivePrice price)
  {
    if (symbol == 'DUSD') {
      return 1;
    }

    return price != null ? price.active.amount : 0;
  }
}
