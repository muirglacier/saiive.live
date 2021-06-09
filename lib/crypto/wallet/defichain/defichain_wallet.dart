import 'dart:async';
import 'dart:math';

import 'package:defichaindart/defichaindart.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/crypto/from_account.dart';
import 'package:saiive.live/crypto/crypto/hd_wallet_util.dart';
import 'package:saiive.live/crypto/wallet/defichain/defichain_wallet_helper.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/helper/balance.dart';
import 'package:saiive.live/network/model/account.dart';
import 'package:saiive.live/network/model/token.dart';
import 'package:saiive.live/network/model/transaction_data.dart';
import 'package:tuple/tuple.dart';
import '../impl/wallet.dart' as wallet;
import 'package:saiive.live/network/model/transaction.dart' as tx;

abstract class IDeFiCHainWallet {
  Future<TransactionData> createAndSendSwap(String fromToken, int fromAmount, String toToken, String to, int maxPrice, int maxPriceFraction,
      {StreamController<String> loadingStream});

  Future<TransactionData> createAndSendAddPoolLiquidity(String tokenA, int amountA, String tokenB, int amountB, String shareAddress, {StreamController<String> loadingStream});
  Future<TransactionData> createAndSendRemovePoolLiquidity(int token, int amount, String shareAddress, {StreamController<String> loadingStream});
}

class DeFiChainWallet extends wallet.Wallet implements IDeFiCHainWallet {
  DeFiChainWallet(bool checkUtxo) : super(ChainType.DeFiChain, checkUtxo);

  final int AuthTxMin = 200000;
  static final int MinKeepUTXO = 2000000;

  @override
  Future<TransactionData> createAndSendRemovePoolLiquidity(int token, int amount, String shareAddress, {StreamController<String> loadingStream}) async {
    await ensureUtxo(loadingStream: loadingStream);
    await walletMutex.acquire();

    try {
      var addLiq = await removePoolLiquidity(token, amount, shareAddress, loadingStream: loadingStream);
      loadingStream?.add(S.current.wallet_operation_send_tx);
      return await createTxAndWait(addLiq, loadingStream: loadingStream);
    } finally {
      walletMutex.release();
    }
  }

  @override
  Future<TransactionData> createAndSendAddPoolLiquidity(String tokenA, int amountA, String tokenB, int amountB, String shareAddress,
      {StreamController<String> loadingStream}) async {
    await ensureUtxo(loadingStream: loadingStream);
    await walletMutex.acquire();

    try {
      var addLiq = await addPoolLiquidity(tokenA, amountA, tokenB, amountB, shareAddress, loadingStream: loadingStream);
      loadingStream?.add(S.current.wallet_operation_send_tx);
      return await createTxAndWaitInternal(addLiq, loadingStream: loadingStream);
    } finally {
      walletMutex.release();
    }
  }

  Future<Tuple3<String, List<tx.Transaction>, String>> removePoolLiquidity(int token, int amount, String shareAddress, {StreamController<String> loadingStream}) async {
    var fees = await getTxFee(0, 0);
    await prepareAccount(fees, loadingStream: loadingStream);

    final key = mnemonicToSeed(seed);

    final txb = await createBaseTransaction(0, shareAddress, shareAddress, fees, (txb, inputTxs, nw) async {
      var tx = await getAuthInputsSmart(shareAddress, AuthTxMin, fees);

      txb.addRemoveLiquidityOutput(token, amount, shareAddress);

      final addressInfo = await walletDatabase.getWalletAddress(tx.address);

      final keyPair = HdWalletUtil.getKeyPair(
          key, addressInfo.account, addressInfo.isChangeAddress, addressInfo.index, ChainHelper.chainFromString(tx.chain), ChainHelper.networkFromString(tx.network));

      final inputContainsAuthTx = inputTxs.where((element) => element.mintTxId == tx.mintTxId && element.mintIndex == tx.mintIndex);
      if (inputContainsAuthTx.isEmpty) {
        var vin = txb.addInput(tx.mintTxId, tx.mintIndex);
        txb.addOutput(tx.address, tx.value);
        final p2wpkh = P2WPKH(data: PaymentData(pubkey: keyPair.publicKey)).data;
        final redeemScript = p2wpkh.output;

        txb.sign(vin: vin, keyPair: keyPair, witnessValue: tx.value, redeemScript: redeemScript);
      }
    });

    return txb;
  }

