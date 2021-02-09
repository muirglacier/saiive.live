import 'package:defichainwallet/network/account_service.dart';
import 'package:defichainwallet/network/token_service.dart';
import 'package:defichainwallet/network/transaction_service.dart';

import '../service_locator.dart';
import 'balance_service.dart';

class ApiService {
  AccountService _accountService;
  TransactionService _transactionService;
  BalanceService _balanceService;
  TokenService _tokenService;

  AccountService get accountService => _accountService;
  TransactionService get transactionService => _transactionService;
  BalanceService get balanceService => _balanceService;
  ITokenService get tokenService => _tokenService;

  ApiService() {
    _accountService = sl.get<AccountService>();
    _transactionService = sl.get<TransactionService>();
    _balanceService = sl.get<BalanceService>();
    _tokenService = sl.get<ITokenService>();
  }
}
