import 'package:intl/intl.dart';

class FundFormatter
{
  static String format(double number) {
    var formatter = NumberFormat('#,##0.00000000');
    formatter.minimumFractionDigits = 2;
    formatter.maximumFractionDigits = 8;

    return formatter.format(number);
  }
}