  Future<String> addPoolLiquidity(String tokenA, int amountA, String tokenB, int amountB, String shareAddress, {StreamController<String> loadingStream}) async {
    if (!DeFiConstants.isDfiToken(tokenA) && !DeFiConstants.isDfiToken(tokenB)) {
      throw ArgumentError("One of the 2 tokens must be DFI!");
    }

    final useAmount = await prepareAccount(DeFiConstants.isDfiToken(tokenA) ? amountA : amountB);

    if (DeFiConstants.isDfiToken(tokenA)) {
      amountA = useAmount;
    } else {
      amountB = useAmount;
    }

    final tokenABalance = await walletDatabase.getAccountBalance(tokenA);
    final tokenBBalance = await walletDatabase.getAccountBalance(tokenB);

    if (tokenABalance.balance < amountA) {
      throw new ArgumentError("Insufficient balance...");
    }

    if (tokenBBalance.balance < amountB) {
      throw new ArgumentError("Insufficient balance...");
    }

    final tokenAType = await apiService.tokenService.getToken("DFI", tokenA);
    final tokenBType = await apiService.tokenService.getToken("DFI", tokenB);
    final key = mnemonicToSeed(seed);

    final accountsA = await walletDatabase.getAccountBalancesForToken(tokenA);
    final accountsB = await walletDatabase.getAccountBalancesForToken(tokenB);

    final fee = await getTxFee(0, 0);

    final accountA = await DefichainWalletHelper.getHighestAmountAddressForSymbol(accountsA, amountA);
    final accountB = await DefichainWalletHelper.getHighestAmountAddressForSymbol(accountsB, amountB);

    if (amountA > accountA.balance) {
      //handle account to account - move account balance to new address
      await createAccountTransaction(tokenA, amountA, accountA.address);
    }
    if (amountB > accountB.balance) {
      //handle account to account - move account balance to new address
      await createAccountTransaction(tokenB, amountB, accountB.address);
    }

    final useableAccountsA = await _getNeededAccounts(accountsA, amountA);
    final useableAccountsB = await _getNeededAccounts(accountsB, amountB);

    var inputTxs = List<tx.Transaction>.empty(growable: true);
    inputTxs.addAll(useableAccountsA.item2.where((element) => element.address == accountA.address));

    for (final input in useableAccountsB.item2) {
      if (!inputTxs.any((element) => element.mintTxId == input.mintTxId && element.mintHeight == input.mintHeight)) {
        inputTxs.add(input);
      }
    }

    final txb = await HdWalletUtil.buildAddPollLiquidityTransaction(inputTxs, accountA.toFromAccount(), accountB.toFromAccount(), walletDatabase, tokenAType.id, tokenBType.id,
        shareAddress, amountA, amountB, fee, shareAddress, key, chain, network);
    return txb.build().toHex();
  }

  Future<Tuple2<List<FromAccount>, List<tx.Transaction>>> _getNeededAccounts(List<Account> accounts, int amount, {List<String> excludeAddresses}) async {
    var curAmount = 0;
    var useAccounts = List<FromAccount>.empty(growable: true);
    final fees = 0;

    final inputTxs = List<tx.Transaction>.empty(growable: true);

    for (final tx in accounts) {
      if (excludeAddresses != null && excludeAddresses.contains(tx.address)) {
        continue;
      }

      final fromAccount = FromAccount(address: tx.address, amount: tx.balance);
      useAccounts.add(fromAccount);

      inputTxs.add(await getAuthInputsSmart(tx.address, AuthTxMin, fees));
      if ((curAmount + tx.balance) >= amount) {
        fromAccount.amount = amount;
        break;
      } else {
        fromAccount.amount = tx.balance - curAmount;
      }
      curAmount += tx.balance;
    }

    return Tuple2(useAccounts, inputTxs);
  }

  Future<TransactionData> createAndSendSwap(String fromToken, int fromAmount, String toToken, String to, int maxPrice, int maxPriceFraction,
      {StreamController<String> loadingStream}) async {
    await ensureUtxo(loadingStream: loadingStream);
    await walletMutex.acquire();

    try {
      loadingStream?.add(S.current.wallet_operation_create_swap_tx);
      var swap = await createSwap(fromToken, fromAmount, toToken, to, maxPrice, maxPriceFraction, loadingStream: loadingStream);
      loadingStream?.add(S.current.wallet_operation_send_tx);
      var tx = await createTxAndWait(swap, loadingStream: loadingStream);

      return tx;
    } finally {
      walletMutex.release();
    }
  }

