import 'package:intl/intl.dart';

class FundFormatter
{
  static String format(double number, {int fractions = 8}) {
    var formatter = NumberFormat('#,##0.00000000');
    formatter.minimumFractionDigits = fractions;
    formatter.maximumFractionDigits = fractions;

    return formatter.format(number);
  }
}