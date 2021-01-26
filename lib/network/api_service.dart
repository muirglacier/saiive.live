import 'package:defichainwallet/network/account_service.dart';
import 'package:defichainwallet/network/transaction_service.dart';

import '../service_locator.dart';
import 'balance_service.dart';

class ApiService {
  AccountService _accountService;
  TransactionService _transactionService;
  BalanceService _balanceService;

  AccountService get accountService => _accountService;
  TransactionService get transactionService => _transactionService;
  BalanceService get balanceService => _balanceService;

  ApiService() {
    _accountService = sl.get<AccountService>();
    _transactionService = sl.get<TransactionService>();
    _balanceService = sl.get<BalanceService>();
  }
}