  Future<Tuple3<String, List<tx.Transaction>, String>> createSwap(String fromToken, int fromAmount, String toToken, String to, int maxPrice, int maxPriceFraction,
      {StreamController<String> loadingStream}) async {
    if (DeFiConstants.isDfiToken(fromToken)) {
      fromAmount = await prepareAccount(fromAmount, loadingStream: loadingStream);
    }

    final changeAddress = await getPublicKeyFromAccount(account, true);
    final fees = await getTxFee(1, 2) + 5000;

    final fromTokenBalance = await walletDatabase.getAccountBalance(fromToken);

    if (fromTokenBalance.balance < fromAmount) {
      throw new ArgumentError("Insufficient balance...");
    }

    final fromTok = await apiService.tokenService.getToken("DFI", fromToken);
    final toTok = await apiService.tokenService.getToken("DFI", toToken);
    final fromAccounts = await walletDatabase.getAccountBalancesForToken(fromToken);
    final fromAccount = await DefichainWalletHelper.getHighestAmountAddressForSymbol(fromAccounts, fromAmount);

    final key = mnemonicToSeed(seed);

    final tokenBalance = await walletDatabase.getAccountBalance(fromToken, excludeAddresses: [fromAccount.address]);

    if (tokenBalance.balance < (fromAmount - fromAccount.balance)) {
      loadingStream?.add(S.current.wallet_operation_send_tx);
    }

    if (fromAmount > fromAccount.balance) {
      await createAccountTransaction(fromToken, fromAmount - fromAccount.balance, fromAccount.address, excludeAddresses: [fromAccount.address]);
    }
    await getAuthInputsSmart(fromAccount.address, AuthTxMin, fees);

    final txb = await createBaseTransaction(0, to, changeAddress, fees, (txb, inputTxs, nw) async {
      var tx = await getAuthInputsSmart(fromAccount.address, AuthTxMin, fees);

      txb.addSwapOutput(fromTok.id, fromAccount.address, fromAmount, toTok.id, to, maxPrice, maxPriceFraction);

      final inputContainsAuthTx = inputTxs.where((element) => element.mintTxId == tx.mintTxId && element.mintIndex == tx.mintIndex);
      if (inputContainsAuthTx.isEmpty) {
        final addressInfo = await walletDatabase.getWalletAddress(tx.address);

        final keyPair = HdWalletUtil.getKeyPair(
            key, addressInfo.account, addressInfo.isChangeAddress, addressInfo.index, ChainHelper.chainFromString(tx.chain), ChainHelper.networkFromString(tx.network));

        var vin = txb.addInput(tx.mintTxId, tx.mintIndex);
        txb.addOutput(tx.address, tx.value);
        final p2wpkh = P2WPKH(data: PaymentData(pubkey: keyPair.publicKey)).data;
        final redeemScript = p2wpkh.output;

        txb.sign(vin: vin, keyPair: keyPair, witnessValue: tx.value, redeemScript: redeemScript);
      }
    });
    return txb;
  }

  @override
  Future<String> createSendTransaction(int amount, String token, String to, {StreamController<String> loadingStream, bool sendMax = false}) async {
    final changeAddress = await this.getPublicKeyFromAccount(account, true);

    if (DeFiConstants.isDfiToken(token)) {
      if (sendMax) {
        await moveAllTokensToUtxo(changeAddress);
      } else {
        var txHex = await prepareAccountToUtxosTransactions(changeAddress, amount, sendMax: sendMax);

        if (txHex != null) {
          for (var txHexStr in txHex.item1) {
            final tx = await createTxAndWaitInternal(txHexStr);

            for (final unspentTx in tx.details.outputs) {
              if (unspentTx.address == changeAddress) {
                await walletDatabase.addUnspentTransaction(unspentTx);
              }
            }
          }
          await walletDatabase.removeUnspentTransactions(txHex.item2);
          amount -= txHex.item3;
        }
      }

      if (sendMax) {
        await ensureUtxoUnsafe();
        amount = (await BalanceHelper().getAccountBalance(token, chain)).balance;
      }

      return await createUtxoTransaction(amount, to, changeAddress, sendMax: sendMax, loadingStream: loadingStream);
    }
    return await createAccountTransaction(token, amount, to, loadingStream: loadingStream);
  }

  Future<String> createAccountTransaction(String token, int amount, String to,
      {bool sendMax = false, List<String> excludeAddresses, StreamController<String> loadingStream}) async {
    if (token == DeFiConstants.DefiTokenSymbol) {
      throw new ArgumentError("$token not supported for account transactions...");
    }

    final tokenBalance = await walletDatabase.getAccountBalance(token, excludeAddresses: excludeAddresses);

    if (amount > tokenBalance.balance) {
      throw ArgumentError("Insufficent funds"); //insufficent funds
    }

    final tokenType = await apiService.tokenService.getToken("DFI", token);
    final key = mnemonicToSeed(seed);

    final accounts = await walletDatabase.getAccountBalancesForToken(token);
    final useAccounts = List<FromAccount>.empty(growable: true);
    final keys = List<ECPair>.empty(growable: true);
    var fee = await getTxFee(0, 0);

    if (sendMax) {
      fee *= -1;
    }

    final inputTxs = List<tx.Transaction>.empty(growable: true);

    var curAmount = 0;
    for (final tx in accounts) {
      if (tx.address == to) {
        continue;
      }

      final fromAccount = FromAccount(address: tx.address, amount: tx.balance);
      useAccounts.add(fromAccount);

      final addressInfo = await walletDatabase.getWalletAddress(tx.address);

      inputTxs.add(await getAuthInputsSmart(tx.address, AuthTxMin, fee));

      final keyPair = HdWalletUtil.getKeyPair(key, addressInfo.account, addressInfo.isChangeAddress, addressInfo.index, addressInfo.chain, addressInfo.network);
      keys.add(keyPair);

      if ((curAmount + tx.balance) >= amount) {
        fromAccount.amount = amount;
        break;
      } else {
        fromAccount.amount = tx.balance - curAmount;
      }
      curAmount += tx.balance;
    }

    if (inputTxs.isEmpty) {
      return null;
    }

    final changeAddress = await getPublicKeyFromAccount(account, true);
    var lastTxId = "";
    for (var authAddress in useAccounts) {
      final txb = await HdWalletUtil.buildAccountToAccountTransaction(inputTxs, authAddress, keys, tokenType.id, to, amount, fee, changeAddress, chain, network);
      loadingStream?.add(S.current.wallet_operation_send_tx);
      var txD = await createTxAndWait(Tuple3<String, List<tx.Transaction>, String>(txb.build().toHex(), inputTxs, changeAddress));

      lastTxId = txD.txId;
    }
    return lastTxId;
  }

  Future<Tuple3<String, List<tx.Transaction>, String>> createAuthTx(String pubKey, int amount, {StreamController<String> loadingStream, bool sendMax = false}) async {
    final changeAddress = await getPublicKeyFromAccount(account, true);

    final tokenBalance = await walletDatabase.getAccountBalance(DeFiConstants.DefiTokenSymbol);

    if (tokenBalance.balance < amount) {
      amount = tokenBalance.balance;
    }

    var baseTx = await createBaseTransaction(amount, pubKey, changeAddress, 0, (txb, inputTxs, nw) {
      txb.addAuthOutput(outputIndex: 0);
    }, sendMax: tokenBalance.balance == amount);
    loadingStream?.add(S.current.wallet_operation_create_auth_tx);
    return baseTx;
  }

  Future<tx.Transaction> getAuthInputsSmart(String pubKey, int amount, int minFee, {StreamController<String> loadingStream, bool sendMax = false}) async {
    var authTxs = await walletDatabase.getUnspentTransactionsForPubKey(pubKey, minFee);

    if (authTxs.isNotEmpty) {
      return authTxs.first;
    }

    var txHex = await createAuthTx(pubKey, amount, loadingStream: loadingStream);
    var txData = await createTxAndWait(txHex, loadingStream: loadingStream);
    final retOut = txData.details.outputs.firstWhere((element) => element.spentHeight <= 0 && element.address == pubKey);

    return retOut;
  }

  Future<int> prepareUtxoToAccountTransaction(int amount, {StreamController<String> loadingStream}) async {
    final tokenBalance = await walletDatabase.getAccountBalance(DeFiConstants.DefiTokenSymbol);
    final accBalance = await walletDatabase.getAccountBalance(DeFiConstants.DefiAccountSymbol);

    final accountBalance = accBalance.balance != null ? accBalance.balance : 0;
    final totalBalance = (tokenBalance.balance != null ? tokenBalance.balance : 0) + accountBalance;

    if (accountBalance > amount) {
      // we already have enough acc balance
      return amount;
    }

    if (totalBalance == amount) {
      amount -= MinKeepUTXO;
    }

    if (amount > totalBalance) {
      throw ArgumentError("Insufficent funds"); //insufficent funds
    }

    loadingStream?.add(S.current.wallet_operation_create_pepare_acc_tx);

    final key = mnemonicToSeed(seed);

    final unspentTxs = await walletDatabase.getUnspentTransactions();
    final useTxs = List<tx.Transaction>.empty(growable: true);
    final keys = List<ECPair>.empty(growable: true);
    final fee = await getTxFee(0, 0);

    var checkAmount = (amount - accountBalance) + fee;

    var curAmount = 0;
    for (final tx in unspentTxs) {
      useTxs.add(tx);
      curAmount += tx.valueRaw;

      if (!await walletDatabase.isOwnAddress(tx.address)) {
        continue;
      }

      final address = await walletDatabase.getWalletAddress(tx.address);
      final keyPair =
          HdWalletUtil.getKeyPair(key, address.account, address.isChangeAddress, address.index, ChainHelper.chainFromString(tx.chain), ChainHelper.networkFromString(tx.network));

      keys.add(keyPair);

      if (curAmount >= checkAmount) {
        break;
      }
    }
    final changeAddress = await getPublicKeyFromAccount(account, true);

    final tokenType = await apiService.tokenService.getToken("DFI", DeFiConstants.DefiAccountSymbol);

    for (final input in useTxs) {
      var needAmount = min(checkAmount, input.value);
      var burnFees = needAmount + fee;

      if (fee + needAmount > input.value) {
        needAmount -= fee;
        burnFees = input.value;
      }

      final txs = await createBaseTransaction(0, changeAddress, changeAddress, burnFees, (txb, inputTxs, nw) {
        txb.addUtxosToAccountOutput(tokenType.id, input.address, needAmount, nw);

        checkAmount -= needAmount;
      });

      var txData = await createTxAndWait(txs, loadingStream: loadingStream);

      for (var input in txData.details.inputs) {
        if (await walletDatabase.isOwnAddress(input.address)) {
          final accBalance = new Account(
              address: input.address,
              balance: needAmount,
              token: DeFiConstants.DefiAccountSymbol,
              chain: ChainHelper.chainTypeString(chain),
              network: ChainHelper.chainNetworkString(network));
          await walletDatabase.setAccountBalance(accBalance);
        }
      }
      if (checkAmount <= 0) {
        break;
      }
    }
    return amount;
  }

  Future moveAllTokensToUtxo(String pubKey) async {
    var tokenBalance = await walletDatabase.getAccountBalance(DeFiConstants.DefiTokenSymbol);

    if (tokenBalance == null || tokenBalance.balance == 0) {
      throw new ArgumentError("Token balance must be greater than 0 to create any tx!");
    }

    final accounts = await walletDatabase.getAccountBalancesForToken(DeFiConstants.DefiAccountSymbol);

    if (accounts == null) {
      return;
    }

    final fees = await getTxFee(0, 0);

    final tokenType = await apiService.tokenService.getToken("DFI", DeFiConstants.DefiAccountSymbol);

    for (final account in accounts) {
      var txData = await prepareAccountToUtxo(pubKey, tokenType, account, fees);

      var createTx = Tuple3<String, List<tx.Transaction>, String>(txData.item1, txData.item2, "");
      await createTxAndWait(createTx);
    }
  }

  Future<Tuple2<String, List<tx.Transaction>>> prepareAccountToUtxo(String pubKey, Token tokenType, Account account, int fees) async {
    final key = mnemonicToSeed(seed);

    final useInputs = List<tx.Transaction>.empty(growable: true);
    final keys = List<ECPair>.empty(growable: true);

    final authTx = await getAuthInputsSmart(account.address, AuthTxMin, fees, sendMax: true);
    useInputs.add(authTx);

    walletDatabase.addUnspentTransaction(authTx);

    if (!await walletDatabase.isOwnAddress(authTx.address)) {
      return null;
    }

    final address = await walletDatabase.getWalletAddress(authTx.address);
    final keyPair = HdWalletUtil.getKeyPair(
        key, address.account, address.isChangeAddress, address.index, ChainHelper.chainFromString(authTx.chain), ChainHelper.networkFromString(authTx.network));

    keys.add(keyPair);

    var txHex = await HdWalletUtil.buildTransaction(useInputs, keys, pubKey, 0, fees, pubKey, (txb, inputTxs, network) async {
      final mintingStartsAt = txb.tx.ins.length + 1;

      txb.addOutput(pubKey, account.balance);
      txb.addAccountToUtxoOutput(tokenType.id, account.address, account.balance, mintingStartsAt);
    }, chain, network);

    return Tuple2<String, List<tx.Transaction>>(txHex, useInputs);
  }

  Future<Tuple3<List<String>, List<tx.Transaction>, int>> prepareAccountToUtxosTransactions(String pubKey, int amount, {bool sendMax = false}) async {
    var tokenBalance = await walletDatabase.getAccountBalance(DeFiConstants.DefiTokenSymbol);

    if (tokenBalance == null || tokenBalance.balance == 0) {
      throw new ArgumentError("Token balance must be greater than 0 to create any tx!");
    }

    // we have currently enough utxo
    if (tokenBalance.balance > amount) {
      return null;
    }

    var accountBalance = await walletDatabase.getAccountBalance(DeFiConstants.DefiAccountSymbol);
    var totalBalance = accountBalance.balance + tokenBalance.balance;

    if (totalBalance < amount) {
      throw new ArgumentError("Balance $totalBalance is less than $amount");
    }

    var neededUtxo = amount - tokenBalance.balance;
    final accounts = await walletDatabase.getAccountBalancesForToken(DeFiConstants.DefiAccountSymbol);

    if (accounts.length == 0) {
      throw new ArgumentError("No accounts found..");
    }
    final key = mnemonicToSeed(seed);
    final usedInputs = List<tx.Transaction>.empty(growable: true);
    final fees = await getTxFee(0, 0);

    var accBalance = 0;

    final tokenType = await apiService.tokenService.getToken("DFI", DeFiConstants.DefiAccountSymbol);
    final txs = List<String>.empty(growable: true);

    for (final acc in accounts) {
      final useInputs = List<tx.Transaction>.empty(growable: true);
      final keys = List<ECPair>.empty(growable: true);

      final authTx = await getAuthInputsSmart(acc.address, AuthTxMin, fees);
      useInputs.add(authTx);
      usedInputs.add(authTx);

      walletDatabase.addUnspentTransaction(authTx);
      walletDatabase.setAccountBalance(Account(token: DeFiConstants.DefiTokenSymbol, address: acc.address, balance: acc.balance, chain: acc.chain, network: acc.network));

      if (!await walletDatabase.isOwnAddress(authTx.address)) {
        continue;
      }

      final address = await walletDatabase.getWalletAddress(authTx.address);
      final keyPair = HdWalletUtil.getKeyPair(
          key, address.account, address.isChangeAddress, address.index, ChainHelper.chainFromString(authTx.chain), ChainHelper.networkFromString(authTx.network));

      keys.add(keyPair);
      var useAcc = acc;

      if ((accBalance + acc.balance) >= neededUtxo) {
        var neededAccBalance = min(acc.balance, neededUtxo - accBalance);
        accBalance += neededAccBalance;
        useAcc = Account(address: acc.address, balance: neededAccBalance, chain: acc.chain, network: acc.network, raw: acc.raw, token: acc.token);
      } else {
        useAcc = acc;
        accBalance += acc.balance;
      }

      var txHex = await HdWalletUtil.buildTransaction(useInputs, keys, pubKey, 0, fees, pubKey, (txb, inputTxs, network) async {
        final mintingStartsAt = txb.tx.ins.length + 1;

        txb.addOutput(pubKey, useAcc.balance);
        txb.addAccountToUtxoOutput(tokenType.id, acc.address, useAcc.balance, mintingStartsAt);
      }, chain, network);

      txs.add(txHex);

      if (accBalance > neededUtxo) {
        break;
      }
    }

    if (accBalance < neededUtxo) {
      throw new ArgumentError("should not happen at all now...");
    }

    return Tuple3(txs, usedInputs, fees * txs.length);
  }

  Future<int> prepareAccount(int amount, {StreamController<String> loadingStream}) async {
    return await prepareUtxoToAccountTransaction(amount, loadingStream: loadingStream);
  }
}
